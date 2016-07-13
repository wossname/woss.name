---
published_on: 2006-04-21
title: Getting Started with a Sun T2000
redirect_from: "/2006/04/21/getting-started-with-a-sun-t2000/"
category: Ops
tags:
  - coolthreads
  - t2000
  - sparcstation
  - hardware
  - solaris
  - alom
---
This is the first part in hopefully what will become a series on the trials
and tribulations I have with a [Sun Fire
T2000](http://www.sun.com/servers/coolthreads/t2000/test/overview_a.jsp?name=A)
over the coming weeks while I have it on trial.  This is going to be an interesting experience; I have used Sun kit extensively in the past -- I was one of the sysadmins for the [Tardis](http://www.tardis.ed.ac.uk/) project while at University, and since then I've run a variety of Internet services on Sun hardware, ranging from a SparcStation 5 (`homer.mathie.cx`, who used to be in the Usenet top 1000 peers, something I consider impressive for that calibre machine sitting behind a 512kb/s leased line) to a Sparc Ultra 30 (initially my desktop machine, eventually `drusilla.wossname.org.uk`, a replacement for `homer`).  So I'm reasonably familiar, if a little rusty, with Sun hardware and Solaris.  OK, OK, `homer` ran Linux, but at least all the Tardis kit was a mixture of Solaris 7 & 8 (with one machine, `brigadier` still running SunOS 4.1.4!).

You can read the entire series of articles by visiting [the Solaris category](/categories/ops/) of my blog.  Please help me make these articles as useful and informative as possible by making comments and pointing out corrections -- I do intend to redraft and compile them into a complete how-to in the future.

## Unpack the box ##

You'll be shocked and amazed at the size of the box it arrives in. Similarly,
you'll be incredulous at the size of the box the two power cables arrive in.
Seriously, you could fit a laptop in *that* box.

## Plugging it in ##

**Don't go plugging it in until you've read some instructions!** Unlike your
average computer, Sun kit has this fancy thing called Advanced Lights Out
Management (ALOM), which is basically a supervisor computer running all the
time, from the point when you plug the thing in to the mains. Once we get you
up and running properly, it'll allow you to connect to the computer over the
network (even when it's 'switched off') to do lots of things that you'd
otherwise have to be physically in front of the computer for (including
'unplugging' PCI cards or memory sticks!). This isn't even your OpenBoot type
system that ye olde Sun weenies are used to having on `cua0` when you switch
the machine on. No, that will appear *once you've switched the machine on from
the ALOM system console*!

Anyway. The first thing you'll need to do is contact your local Sun reseller
and ask nicely if you can borrow a serial console cable. Unless you're already
a Sun shop, in which case you're probably reading the wrong introduction!
Shipping one of these beasties, since it appears to be the only way to
bootstrap it, might have been a shrewd move. If you're like me, you'll speak
to a really friendly guy called Scott at your local Sun reseller, who will
offer to lend you the cable and adapter. You'll then drive 30 miles there and
back to pick it up.

If you're me, you'll also have an extra step: think you need a USB-to-serial
dongle and nip into your local PC hardware store to acquire one. Of course,
the one I acquired (the only one they had) doesn't appear to work with Mac OS
X, so that was pointless. Instead I dug out an old PC laptop, booted it to
find out what was installed (Debian, from back when Sarge was 'unstable') and
attempt to install `minicom`. `apt-get install minicom` fails miserably,
complaining that it would have to remove the essential package `e2fsprogs`
unless I want to download 657MB of updated packages. No thanks, I'll `apt-get
source minicom` and build it myself, thanks all the same.

So we hook up the serial console to the T2000, get minicom running and tell it
to use 9600 baud, 8 bits, 1 stop bit, no parity, with no flow control at all
-- neither hardware nor software. That's generally shortened to `96008n1` -- I
guess all this talk of serial devices is foreign to the cool kids these days?
And **now** you get to plug the machine in to the mains. Doesn't appear to
matter which PSU you choose and it'll happily run on just the one. First thing
you'll notice is that it's **really noisy** and you'll think to yourself, "the
wife is going to make me switch this off at night". Hooo, boy, you ain't heard
nothing yet!

Stuff should appear on the console.  If it doesn't, well, you've messed up something in the serial configuration, or you've plugged the cable into the wrong port.  To be fair, I did both (wrong port, and I forgot to switch off hardware flow control).

## Getting the Network ALOM Console working ##

First thing, get the network system console working, so you can put the T2000
away in a soundproof cupboard several timezones away. Once the console has
finally booted (ooh, interesting, it's built with
[VxWorks](http://www.windriver.com/portal/server.pt?space=Opener&control=OpenObject&cached=true&parentname=CommunityPage&parentid=4&in_hi_ClassID=512&in_hi_userid=27106&in_hi_ObjectID=769&in_hi_OpenerMode=2&))
you'll get a `sc>` prompt.  There's lots of exciting stuff you can do there, but let's resist temptation 'til we're away from this horrible, laggy serial interface.  Issue the following commands:

    setsc if_network true
    setsc netsc_ipaddr <ip address>
    setsc netsc_ipnetmask <ip netmask>
    setsc netsc_ipgateway <ip gateway>

Or you can do `setupsc` which will talk you through all those settings and more.  Just say `y` to setting up the network management port.  Make sure your network management port is plugged into the network and do `resetsc` -- shortly thereafter, your network management port will be working and you can `telnet` to the IP address you specified as `netsc_ipaddr` above.  Note that it's a really bad idea to stick your network management port on the same network as the computer itself (it should really be on a completely separate, secure, admin network), but that didn't stop me for the purposes of setting things up locally.  After all, the only person on this here network is, well, me, unless the cats are just *pretending* to be fast asleep next door...

## First Boot ##

Now that we've got the network management console running, we can go hide the racket-maker in a cupboard, remembering to hook up the network management port (above the USB ports) and the first regular Ethernet port.  Oh, and the power too, but you can't forget that or it'll sound strangely quiet. :)  `telnet` to the ip address you configured the management port as above, and it will immediately give you an `sc>` prompt.  The first thing I did was to set a password (actually I might have done that at the serial console stage, but I'm just paranoid) by running `password` and entering the new password twice.  Now in future, when you connect to the management console, it will ask for a login and password; the login is `admin` with the password you just supplied.

Let's skip all the fun stuff you can do from here and go straight to powering up the T2000 for the first time.  Run `poweron` and you'll see what I *really* mean about the noise.  That's the three fans which push air over the memory and CPU kicking in.  Wow.  Next run `console -f` to connect to the T2000's main console.  If you've used a Sparc machine before, this is where you'll start to recognise OpenBoot.  It'll run through a bunch of tests which takes ... I didn't measure it, but I'd say something in the region of 5 minutes.  If everything is successfully completed, it will restart the computer and boot properly.  Mine started Solaris straight away (I guess `auto-boot?` was set to `true`) even although the documentation suggested it might be otherwise.

It will then ask you to select a bunch of configuration options (language, date, time zone, network configuration) and to set an initial root password.  Then it reboots and you're ready to go.  You can log in as `root` with the password you supplied during the configuration and you'll be left in this alien environment that feels vaguely like the Linux and FreeBSD you've cut your teeth on, but not quite.

First thing?  Type `bash`.  At least that way you get tab completion which makes it seem slightly more natural.  You might consider doing `chsh` to change the permanently, but you'll be as surprised as I was to discover that command doesn't appear to exist.  Oh well, we'll gloss over that for now.  To list all processes, it's `ps -ef`, not `ps ax` as you might be tempted to type.  And I can't find `top` or `locate` or figure out how to `makewhatis` so I can at least use `apropos`.  It's all very strange...

## Updating the system ##

OK, so now we're logged in as root, let's update the system with all the latest patches and features.  I've spent the past 2 hours trying to figure out how to set things up from the command line and failed miserably.  In theory it looks like you should be able to do things with `smpatch` and/or `sconadm` and you should be able to do it without buying a support contract from Sun (though you'll only get a limited number of patches without the contract).  But I never managed.  Instead, I loaded up `updatemanager` and used the GUI tool to set up the update system.  This goes against my server-management-ethos (if I wanted pretty GUI tools, I'd use an XServe or *shock* maybe even Windows!), but I'd given up by this point.

Easiest way to do this was to enable root login over ssh (by changing `PermitRootLogin` to `yes` in `/etc/ssh/sshd_config` and restarting ssh with `kill -HUP <pid of master sshd>` -- the master ssh process is the one with a parent pid of 1) and ssh'ing in with `ssh -X <ipaddr>`, then launching `updatemanager`.  Unfortunately, this didn't work on my G5 -- the windows were all sized incorrectly and the GUI was unusable.  This is the first time I've run X11 on this machine, so it could be a more general problem; I felt that investigating further was too much of a distraction.  So I gave up and retrieved the trusty old laptop running Debian GNU/Linux.  `ssh` in and run `updatemanager`.  That works.  I've just run through the setup wizard, opting not to commit to giving Sun money before I've decided I'm keeping this system, and am proceeding with installing all 68 updates.

And I appear to have run out of beer, too.  Time to go find that nice bottle of Glen Marnoch before continuing.  Ah, yes, that's good stuff -- I'd never heard of it before, but it's very reminiscent of Glenmorangie.  You ever notice how they pour more generous measures at home than in the pub? :-)

## Starting afresh in the morning ##

OK, I've decided that I don't really want to continue using the preinstalled version of Solaris 10 sitting on this machine.  After all, why on earth would I want a full installation of X along with [Gnome](http://www.gnome.org/ "Gnome Desktop Environment") installed on a *server*?  So let's start from a clean, minimal installation where, hopefully, I can configure the two disks to act as a RAID mirror, get `sconadm` to install updates and generally be a happier bunny.

First stage is to head to [Solaris Downloads](http://www.sun.com/software/solaris/get.jsp).  I selected "Solaris 10 1/06" and "Sun Update Connection" and said that it was for evaluation use.  I'm currently downloading all the segments of the DVD, ready to burn and install.  Now would be the time to check that I do actually have blank DVD media sitting around here somewhere...

## Addendum ##

Yes, the wife made me switch that racket off before she went to bed last night...
