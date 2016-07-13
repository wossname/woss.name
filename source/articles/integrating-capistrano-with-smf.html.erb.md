---
published_on: 2007-06-24
title: Integrating capistrano with SMF

category: Internet
tags:
  - ruby
  - rails
  - smf
  - solaris
  - capistrano
  - mongrel
  - rbac
---
I've got a new application I'm in the process of deploying in order to demo for a client (no, it's not ready for everybody else to have a nosy at just yet!) and figured I'd take the opportunity to learn two things:

* What's new and shiny about [Capistrano 2](http://www.capify.org/).  Most of that was putting what I learned at [Harnessing Capistrano](/articles/harnessing-capistrano/) into practice.

* How to make the Solaris [Service Management Facility](http://www.opensolaris.org/os/community/smf/) (SMF) manage all my mongrel processes for me.

And I think I've pulled the right bits together to make it work rather well.  If I do say so myself. :-)

First up I got the basic project running and deploying.  I decided to work with, rather than against, capistrano as much as possible.  So that meant using `script/spin` and `script/process/*` instead of messing around with trying to port `mongrel_cluster` recipes to cap2.  So I created a `script/spin` with the following:

    #!/usr/bin/env bash

    /u/apps/example/current/script/process/spawner mongrel -p 9000 -i 3 -a 127.0.0.1

which makes the spawner start three mongrel processes, listening at 9000, 9001, & 9002, on localhost.  Dead simple.  Add that to your subversion repository and commit.  Now let's create a default capistrano configuration for the project:

    mathie@lagavulin:example$ capify .
    [add] writing `./Capfile'
    [add] writing `./config/deploy.rb'
    [done] capified!

Before I go any further, let's have a wee aside about my current capistrano setup.  I still have applications that require Capistrano 1.4.x (they're using third party plugins which haven't yet been ported), so I need to have access to both versions in my environment.  I've done this by having both versions of the gem installed.  Then in my bash environment, I have the following:

    alias cap1="`which cap` _1.4.1_"
    alias cap2="`which cap`"
    alias cap="echo 'Please explicitly choose cap1 or cap2.'"

So running `cap1` will pick capistrano version 1.4.1, and `cap2` will run the latest installed version.  Another useful snippet picked up from the Harnessing Capistrano tutorial -- thanks Jamis!

Anyway, on with the show.  Let's create a very basic deployment which deploys the application to 'example.rubaidh.com' running as the user 'deploy':

    # Basic configuration
    set :application, "example"
    set :repository,  "http://svn.rubaidh.com/#{application}/trunk"
    set :host, "example.rubaidh.com"
    set :user, "deploy"
    set :scm_username, ENV['USER']
    set :deploy_via, :remote_cache
    set :use_sudo, false

    role :app, host
    role :web, host
    role :db,  host, :primary => true

    # Specify some dependencies
    depend :remote, :command, :gem
    depend :remote, :gem, :mongrel, '>=1.0.1'
    depend :remote, :gem, :hpricot, '>=0.6'
    depend :remote, :gem, :rmagick, '>=1.15.7'
    depend :remote, :gem, :rake, '>=0.7'
    depend :remote, :gem, "bcrypt-ruby", '>=2.0.2'
    depend :remote, :gem, :BlueCloth, '>=1.0.0'

    # Clean up after ourselves, so we don't leave too many old releases lying
    # around.
    after :deploy, "deploy:cleanup"

A pretty simple configuration, but it shows off a couple of new features in Capistrano 2, the dependency checking (`depend`) and the new hooks system (`after`).  The latter, in particular, is a neat wee trick, I reckon.  After it's finished a deployment, it'll automatically clean up old releases, only leaving around the last 5.  Kudos to [Craig](http://beer-monkey.com/) for introducing that to me after we ran out of disk space on one production machine with 200+ old deployments lying around!

Doing a deployment is pretty simple:

    mathie@lagavulin:nang$ cap2 deploy:setup
      * executing `deploy:setup'
    [ snip ]
        command finished
    mathie@lagavulin:nang$ cap2 deploy:cold
      * executing `deploy:cold'
    [ snip ]
        command finished

Which will do the usual setup tasks, deploy the system, run any pending migrations and start up the servers.  That's us done for part one.  Now to get SMF to manage the mongrels for us.  First of all, we need to create a service manifest.  Create the following file on the server:

    <?xml version='1.0'?>
    <!DOCTYPE service_bundle SYSTEM '/usr/share/lib/xml/dtd/service_bundle.dtd.1'>
    <service_bundle type='manifest' name='example'>

      <!-- New service, called application/mongrel/nang -->
      <service name='application/rails/example' type='service' version='0'>

        <!-- Not enable by default when we're imported -->
        <create_default_instance enabled='false' />

        <!-- There can only be one! -->
        <single_instance />

        <!-- Dependent upon the local filesystem having been started -->
        <dependency name='fs' grouping='require_all' restart_on='none' type='service'>
          <service_fmri value='svc:/system/filesystem/local' />
        </dependency>

        <!-- Dependent upon the network having started up, since we bind to localhost -->
        <dependency name='net' grouping='require_all' restart_on='none' type='service'>
          <service_fmri value='svc:/network/loopback'/>
        </dependency>

        <!-- Multi-user is dependent upon us starting up. -->
        <dependent name='multi-user' restart_on='none' grouping='optional_all'>
          <service_fmri value='svc:/milestone/multi-user'/>
        </dependent>

        <!-- Apache depends on us starting up, since we are its backend -->
        <dependent name='apache2' restart_on='none' grouping='optional_all'>
          <service_fmri value='svc:/network/http:cswapache2' />
        </dependent>

        <!-- Environment -->
        <method_context working_directory='/u/apps/example/current'>
          <method_credential user='deploy' group='deploy' />
          <method_environment>
            <envvar name='PATH' value='/usr/bin:/bin:/opt/csw/bin'/>
            <envvar name='RAILS_ENV' value='production' />
          </method_environment>
        </method_context>

        <!-- Start and stop methods. -->
        <exec_method name='start'   type='method' exec='/bin/nohup /u/apps/example/current/script/spin' timeout_seconds='60' />
        <exec_method name='stop'    type='method' exec='/u/apps/example/current/script/process/reaper -a kill' timeout_seconds='60' />
        <exec_method name='restart' type='method' exec='/u/apps/example/current/script/process/reaper' timeout_seconds='60' />

        <!-- Authorisation -->
        <property_group name='general' type='framework'>
          <propval name='action_authorization' type='astring' value='rails.applications' />
          <propval name='value_authorization'  type='astring' value='rails.applications' />
        </property_group>
      </service>
    </service_bundle>

This probably deserves some explanation.  We're creating a service manifest for the service with the FMRI of `svc:/application/rails/example`.  We're saying that it shouldn't be enabled by default when it's imported, and that there can only be one instance of it running at a time.  Next we say what the dependencies are, and what services are dependent upon it (Apache, mostly).  We configure its environment (working directory, user, path and `RAILS_ENV`).  The methods for starting, stopping and restarting the service are all cargo-culted directly from the capistrano 2 default deployment recipe.  Finally, there's a wee bit of magic: We are telling the SMF framework that anybody who has been granted the `rails.applications` authorisation is allowed to stop and start the service, so you no longer need to be root to restart it!

Once you've created that file on the server, import it and check that it's been done correctly:

    mathie@example:~$ pfexec svccfg import smf.xml
    mathie@example:~$ svcs example
    STATE          STIME    FMRI
    disabled       20:54:15 svc:/application/rails/example:default

Excellent!  Now we have to do a little extra fiddling to get the authorisation to work.  Add the following to the end of `/etc/security/auth_attr`:

    rails.applications:::Manage Rails applications::

And the following to  the end of `/etc/user_attr`:

    deploy::::type=normal;auths=rails.applications

This declares the authorisation and assigns it to the deploy user.  We can check that it's been done correctly by running:

    mathie@cardhu:~$ auths deploy
    rails.applications,[ snip ]

Finally, we need to modify the capistrano deployment slightly.  But before we do that, make sure and stop the app servers with the old configuration so nothing gets confused:

        mathie@lagavulin:example$ cap2 deploy:stop

Remove the `set :use_sudo, false` line from `config/deploy.rb` because we are going to want to use the sudo mechanism, though not for launching sudo.  Then append the following:

    set :fmri, "application/rails/#{application}"
    set :sudo, 'pfexec'

    namespace :deploy do
      task :start, :roles => :app do
        invoke_command "/usr/sbin/svcadm enable #{fmri}", :via => fetch(:run_method, :sudo)
      end

      task :stop, :roles => :app do
        invoke_command "/usr/sbin/svcadm disable #{fmri}", :via => fetch(:run_method, :sudo)
      end

      task :restart, :roles => :app do
        invoke_command "/usr/sbin/svcadm restart #{fmri}", :via => fetch(:run_method, :sudo)
      end
    end

This overrides the default start, stop and restart tasks for the deployment scenario to use `pfexec` (to gain the appropriate authorisation) and `svcadm` to control the service.  Run:

            mathie@lagavulin:example$ cap2 deploy:start

to make sure it works.  You can verify it works by looking at `svcs` on the server:

    mathie@cardhu:~$ svcs -p example
    STATE          STIME    FMRI
    online         20:56:08 svc:/application/rails/example:default
                   20:56:07     5953 mongrel_rails
                   20:56:07     5956 mongrel_rails
                   20:56:08     5959 mongrel_rails

We have a running app. :-)  Satisfy yourself that it's all working OK by doing a full deploy (`cap2 deploy`) then checking that the pids listed in the `svcs -p` output have changed and that your app has updated.  Finally, reboot the machine to check that it all comes back up again afterwards?  It does?  How excellent is that? :)
