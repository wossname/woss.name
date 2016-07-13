---
published_on: 2014-11-26
title: Dockerising a Rails App
excerpt: |
  Today we're going to explore how to bundle up a sample Ruby on Rails
  application into Docker images, run containers locally in our development
  environment, and link the containers together so they can talk to each other.
  On the way, we'll automate the build with Rake, and discover a little more
  about how container linking actually works.
category: Internet
tags:
  - docker
  - ruby
  - rails
  - nginx
  - postgresql
  - runit
  - phusion
---

Last time, we learned how to get [Vagrant, Docker & VMWare Fusion][part-1]
running locally on our Mac development environment, and even convinced it to
serve a trivial static blog through nginx. Today, we're going to up our game
and get a full Ruby on Rails application running in the docker environment,
complete with separate containers for each service. We're going to take the
[widgets][] app we were using to muck around with
[specifying controllers with RSpec][rspec-part-1], and see how to deploy it properly.

So, what would we like to achieve?

* Being able to build and test our docker containers locally, since that'll be
  the fastest way to iterate on them and build the right thing.

* Separate containers for each of the separate concerns in the web app. Right
  now, I'm aiming for:

  * a front end nginx container, which serves the static assets for the
    application, and proxies to the Rails application server;

  * the application server itself, which runs the Rails application; and

  * a backend PostgreSQL container to store the database.

* Pushing all our customised images up to the [Docker Registry][] so that we
  can easily deploy them elsewhere.

* Deploying the images onto a container host in the cloud, just to prove it
  works in production, too.

Sounds like a plan, eh?

## PostgreSQL Container

The first order of business, since it's easiest, is to get a PostgreSQL
container up and running. Here, we don't need anything special, so we can grab
a stock container from the [Docker Registry][]. Fortunately, there's an
[official image](https://registry.hub.docker.com/_/postgres/) we can use. In
fact, we can just download and run it:

```bash
docker run -d --name postgres postgres
```

This image exposes a running PostgreSQL database on port 5432 (its well-known
port), and has a superuser called 'postgres'. It also trusts all connections to
itself by anyone claiming to be the postgres user, so it's not the sort of
thing that you'd want to expose to the public internet. Fortunately, since
we're running all our Docker containers on the same host, we don't need to
anyway (though it's still worth remembering that you're also trusting all the
other containers running on that same host!).

## Our App Server

Let's tackle the trickiest bit, next: building our own custom container that
runs the application. We can't just pick something off the shelf that'll work
here, but we can start from a firm foundation. For that, let's begin with
[`phusion/base_image`](https://registry.hub.docker.com/u/phusion/baseimage/).
This is an opinionated starting point, as it has a particular style of running
docker containers. In particular, instead of being a single-process-based
container, it has an init system, and runs a handful of ancillary services
inside the container. From this base image, we get:

* [runit][] for initialising the container, running services and supervising
  them to ensure they stay working;

* [syslog-ng][] for centralised logging on the container itself (which you may
  then want to configure to ship off to a central log server elsewhere);

* cron, for running of scheduled tasks; and

* an ssh daemon, which we can use to introspect the running container.

All these things would need further configuration for a production deployment
(in particular, ssh uses an insecure public key which should be replaced
ASAP!), but we'll punt on that for now and focus on building a container for
the app.

### The Dockerfile

Let's start building out a [Dockerfile][Dockerfile] for our application server.
First we start with some boilerplate, specifying the image we're building on,
and that we're maintaining this version:

```bash
FROM phusion/baseimage
MAINTAINER Graeme Mathieson <mathie@woss.name>
```

Next up, we'll install some system dependencies. For our app, we need Ruby 2.1,
some sort of JavaScript runtime, and the appropriate build tools to compile our
gem dependencies:

```bash
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update && apt-get dist-upgrade -qq -y
RUN apt-get install -qq -y ruby-switch ruby2.1 \
  build-essential ruby2.1-dev libpq-dev \
  nodejs
RUN ruby-switch --set ruby2.1
```

And we can update Rubygems for good measure, then install bundler to manage the
application's dependencies:

```bash
RUN gem update --system --no-rdoc --no-ri
RUN gem update --no-rdoc --no-ri
RUN gem install --no-rdoc --no-ri bundler
```

Now we specify the environment for the application. In a production
environment, we'd probably get this information from a configuration service,
but since we're just playing around, we can hard code them here, so at least
the app can know what it's supposed to be doing:

```bash
ENV RAILS_ENV production
ENV PORT 5000
ENV SECRET_KEY_BASE sekritkey
```

It turns out that we can use environment variables we've set here, later on in
the configuration file. We'll make use of this so we don't repeat ourselves
when specifying the port that the application server will expose:

```bash
EXPOSE ${PORT}
```

We'll supply a simple script so that runit can run the application server, and
restart it if it fails. The script is:

```bash
#!/bin/sh

export DATABASE_URL="postgresql://postgres@${POSTGRES_PORT_5432_TCP_ADDR}:${POSTGRES_PORT_5432_TCP_PORT}/widgets?pool=5"

cd /srv/widgets

/sbin/setuser widgets bundle exec rake db:create
/sbin/setuser widgets bundle exec rake db:migrate

exec /sbin/setuser widgets bundle exec \
  unicorn -p ${PORT} -c config/unicorn.rb \
    >> /var/log/rails.log 2>&1
```

We'll come onto the `DATABASE_URL` later on, but it's picking up the relevant
information from the container environment to figure out the database that
Rails should connect to. We're also cheating a bit, in that the init script
makes sure the database exists, and is migrated to the latest schema. I
wouldn't recommend this approach in a real production environment!

We install the script with:

```bash
RUN mkdir /etc/service/widgets
ADD config/deploy/widgets.sh /etc/service/widgets/run
```

Now, finally, we can install the application itself, along with its gem
dependencies:

```bash
RUN adduser --system --group widgets
COPY . /srv/widgets
RUN chown -R widgets:widgets /srv/widgets
RUN cd /srv/widgets && \
  /sbin/setuser widgets bundle install \
    --deployment \
    --without development:test
```

This dumps the container's build context (which is the directory that contains
the Dockerfile -- in other words, the root of our project) into `/srv/widgets`,
making sure it's owned by the `widgets` user, then installing dependencies.

### Building the custom app container

Now we've got a `Dockerfile` which describes the container we'd like to have, we can build it:

```bash
docker build -t 'mathie/widgets:latest' .
```

This runs through all the commands in the Docker configuration file in turn,
and executes them in a newly created container which is running the resulting
image from the previous command. This is clever stuff. Every new container is
built upon the results of the commands preceding it. One key benefit is that it
means Docker can cache these intermediate images, and only rebuild the bits
that are needed, resulting in faster image build times.

So, for example, if we just change our runit configuration file above, then
rebuild the image, Docker will used cached versions of the images generated
from each preceding command, only really running the `ADD` command to add the
new configuration file. Of course, since this emits a new image, all the
subsequent commands have to be re-run. It can be useful to bear this caching
strategy in mind when structuring your `Dockerfile`: put the bits that download
and install all your dependencies near the top, while leaving configuration
files and tweaks towards the end.

## Running the containers

Now we've built all the necessary containers, we can run them. First of all, let's run the PostgreSQL container, which provides a database service we can link to from our app:

```bash
docker run -d --name postgres postgres
```

Next, we can run the app itself, linking to the running PostgreSQL database:

```bash
docker run -d --name widgets \
  --link 'postgres:postgres' \
  mathie/widgets:latest
```

Linking allows an application on one container to connect to a service provided
by another container. In this example, it allows the `widgets` container to
connect to services running on the `postgres` container. This confused me for a
while; I assumed that the links were for *specific* services on the target
container. That's not the case. The client container has access to *all* the
exposed services on the target container.

Better still, linking containers allows us to auto-configure the connection to
the target container, using environment variables. That way, we're not hard
coding any IP configuration between the containers, which is just as well
seeing as we don't have any overt way to control it.

The `--link` flag has two colon-separated arguments. The first is the target
container. The second argument is the label used for the environment variables
on the source container. Let's try running an example container attached to the
`postgres` container to see what happens. And let's label the link "chickens"
just to make things clearer:

```bash
$ docker run -i -t --rm --link 'postgres:chicken' mathie/widgets:latest bash
$ env|grep CHICKEN
CHICKEN_ENV_LANG=en_US.utf8
CHICKEN_ENV_PGDATA=/var/lib/postgresql/data
CHICKEN_ENV_PG_MAJOR=9.3
CHICKEN_ENV_PG_VERSION=9.3.5-1.pgdg70+1
CHICKEN_NAME=/high_yonath/chicken
CHICKEN_PORT=tcp://172.17.0.177:5432
CHICKEN_PORT_5432_TCP=tcp://172.17.0.177:5432
CHICKEN_PORT_5432_TCP_ADDR=172.17.0.177
CHICKEN_PORT_5432_TCP_PORT=5432
CHICKEN_PORT_5432_TCP_PROTO=tcp
```

The environment variables that start `CHICKEN_ENV_` correspond to the
environment set up in the PostgreSQL instance's Docker configuration. We get
the container's name and label from the `CHICKEN_NAME` environment variable.
And we get each of the exposed ports (from `EXPOSE` in the docker configuration
file) in a few different ways, so that we can easily compose what we need to
connect to the service.

Now you can see how we compose the database URL above.

## Nginx Frontend

We're still missing one piece of the puzzle: something to serve static assets
(stylesheets, javascript, images, that kind of thing). We're using the Rails
Asset Pipeline to serve our assets, so we need to generate static copies of
them, bundle them up in a container running a web server, and get it to forward
real requests on to the backend. Just like all the cool kids, I've followed the
trends through Rails web serving, from Apache to Lighty, back to Apache with
Passenger, then onto Nginx. (I hope we're all still on Nginx, right?) Let's
stick with that.

There's an [nginx container][] that's ready to go, and it does almost all we need to do -- serve static assets -- but not quite. Still, we can start with it, and customise it a little. Let's create a second `Dockerfile`:

```bash
FROM nginx
MAINTAINER Graeme Mathieson <mathie@woss.name>

RUN rm -rf /usr/share/nginx/html
COPY public /usr/share/nginx/html
COPY config/deploy/nginx.conf /etc/nginx/conf.d/default.conf
```

All we're doing here is copying all the static assets (i.e. the contents of the
`public/` folder, some of which we'll have to generate in advance) across to
the container, and supplying an nginx configuration file that passes dynamic
requests to the back end. What does that nginx configuration file look like?

```nginx
server {
    listen       80;
    server_name  localhost;

    location / {
        root      /usr/share/nginx/html;
        index     index.html index.htm;
        try_files $uri/index.html $uri.html $uri @upstream;
    }

    location @upstream {
        proxy_pass http://widgets:5000;
    }
}
```

So, if a file exists (in a couple of forms), it'll serve it. If it doesn't,
it'll pass it on to this mysterious upstream called `widgets` at port 5000.

## Automating the build with Rake

Things are starting to get a little complicated here. Not only do we have to
remember to precompile the assets before building our web frontend, we also
have to remember to do it before building our app server too. (The app server
uses the generated `manifest.yml` file to figure out the cache-busting names it
should use for the assets it links to.) With all these dependent tasks, it
sounds like we need a make-clone to come to our rescue. Hello, rake!

There are a couple of things that we want to manage with rake:

* Since we're now building two different Docker images, we want the appropriate
  `Dockerfile` at the root of the repository, so that docker correctly picks up
  the entire app for its context. Let's rename our existing `Dockerfile` to
  `Dockerfile.app` and the web front end to `Dockerfile.web`. We can then get
  rake to symlink the appropriate one as it's doing the image build.

* We need to precompile all the assets for the asset pipeline.

* And, of course, we need to build the images themselves.

Let's create our rake tasks in
[lib/tasks/docker.rake](https://github.com/mathie/widgets/blob/master/lib/tasks/docker.rake)
with the following:

```ruby
namespace :docker do
  task :build => ['docker:build:web', 'docker:build:app', 'assets:clobber']

  namespace :build do
    task :app => ['assets:precompile', 'assets:clean'] do
      sh 'ln -snf Dockerfile.app Dockerfile'
      sh 'docker build -t "mathie/widgets:latest" .'
      sh 'rm -f Dockerfile'
    end

    task :web => ['assets:precompile', 'assets:clean'] do
      sh 'ln -snf Dockerfile.web Dockerfile'
      sh 'docker build -t "mathie/widgets-web:latest" .'
      sh 'rm -f Dockerfile'
    end
  end
end
```

Now we can run `rake docker:build` to build our pair of docker images, one for
the web front end, and one for the app itself. If you take a look at the file
in GitHub, you'll see that I've also added some helper tasks to automate
running and terminating the containers in the right order with the right links.

## Container Host Names

A little earlier, I noted that our nginx configuration was passing dynamic requests up to a mysteriously named back end:

```nginx
location @upstream {
    proxy_pass http://widgets:5000;
}
```

So what's that all about? Well, when we link containers together, in addition
to creating all those environment variables to help us configure our container,
it also writes the label out to `/etc/hosts`, giving us a name -> ip address
mapping for the linked container. Let's run a sample container to see this in
action:

```bash
$ docker run -i -t --rm --link 'widgets:chickens' mathie/widgets-web:latest bash
root@45aa608114f8:/# ping chickens
PING chickens (172.17.0.178): 48 data bytes
56 bytes from 172.17.0.178: icmp_seq=0 ttl=64 time=7.931 ms
```

Winning. This is particularly useful for the likes of nginx, where we can't use
environment variables in that particular context. Our alternative would have
been to figure out some sort of template nginx configuration that had variables
we could substitute when the container was run, and that would have been too
much like hard work!

## Running the web front end

So, to recap, now we have two running containers: one for PostgreSQL, and one
for the app itself. And we've built two custom containers: one for the app
itself, and one with static assets for the web front end. The final piece of
the puzzle is to start up the web front end:

```bash
docker run -d \
  --name widgets_web \
  -p 80:80 \
  --link "widgets:widgets" \
  mathie/widgets-web:latest
```

We're launching it with the custom container, binding port 80 on the container
to port 80 on the docker host, and linking the container to the app server. If
you've followed the instructions in [part 1][part-1] (in particular, around
giving the docker host a name, and running avahi for mDNS), then you should now
be able to visit <http://docker.local/> and see the running app.

## In Summary

It feels like it's been a long trek to get here, but we've achieved a lot:

* We're building custom Docker containers, starting from existing containers
  supplied by the community. And we've automated the build with Rake, so it
  would be trivial for our Continuous Integration system to automatically build
  these images every time we push up some new code.

* We've got an entire docker environment running locally, which will closely
  resemble our production environment. This will give us closer parity between
  development and production, reducing the scope of production-only errors, and
  improving our (still inevitable) production debugging experience.

* And we've learned how Docker actually works for linking containers, with both
  the environment variables available, and the host names supplied by Docker.
  Personally, I'm most pleased about that, because I hadn't properly understood
  it until now!

I do have one question that you might know the answer to, if you've suffered
your way through this entire rambling article: in a Docker configuration file,
what's the difference between `COPY` and `ADD`? The only difference I can see
is that `ADD` will accept source URLs in addition to files in the image's build
context. I suspect there's a subtle difference in caching behaviour, but I
could be way off base!


[part-1]: /articles/vagrant-docker-and-vmware-fusion/ "Vagrant, Docker & VMWare Fusion: Oh my!"
[widgets]: https://github.com/mathie/widgets
[rspec-part-1]: /articles/specifying-rails-controllers-with-rspec/ "Specifying Ruby on Rails Controllers with RSpec"
[Docker Registry]: https://registry.hub.docker.com
[runit]: http://smarden.org/runit/ "a UNIX init scheme with service supervision"
[syslog-ng]: http://www.balabit.com/network-security/syslog-ng/opensource-logging-system
[Dockerfile]: https://github.com/mathie/widgets/blob/master/Dockerfile.app
[nginx container]: https://registry.hub.docker.com/_/nginx/ "Official build of nginx at the Docker Registry."