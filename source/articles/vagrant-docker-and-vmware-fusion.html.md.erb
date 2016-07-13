---
published_on: 2014-11-23
title: "Vagrant, Docker & VMWare Fusion: Oh my!"
category: Internet
excerpt: |
  Today we figure out how to run Docker containers on Mac OS X with a little
  help from VMWare Fusion, and Vagrant.
tags:
  - vagrant
  - docker
  - vmware
  - containers
  - puppet
  - phusion
  - jekyll
  - nginx
---

I'm a bit behind the times when it comes to containerised deployments. I've
been quite happily using [Vagrant][] and [Puppet][] to model production
environments on my laptop before orchestrating their release into a real
production environment. It's delightful to be able to use Vagrant to recreate
entire production-like environments, complete with a local puppet master, on my
own computer, to test my Puppet changes before they go live.

With Vagrant at my back, and with all the experience I've picked up from
deploying Puppet I've largely ignored the new hotness that is [Docker][] --
after all, it's just Solaris Zones, right? ;)

I have to admit, I did have a wee poke around with Docker on my laptop a few
months back, but quickly gave up. The trouble is that I'm obstinate: I've paid
for a [VMWare Fusion][] license, and I'm insisting on using it. The Vagrant
support for Docker uses [boot2docker][], which only supports [VirtualBox][], so
I'm left high and dry. I figured it was time to get around that and figure out
a reliable way to run docker containers on my Mac OS X laptop.

The trouble, of course, is that Docker is a Linux technology, so it doesn't run
natively on Mac OS X. So we need a Linux VM to run the containers. Let's just
get this absolutely clear: we're trying to run containers within a Linux
virtual machine, which is running on VMWare Fusion, which is managed through
Vagrant which, in turn, is running on our Mac OS X laptop. (Yes, it's
[virtualisation technology all the way down][turtles]!)

So, what do we want from this Linux VM?

* Ideally, it should be accessible by some well-known name -- let's call it
  `docker.local` -- so that we can connect to services running on it without
  worrying about hard coding IP addresses, or forwarding ports back to the host
  machine.

* Most importantly, it should be running a recent stable version of Docker.

* It has (a portion of) the Mac OS X host file system shared with it, so that
  we can, in turn, share portions of that filesystem with docker containers.

You can find the full configuration up on GitHub: [Vagrantfile][]. Let's step
through it. All the configuration is wrapped in a standard vagrant
configuration block:

```ruby
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Configuration goes here.
end
```

First of all, we configure a base box. I'm using the base image of [Ubuntu
14.04][] provided by the folks at [Phusion][] (purveyors of Passenger and other
high quality things for a production environment):
[phusion/ubuntu-14.04-amd64](https://vagrantcloud.com/phusion/boxes/ubuntu-14.04-amd64).
Mostly, I'm using this base box because it's correctly configured for VMWare
Fusion, so things like shared folders keep working, even across updated kernel
packages. I'm also tweaking the number of CPUs available to the box, and the
memory, just to give us plenty of headroom for running containers:

```ruby
config.vm.box = "phusion/ubuntu-14.04-amd64"

config.vm.provider "vmware_fusion" do |provider|
  provider.vmx['memsize'] = 2048
  provider.vmx['numvcpus'] = 4
end
```

We'll give the box a well-known hostname because, along with installing
`avahi-daemon` shortly, that will allow us to refer to the vm by name, instead
of having to discover its IP address manually:

```ruby
config.vm.hostname = 'docker.local'
```

Finally, configuration-wise, let's mount the host's home directory somewhere
convenient, so that we can share folders with docker containers later on:

```ruby
config.vm.synced_folder ENV['HOME'], '/mnt'
```

This way, our entire home directory on Mac OS X will be available in `/mnt` on
the Linux VM. Handy. (I did initially muck around with mounting it on
`/home/vagrant`, but that turned out to create problems with SSH keys, so I
punted and mounted it somewhere neutral.)

Now all we need is a bit of shell magic to provision the machine. Specify a shell script provisioner with:

```ruby
config.vm.provision :shell, inline: <<-SHELL
  # Provisioning script goes in here.
SHELL
```

The rest of the code is inside the provisioning script. All we're doing is installing the latest stable version of Docker, direct from Docker's own apt repository, configuring it to listen for both TCP and socket connections, updating the rest of the system, and installing avahi for multicast DNS resolution. Simples:

```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
echo 'deb https://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get dist-upgrade -u -y -qq
apt-get install -qq -y lxc-docker avahi-daemon
apt-get autoremove --purge -y

adduser vagrant docker

echo 'DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"' >> /etc/default/docker
restart docker
```

Let's provision the box to make sure it's working, and run our first docker container:

```bash
$ vagrant up
# [ ... ]
$ vagrant ssh
$ docker run ubuntu echo hello world
# [ ... ]
hello world
```

Winning. But, even better still, we can run the Docker client on Mac OS X,
connecting to the Docker daemon running inside the VM. I've got docker
installed on my Mac through homebrew:

```bash
$ brew install docker
```

Now we can tell the Docker client where to connect (this is where setting the
hostname on our VM, and installing avahi, comes in handy). The `DOCKER_HOST`
environment variable can be used to say where our Docker host is. I've added
the following to my shell startup (`~/.zshenv` in my case):

```bash
export DOCKER_HOST="tcp://docker.local:2375"
```

Restart your shell and let's see if we can run a docker container directly from
Mac OS X:

```bash
$ docker run ubuntu echo hello world
hello world
```

Awesome. Finally, just to check we've got all the moving parts working as
desired, let's try to serve up this blog's generated content (built with
[Jekyll][]) using an [nginx][] container. This will check that we can run
daemon containers, connect to their advertised ports, and share the local
filesystem content with a container. Start the container, on your Mac OS X host's command line, with:

```bash
$ BLOG=Development/Personal/mathie.github.io/_site
$ docker run -d \
    -p 80:80 \
    --name wossname-nginx \
    -v /mnt/${BLOG}:/usr/share/nginx/html:ro \
    nginx
```

It's a bit of a mouthful. We're:

* running a docker container as a daemon, detaching it from the tty with the
  `-d` flag;

* forwarding port 80 on the docker host to port 80 of the container;

* giving the container a name (`wossname-nginx`) so that we can refer to it
  later;

* mounting a shared volume from this web site's output directory on the host
  (though note the path is based on where it's mounted inside the Linux VM) to
  the preconfigured HTML root for the nginx container; and

* finally, specifying the name of the image we want to run, which happens to be
  the most recent official nginx image.

With all that done, we can visit <http://docker.local/> and be served with the
most recently generated version of this web site. And it's coming from a docker
container inside a Linux VM running in VMWare Fusion, which is managed by
Vagrant, which is running on our Mac OS X host. It's amazing it looks so fresh
after travelling all that distance, eh?

The next step will be to try and serve up something a little more complex --
say, a simple Rails app -- with multiple containers. But that's for another day.

[Vagrant]: http://vagrantup.com/ "Create and configure lightweight, reproducible, and portable development environments."
[Puppet]: http://puppetlabs.com "Manage IT infrastructure as code across all environments."
[Docker]: https://www.docker.com "Build, Ship and Run Any App, Anywhere."
[VMWare Fusion]: http://www.vmware.com/uk/products/fusion "VMware Fusion 7."
[boot2docker]:http://boot2docker.io "boot2docker is a lightweight Linux distribution based on Tiny Core Linux made specifically to run Docker containers."
[VirtualBox]: https://www.virtualbox.org "VirtualBox is a powerful x86 and AMD64/Intel64 virtualization product for enterprise as well as home use."
[turtles]: http://en.wikipedia.org/wiki/Turtles_all_the_way_down "Turtles all the way down."
[Ubuntu 14.04]: http://releases.ubuntu.com/14.04/ "Ubuntu 14.04 LTS (Trusty Tahr)"
[Vagrantfile]: https://github.com/mathie/vagrant/blob/master/Vagrantfile
[Phusion]: http://www.phusion.nl
[Jekyll]: http://jekyllrb.com "Transform your plain text into static websites and blogs."
[nginx]: http://nginx.org/en/ "nginx [engine x] is an HTTP and reverse proxy server"