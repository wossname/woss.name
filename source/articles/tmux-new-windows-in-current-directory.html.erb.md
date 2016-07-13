---
published_on: 2014-11-16
title: "tmux: New Windows in the Current Working Directory"
category: Ops
tags:
  - tmux
  - path
  - working directory
  - screen
  - cwd
  - shell
  - command line
excerpt: |
  I could have sworn that tmux used to launch new shells in the current working directory of my active shell
  when it spawned new windows/panes. In this post, I discover that it wasn't my imagination, that it no
  longer happens by default, and how I can get the behaviour back again.
---
For a while, [tmux](http://tmux.sourceforge.net) would default to creating new
windows (and splits) with the shell in the current working directory
(<abbr title="Current Working Directory" class="initialism">CWD</abbr>) of my
existing pane.  As of quite recently, that seems to have stopped working; now
all my new shells are popping up with the
<abbr title="Current Working Directory" class="initialism">CWD</abbr> set to my
home directory. That's almost never where I want to be, and the
<abbr title="Current Working Directory" class="initialism">CWD</abbr> of the
previous window is at least as good a starting point as any.

It turns out, according to
[this question](http://unix.stackexchange.com/questions/12032/create-new-window-with-current-directory-in-tmux)
on Stack Exchange, that the default behaviour used to be, on tmux 1.7:

* If `default-path` is set on the session, set the current working directory of
  a new window (or split) to that directory; or

* if `default-path` is unset, use the current working directory of the current
  window.

In tmux 1.9, the `default-path` option was apparently removed. It's definitely
not mentioned in the man page on my installed version (1.9a). That's kind of a
shame, because setting the default path for a session would be a useful feature
(say, for example, setting it to the root of a project). Still, let's see about
making sure the new-window-related shortcuts within tmux do the right thing.
Add the following to `~/.tmux.conf`:

    # Set the current working directory based on the current pane's current
    # working directory (if set; if not, use the pane's starting directory)
    # when creating # new windows and splits.
    bind-key c new-window -c '#{pane_current_path}'
    bind-key '"' split-window -c '#{pane_current_path}'
    bind-key % split-window -h -c '#{pane_current_path}'

which updates the current key bindings to use the current pane's working
directory. I've also updated my `new-session` shortcut, too:

    bind-key S command-prompt "new-session -A -c '#{pane_current_path}' -s '%%'"

Much better! You can find my entire tmux configuration up on GitHub:
[tmux.conf](https://github.com/mathie/dot-files/blob/master/tmux.conf). Most of
the rest of the configuration is around customising the status bar.
