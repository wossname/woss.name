---
published_on: 2012-02-13
title: "Today I Learned: Vim command line fu"
excerpt: In which I learn some useful shortcuts to make life faster with the Vim command
  line.
redirect_from: "/2012/02/13/today-i-learned-vim-command-line-fu/"
category: Ops
tags:
  - vim
  - editors
  - command line
  - git
  - fugitive
---
OK, so this was "Thursday I learned" but I figured I should write it down before I forget again. One of my frustrations with Vim is better learning to use the command line. In this particular instance, I had been searching for a phrase inside a single file and I wanted to instead search for it with `git grep` (using `:Ggrep` from the awesome [fugitive.vim](https://github.com/tpope/vim-fugitive)). Of course, I didn't want to retype the thing I'd already been searching for. Turns out there are a couple of viable options:

* `ctrl-r /` will insert the last search pattern. So, having searched for something within a file and now wanting to search for it throughout the repository, I could do `:Ggrep ctrl-r /<cr>`. I think I want to turn that into a shortcut of some variety…

* The other possibility is to insert the word under the cursor. `ctrl-r ctrl-w` will insert the "word" under the cursor and `ctrl-r ctrl-a` will insert the "WORD" under the cursor (with 'word' and 'WORD' meaning what they usually do).

Here's a random bunch of other useful expansions:

* `ctrl-r "` will insert the contents of the unnamed register (i.e. the last thing you yanked or deleted without specifying a register).

* `ctrl-r +` will insert the clipboard contents.

* `ctrl-r %` will insert the current filename.

* `ctrl-r ctrl-p` will insert the filename under the cursor, expanded in the same way as `gf` does. This could be particularly useful with filetype plugins that extend the behaviour of `gf` (like Rails.vim).

It was useful to read through the rest of the [command line reference](http://vimdoc.sourceforge.net/htmldoc/cmdline.html) to reinforce the rest of the command line movement keys, too. So far I'd mostly just been mashing keys, assuming it behaves a bit like bash command line editing. Mostly I was right:

* `ctrl-b` (**not `ctrl-a`**) to get to the start of the command line buffer.

* `ctrl-e` to get to the end of the command line buffer.

* `ctrl-w` to delete the word before the cursor.

* `ctrl-u` to delete the characters from before the cursor to the start of the line (in other words, `ctrl-e ctrl-u` will delete the entire contents of the command line).

* `ctrl-c` to get safely out of the command line.

**Update** Drew, of [Vimcasts](http://vimcasts.org) fame, has pointed out that `ctrl-r` works in insert mode too. That's mind-blowingly useful. For example, you can use `ctrl-r "` in insert mode to paste something without exiting insert mode. I wish I'd already known that!
