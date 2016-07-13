---
published_on: 2011-12-30
title: "Give me back my # key!"
excerpt: Since I switched on "Use option as meta" in my Terminal app, I've lost my
  hash key. Can I have it back, please? Plus a bonus tip for quickly commenting out
  commands at the command line.
redirect_from: "/2011/12/30/give-me-back-my-hash-key/"
category: Ops
tags:
  - bash
  - meta
  - readline
  - inputrc
  - terminal
  - hash key
  - pound sign
---
This particular tip may have an audience of approximately one, since:

* It's only going to bother Mac users;

* who are in the UK;

* who use the `#` (hash, pound, whatever you call it) key much; and

* who have enabled "Use option as meta key" in Terminal.app in order to sanely use Emacs.

If you tick all these boxes, and have suddenly discovered that your # key (which is option-3 for UK-keyboard-wielding Mac users) no longer works, you've come to the right place!

The problem is that `M-3` is bound to `digit-argument`. This allows you to repeat commands (e.g. if you type `M-3` `c`, then it will output `ccc`) which I've got to admit I don't use terribly often.

It turns out that the bindings for keys are controlled by the [readline](http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html) library and you can customise them with readline's configuration file, `~/.inputrc`. If you want to override the default behaviour of M-3 and turn it back to emitting the `#` symbol, put the following in that file:

    "\e3": '#'

You'll need to restart bash (or force it to reload its `inputrc` file with `C-x C-r`) in order for it to take effect.

Here's another related tip, while I'm here. I picked this one up from [Ross](http://blog.rah.org/) a few years ago. I almost never use the UK currency symbol (`£`) in a shell environment. On the other hand, there's another operation I perform quite often at the command line: commenting out the command I'm currently typing. It usually happens when I'm doing a sequence of steps at the command line, and I realise that I've forgotten a prerequisite step. Rather than sticking the current line in the kill ring (`C-e C-u` or `C-a C-k`), then remembering to yank it (`C-y`) again, I tend to jump to the start of the line (`C-a`), stick a hash in (to comment the line out), then hit enter. That way it's in my (searchable) bash history for when I next need it.

But that's a fairly cumbersome sequence too, so let's shorten it. Stick the following in `~/.inputrc`:

    "£": '\C-a#\C-m'

and restart your shell. Now when you're part way through typing a command line and want to switch tracks, hit the `£` sign and you're done. When you want the command back, retrieve it from your shell history (`C-r` to search!), then hit `C-a C-d` to remove the comment sign and you're good to go.

One last wee trick. You really can remap any key to any other key. Imagine the fun and hilarity of the following in your `~/.inputrc`:

    "l": 'r'
    "s": 'm'

\:-)

**Update**: My colleague, Mihai, points out that the only appreciable difference between the UK and US keyboard layout on the Mac is that the `#` and `£` key combinations are swapped around (oh, and it's easier to find the ™ than the € now, not that I use either). Since I've just discovered that my `irb` isn't picking up the `~/.inputrc` and doing the right thing, I reckon I'll just switch to the US layout...
