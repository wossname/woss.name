---
published_on: 2005-11-22
title: Using launchd on Mac OS X
redirect_from: "/2005/11/22/using-launchd-on-mac-os-x/"
category: Ops
tags:
  - launchd
  - init
  - cron
  - mysql
  - postgresql
---
`launchd` is Mac OS X 10.4's replacement for `init`, `cron`, (`x`)`inetd` and all the various startup bits like `/etc/init.d` or `/Library/StartupItems` (as was the preferred way in Mac OS X up to 10.3.x).  It's all replaced with one supervisor daemon which controls the startup (and restart upon failure) of daemons, schedules regular running of tasks and other hoopy things.  I've been reading a little about it at [Introduction to Tiger Terminal part 5](http://www.macdevcenter.com/lpt/a/6332) and <a href="http://developer.apple.com/macosx/launchd.html">Getting started with `launchd`</a> trying to figure out how to make it work for me.  And I came up with settings, that will launch the [Darwin Ports](http://www.darwinports.com/) copies of both MySQL and PostgreSQL on demand, which you can download here: [mysql4.plist](/dist/mysql4.plist) and [postgresql.plist](/dist/postgresql.plist).  Place those files in `/Library/LaunchDaemons` and, to get `launchd` to notice them, run the following:

```bash
mathie@Tandoori:mathie$ sudo launchctl unload /Library/LaunchDaemons
Password:
mathie@Tandoori:mathie$ sudo launchctl load /Library/LaunchDaemons
```

You should now have a couple of extra launch services to control, which you can see with:

```bash
mathie@Tandoori:mathie$ sudo launchctl list
[ ... ]
mysql4
postgresql
```

In order to start MySQL and PostgreSQL, run the following:

```bash
mathie@Tandoori:mathie$ sudo launchctl start mysql4
mathie@Tandoori:mathie$ sudo launchctl start postgresql
```

And to stop them, replace the `start` in the above example with `stop`.  If either of the daemons happen to die horribly, they ought to be automatically restarted.  It's even smart about giving up restarting them if they fail 10 times in a short period.  If you want to always start these daemons automatically at boot (I don't, really, I just want to use them on demand occasionally), add the following inside the top-level dict in each of the plist files:

```xml
<key>RunAtLoad</key>
<true/>
```

You'll need to repeat the `unload`/`load` sequence from above to reload the plist files, but you'll notice that the MySQL and PostgreSQL daemons both start when the `load` command is issued (and also at system boot time).

Next, I would like to actually get MySQL and PostgreSQL to both start *entirely on demand*.  It looks kinda like this should be possible with `launchd`, using the `WatchPaths` key.  If I could tell it to watch for clients attempting to connect to the daemon's socket, then magically start the daemon in question on demand, quitting it after it's not needed, I could save quite a bit of system resources (particularly since I only really use PostgreSQL in a work capacity -- most of my personal development projects use MySQL since that's what my hosting company provides).

Unfortunately, I can't quite see how to achieve this.  Both the database daemons create sockets on the file system when they are launched.  I had hoped that simply specifying this file name as a `WatchPath` would be enough.  But since the sockets are only created when the daemons start, they aren't pervasive on the file system and don't exist for `launchd` to watch them the rest of the time.  I do wonder if just creating an empty file and having `launchd` watch that would be enough, but I suspect not.

It would also appear the `launchd` doesn't support any sort of dependency checking for daemons.  Which is unfortunate, since the next task I was going to get it to do is manage the Zope instances on my laptop.  However, in order to do this nicely, it would have been good to describe which instances use MySQL and which use PostgreSQL, then start up the relevant database before starting up the instance.  Likewise, if the instance also needed a ZEO for the back end ZODB.  But no, it doesn't appear that we can do that -- `StartupItems` provides that functionality instead.  So `launchd` isn't a *complete* replacement for its predecessors after all.  Oh well.
