---
published_on: 2012-01-04
title: Running tmux in Mac OS X Terminal

updated: 2014-09-16 00:00:00 +00:00
category: Internet
tags:
  - mac os x
  - tmux
  - shell
  - terminal
  - screen
  - launchd
---
I've been a fan of [screen](http://www.gnu.org/software/screen/) for ... a
while now. But since I like being one of the cool kids, I've been using
[tmux](http://tmux.sourceforge.net/) for the past year or so. Last week, I
noticed that every time I launch a new terminal, I wind up typing
`tmux attach-session`. Let's streamline, a little bit.

In Mac OS X's Terminal.app, you can change the shell that it runs. Here's how I
did it:

* Open Preferences, and choose the Settings tab.

* Duplicate your existing settings (since sometimes you might not want `tmux`
  after all). Pick your default session (mine's "Pro") and select "Duplicate
  profile" from the tool menu at the bottom. Name the new settings "Tmux" or
  something along those lines.

* In the shell tab for your settings, select "Run command" and enter
  `/usr/local/bin/tmux attach-session`. Deselect "Run inside shell" since you
  don't really need to. Since you're not running inside a shell,
  `/usr/local/bin` probably isn't in your `$PATH` so you'll need to specify the
  full path name. Of course, if your `tmux` binary lives somewhere other than
  `/usr/local/bin` you'll need to change the path.

* If you've selected "Only if there are processes other than" for "Prompt
  before closing", then you'll probably want to add `tmux` to that list.

* In the "Window" tab, I set "Scrollback" to limit the number of rows to '0',
  since tmux provides scroll back, and the Terminal one isn't terribly useful
  when tmux is running inside it.

* Make sure your Tmux session is set as the default one by clicking the
  "Default" button at the bottom of the settings lists while it's selected.

That's it. Close your existing terminal sessions and launch a new one. You
should be launched into (one of) your existing tmux sessions. If tmux wasn't
already running, then this assumes that your tmux configuration sets up at
least one session when it first starts. Add the following to the end of
`~/.tmux.conf` to make that happen:

    new-session -s Default

If you've got more than one tmux session running, then it will reattach you to
the last session you were using. You can always switch to another session with
`C-a s`, which will allow you to select from a list of running sessions. (You
have rebound the prefix to `C-a`, right?)

There are some (rare) occasions where you *don't* want tmux as your shell. (For
example, when you're running tmux in an ssh session and get tired of hitting
`C-a a C-a a` to correctly escape moving to the start of a line!) In Terminal,
choose the Shell menu, choose "New Window" (or "New Tab") and select one of the
other settings profiles.

You can find my entire tmux configuration up on GitHub:
[tmux.conf](https://github.com/mathie/dot-files/blob/master/tmux.conf). Most of
the rest of the configuration is around customising the status bar.
