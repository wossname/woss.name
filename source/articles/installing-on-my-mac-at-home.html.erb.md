---
published_on: 2011-02-04
title: Installing on my Mac at home
excerpt: This is a short tutorial on connecting back to your home Mac via SSH, through
  the magic of MobileMe, then downloading some software, mounting the disk image and
  installing it, all without the need of the Mac OS X GUI. I use VirtualBox as an
  example, but it should work for any standard Mac OS X installer.
redirect_from: "/2011/02/04/installing-on-my-mac-at-home/"
category: Ops
tags:
  - installation
  - mobileme
  - mac os x
  - ssh
  - virtualbox
  - vagrant
  - dns
  - mdns
---
I'm in the office and I want to start installing some software on my laptop at home so it's ready to try when I get back to my laptop. (The test suite is running and I know the install will take a while, so it can get going while I commute!) In particular, I was looking to try [Vagrant](http://vagrantup.com/), which requires [VirtualBox](http://www.virtualbox.org/).

First step: Back to my Mac. Turns out, if you're sensible enough to have SSH running on your Mac (enable it under Sharing in System Preferences), it's available from other Macs where you have your MobileMe account set up. Simply run:

    ssh <hostname>.<MobileMe name>.members.mac.com

where `<hostname>` is the short name of your laptop and `<MobileMe name>` is your MobileMe login. So, for example:

    ssh jura.mathie.members.mac.com

gets me to my laptop. (Interestingly, this doesn't resolve on hosts where you're not logged in to your MobileMe account, so there's some DNS resolution magic going on locally. At least I hope so, and I've not just exposed myself on the Internet!)

Next up, let's grab VirtualBox. Head across to the web site to figure out the latest download URL, and download it with curl:

    curl -LO http://[...]/VirtualBox-4.0.2-69518-OSX.dmg

Once it's downloaded, we have to mount the disk image. The simplest way with Mac OS X is to use `hdiutil`:

    hdiutil attach VirtualBox-4.0.2-69518-OSX.dmg

This will mount the disk image on `/Volumes/VirtualBox`. Now we have to run the installer, which we can do headless:

    sudo installer -pkg /Volumes/VirtualBox/VirtualBox.mpkg -target / -verbose

This needs to run as root, hence `sudo`. Since it's verbose, it'll spit out a bunch of progress stuff, because we asked it to be verbose. But that's it. Thanks to having a standard installer, we can install Mac OS X packages without a GUI. Win.

We should tidy up after ourselves by unmounting the disk image:

    hdiutil detach /Volumes/VirtualBox

And we're done. VirtualBox is installed, and I can get onto the long running download of grabbing the demo Ubuntu 10.04 LTS image for Vagrant (which clocks in at nearly 500MB). Getting started with Vagrant is another story entirely, which I'm sure I'll talk about sometime soon.

Well, we're nearly done. Let's finish up by freaking out whoever's in the house:

    say "We're watching you!"

\:-)
