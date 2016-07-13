---
published_on: 2007-06-12
title: Best Practice with sudo

category: Internet
tags:
  - sudo
  - authorisation
  - logging
  - tracking
  - rbac
---
I just found this lecture in some documentation I'd been writing for a client.  Clearly I was running through an install, documenting it as I go along, and was filling in time while something happened.  Anyway, I thought I'd share it here:

> As a side note, before I go on, let's have some best-practice
> discussion about doing things as root. Since you can't log in directly as root on Ubuntu installs,
> you always log in with your own user name and use sudo to gain root
> access. This way we get a log entry, along the lines of:
>
>     Apr 6 09:38:36 cluedo sudo: cl_mustard : TTY=pts/0 ; \
>     PWD=/home/library ; USER=prof_plum ; \
>     COMMAND=/bin/kill --with lead_pipe mrs_white
>
> So we see:
>
> * When something happened (April 6th, at 9:38AM).
> * Who did it (cl_mustard).
> * Where they were (/home/library).
> * Who they masqueraded as (prof_plum).
> * The command they ran (/bin/kill --with lead_pipe mrs_white).
>
> In order for this to work, I need to **ban** the use of the following
> two commands:
>
> * `sudo -s`
> * `sudo su -`
>
> which I often used to see in the [Tardis](http://www.tardis.ed.ac.uk/) logs. When you do this, the
> system logs no longer show what you were up to so we lose our audit
> trail.  Unfortunately, it's pretty much impossible to effectively stop folks doing
> this, so I'm just saying: **don't do it!** Always do `sudo -u <user>
> <command>` to make it explicit what you're doing!
>
> On the downside,
> there are also some situations where it's necessary to do `sudo -s` --
> for example when you want to look at file where you don't have read
> permission in the directory, but you can't remember the name of the
> file!)

So there you go.  That's how I believe you should use sudo.  One of these days I ought to figure out how to make the RBAC stuff in Solaris log stuff in a similar manner.  I seem to recall getting as far as running `bsmconv` & rebooting, then getting distracted by something else...
