---
published_on: 2005-08-17
title: Using ssh-agent and screen together
category: Internet
tags:
  - ssh
  - screen
  - tmux
  - ssh-agent
  - environment
---
I've been meaning to 'fix' this for ages.  I use public-key authentication for my [ssh](http://www.openssh.com/) connections wherever possible.  I also use [screen](http://www.gnu.org/software/screen/) all the time.  (If you use ssh regularly and haven't discovered it already, go look now!  There's a bit of a learning curve, but it's well worth it!)  But the <code>SSH_AUTH_SOCK</code> isn't always set correctly inside a screen session, so you can't then use the ssh key on the client computer to authenticate against other hosts.  (Oh, I also have a reasonably strict policy of only ever create SSH keys for hosts that I am actually, physically, at the console of, not for hosts I merely ssh into now and then.  There are, of course, exceptions to this rule!)

Let's describe the problem a little more clearly.  I have two Macs, <code>tandoori</code> and <code>dream</code>.  <code>Tandoori</code> is my work laptop, <code>dream</code> is my iMac at home.  And my web hosting company allows shell access with ssh to <code>woss.name</code>.  First thing in the morning, I'm logging in from dream to check some logs, then detaching from the session.  The screen session is a new one, since the shell server got rebooted in the night.  Here is the session, (minus what I actually did!):

```bash
mathie@Tandoori:mathie$ ssh -A -t woss.name screen -xRR
[ ... my shell starts up inside screen ... ]
mathie@napoleon:mathie$ echo $SSH_AUTH_SOCK
/tmp/ssh-XXjqTtiY/agent.25944
mathie@napoleon:mathie$ ssh-add -l
1024 f8:c2:ae:f9:5c:8f:28:67:ba:fb:c6:d8:60:2f:f5:52 /Users/mathie/.ssh/id_dsa (DSA)
mathie@napoleon:mathie$
[detached]
Connection to napoleon.dreamhost.com closed.
mathie@Tandoori:mathie$
```

As you can see, it is happily talking to my ssh agent on my iMac and using the identity stored there.  Now, later on I login from <code>tandoori</code> to check something else:

```bash
mathie@Tandoori:mathie$ ssh -A -t woss.name screen -xRR
[ ... my shell starts up inside screen ... ]
mathie@napoleon:mathie$ echo $SSH_AUTH_SOCK
/tmp/ssh-XXjqTtiY/agent.25944
mathie@napoleon:mathie$ ssh-add -l
Could not open a connection to your authentication agent.
mathie@napoleon:mathie$
[detached]
Connection to napoleon.dreamhost.com closed.
mathie@Tandoori:mathie$
```

Why couldn't it connect this time?  Well, because the environment variable <code>SSH_AUTH_SOCK</code>, which it inherited from the environment when screen was first started, points to the <em>old</em> agent socket from the first session of the morning, not the current socket.

So, what to do about it?  Well, here's my solution, from my ~/.bashrc:

```bash
if [ -z ! "$SSH_AUTH_SOCK" ]; then
    screen_ssh_agent=${HOME}/usr/state/ssh-agent-screen
    if [ "$TERM" = "screen" ]; then
        SSH_AUTH_SOCK=${screen_ssh_agent}; export SSH_AUTH_SOCK
    else
        ln -snf ${SSH_AUTH_SOCK} ${screen_ssh_agent}
    fi
```

So, if the current terminal is inside a screen session, it will use a fixed, known path to an agent socket.  And if the current terminal is <em>not</em> a screen session (say the login shell that precedes reconnecting to screen!), it will update the symlink.  (Of course, my ~/.bashrc is a little more complicated than that -- you can see the ssh-related stuff in [usr/etc/profile.d/ssh.sh](/svn/mathie/homedir/trunk/usr/etc/profile.d/ssh.sh).  Or at least you would be able to if websvn wasn't a pile of poo.)

There is one failure scenario I can think of.  Say you have two terminal windows open on your desktop, with one connected to the screen session on <code>woss.name</code>  But then you want another view onto the current screen session, so ssh in from the other terminal window.  Then you log out from the second window.  Since logging in from the second window had the effect of updating the symlink to point to its agent, the first no longer has a valid connection to its agent.  But it's a rare enough case that I am not too worried about it.
