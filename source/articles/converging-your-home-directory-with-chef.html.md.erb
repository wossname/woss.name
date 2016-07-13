---
published_on: 2011-01-23
title: Converging your Home Directory with Chef
excerpt: |
  In this tutorial, I'll take you through using Chef and Homebrew to manage
  your home directory in Mac OS X. I've also included a neat cookbook which will
  allow you to use Homebrew as your native packaging system in Chef.

category: Internet
tags:
  - mac os x
  - ruby
  - chef
  - homebrew
  - tmux
  - rvm
  - devops
  - development
---
In this tutorial, I'll take you through using Chef and Homebrew to manage your
home directory in Mac OS X. I've also included a neat cookbook which will allow
you to use Homebrew as your native packaging system in Chef.

## TL;DR

* Chef is awesome.

* You can grab the cookbook to use Homebrew as the native packaging system for
  Chef on GitHub at [chef-homebrew](https://github.com/mathie/chef-homebrew).

* Managing your configuration isn't just for servers.

* If you spend any time at a command line, you owe it to yourself to use `tmux`
  (or `screen`).

* The formatting of the code samples on this post is a work in progress... Sorry.

## Getting Started with Chef

Mac OS X, and the current breed of open source developer tools (notably
[Homebrew](http://mxcl.github.com/homebrew/) and
[RVM](http://rvm.beginrescueend.com/)) introduce an interesting possibility
when it comes to managing one's home directory. These mechanisms allow you to
install arbitrary packages, owned and run by your own user.

So, you've got a package manager which installs software and allows you to
start/stop services. You've got a bunch of configuration files, both for those
services, and dotfiles in your home directory. What's the best way to manage
these? With some sort of configuration management tool, of course! There's
plenty to choose from (including [lcfg](http://www.lcfg.org/),
[cfengine](http://www.cfengine.org/) and [Puppet](http://www.puppetlabs.com/))
but the one I've been working with on and off for the past couple of years is
[Chef](http://wiki.opscode.com/display/chef/Home).

How do you get started? Well, personally, I'd just choose one piece of
configuration to manage. Let's say, for example, that you want to manage your
tmux configuration. Let's create a cookbook for that. Start with a repository:

```bash
mkdir personal-chef
cd personal-chef
touch README
git init
git add .
git commit -m "First post."
```

I like to use bundler to manage gem dependencies. There's only one dependency
right now -- chef -- but we might as well start out sensibly. Create a
`Gemfile` in the root of your repository and give it the following content:

```ruby
source :rubygems
gem 'chef'
```

Save that and run:

```bash
bundle
```

which will install chef & its dependencies. You might want to noodle around
with a `.rvmrc` to get an isolated gemset for the project too (I do), but
that's very much a personal taste thing (that I'll cover in another post).

Now let's create a really basic configuration for `chef-solo` to allow it to
put things in the right place, and to find its roles & cookbooks. Create a
`config` folder in your new repository and add the following to
`config/solo.rb`:

```ruby
root_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))

cookbook_path   File.join(root_path, 'cookbooks')
role_path       File.join(root_path, 'roles')

# Move all the state stuff from /var/chef. I wish there was a single config
# variable for this!
state_root_path = File.expand_path('~/.chef/state')
file_cache_path  "#{state_root_path}/cache"
checksum_path    "#{state_root_path}/checksums"
sandbox_path     "#{state_root_path}/sandbox"
file_backup_path "#{state_root_path}/backup"
cache_options[:path] = file_cache_path
```

I haven't caught all the paths pointing to `/var/chef` but it has been enough
for chef to stop whining at me so far. ;-)

Now let's create ourselves some data that tells chef what we want to do with
ourselves. As the configuration grows larger, I'm probably going to want to
introduce roles, but let's keep it simple for now. Create `config/mathie.json`
(adjust to taste!) and fill it in with the following:

```javascript
{
  "run_list": [ "recipe[tmux]" ]
}
```

Very simple for now. The final bit of context we're going to want before we get
to the interesting bits is a quick script to run chef. Here's one I prepared
earlier, called `converge.sh`:

```bash
#!/bin/bash
chef-solo -c config/solo.rb -j config/mathie.json $*
```

(That should probably be `bundle exec chef-solo` but it failed the time I tried
it, and I haven't yet tracked down why.) Make it executable:

```bash
chmod +x ./converge.sh
```

Add that lot to your git repository and commit if you haven't been doing so
already (little and often!). The last thing we need to do before we can verify
the machinery is working is create a skeleton for the cookbook itself:

```bash
mkdir -p cookbooks/tmux/recipes
touch cookbooks/tmux/recipes/default.rb
```

All being well, the next thing we can do is test that it's all wired up
correctly:

```bash
./converge.sh
```

which should spit out ~6 lines from chef saying that it's starting, finishing
and tidying up. If that doesn't work so well, try:

```bash
./converge.sh -l debug
```

(which is why we stuck the `$*` on the end of the `chef-solo` invocation in
there!) and see if you can see what's going wrong. If you can't, drop me a
comment and I'll see if I can help!

### Converging on tmux

So, we've got the infrastructure in place. Next thing we need to figure out is
installing packages. Chef has some neat separation between what it refers to as
'resources' and 'providers' so that, in your recipes, you can say:

```ruby
package 'tmux'
```

and it will do the right thing, no matter what platform you're on.
Unfortunately, Chef doesn't ship with the ability to manage packages with
Homebrew. That's why I come in. I've put together a cookbook which will install
homebrew if it doesn't already exist, keep it up to date and, most importantly,
hook into Chef to use Homebrew as the native package manager. Let's pull that
wonderful cookbook in using git's [subtree merge
strategy](http://www.kernel.org/pub/software/scm/git/docs/howto/using-merge-subtree.html)
(which, since we're DevOps Ninjas, in this situation, is pretty much the way
forward):

```bash
git remote add -f homebrew git://github.com/mathie/chef-homebrew.git
git merge -s ours --no-commit homebrew/master
git read-tree --prefix cookbooks/homebrew -u homebrew/master
git commit -m "Pull in mathie's awesome Homebrew cookbook."
```

(If I've just lost you, or you're not using Git, head to
<https://github.com/mathie/chef-homebrew> and stick the contents of that
repository in `cookbooks/homebrew`.)

Now we should be good to go with getting tmux installed through Homebrew. Edit
`cookbooks/tmux/recipes/default.rb` so that it contains:

```ruby
include_recipe 'homebrew'
package 'tmux'
```

Save and commit (early and often!). Now run `./converge.sh`. It should bumble
around for a bit, installing Homebrew if you haven't got it already, and
installing tmux using Homebrew. Run it again, and it shouldn't do a whole lot.
Win.

### Converging a tmux configuration

Last thing we're going to do here, just to demonstrate managing configuration
too, is installing a managed `~/.tmux.conf` file. Add the following to
`cookbooks/tmux/recipes/default.rb`:

```ruby
template "#{ENV['HOME']}/.tmux.conf" do
  source "tmux.conf.erb"
end
```

and create `cookbooks/tmux/templates/default/tmux.conf` with your favourite
tmux configuration. Let's say, for example, that you're on Mac OS X and you
want to know the current battery level in your status bar:

```bash
set -g status-right "#[fg=green]#(pmset -g ps |awk 'BEGIN { FS=\"\t\" } /InternalBattery/ { print $2 }')"
```

(kinda useful, huh?) Now run:

```bash
    ./converge.sh
```

and your tmux configuration will magically be installed into `~/.tmux.conf`.
Neat, huh?

### Conclusion

Chef isn't just for managing your massively scaled production infrastructure.
You can use it to manage lots of other things too, including your home
directory. The win here is magnified with each computer you work with (home
desktop, work desktop and a laptop while you're out and about?).

So, have you tried using Chef to manage your home directory? How did you find
it? Good stuff? Bad stuff? What other strategies have you tried?

**Update** In addition to publishing the Cookbook on Github as [chef-homebrew](https://github.com/mathie/chef-homebrew) I've also uploaded it to the Opscode Cookbooks. Get it here: [homebrew](http://cookbooks.opscode.com/cookbooks/homebrew).
