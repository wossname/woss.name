---
published_on: 2010-03-15
title: Updating the path everywhere on Ubuntu 09.10
category: Internet
tags:
  - debian
  - ubuntu
  - linux
  - path
  - ruby
  - phusion
  - passenger
  - sudo
  - cron
  - bash
---
[Ubuntu](http://www.ubuntu.com/) is my Linux of choice. It has been for a long time. I've been a huge fan of [Debian](http://www.debian.org/) since the late '90s -- I was a Debian Developer stuck in the NM queue for a few years -- but the release cycle was *way* too long for my tastes (which invariably meant I kept most of my systems running testing or unstable). So I switched to Ubuntu pretty early on.

I'm also a Ruby developer and, in particular, keep [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/) fed and cared for on my production servers. Every time I do a fresh install I have to remind myself how to make sure REE is **always** in the path and definitely in the path ahead of an accidental install of the stock Ruby on Ubuntu.

Here's the list of things I've had to change this morning on Ubuntu 09.10 to make sure `$PATH` is set correctly everywhere:

* `/etc/environment`, updating the `PATH="..."` line to read:

  `PATH="/opt/ruby-enterprise/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"`

* `/etc/crontab`, updating its `PATH="..."` line to read:

  `PATH=/opt/ruby-enterprise/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin`

* `/etc/login.defs`, updating the `ENV_SUPATH` and `ENV_PATH` lines to read:

  `ENV_SUPATH	PATH=/opt/ruby-enterprise/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`
  `ENV_PATH	PATH=/opt/ruby-enterprise/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games`

* `/etc/sudoers`, where I've had to add the following line to override the compiled-in default:

  `Defaults        secure_path = "/opt/ruby-enterprise/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/X11R6/bin"`

That seems to have covered everything. The incantation for sudo was a bit of a bother to find (it being a built in default rather than configured in `/etc`), but with it, `sudo irb` now works, when it didn't before. I haven't changed the paths specified in init scripts as it seemed unnecessary.

For reference, the command I user to determine what might need changed was:

    sudo find /etc -type f | xargs sudo grep 'PATH=' | grep -v /opt/ruby-enterprise

It produced a number of false positives, but was a good bet for figuring out the right ones.

So, have I missed anything? Have I changed things I shouldn't have changed?

(And yes, I know, I should be using some sort of Configuration Management system to bootstrap everything I touch...)
