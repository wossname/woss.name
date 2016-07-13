---
published_on: 2011-08-28
title: Pimpin' TextMate (aka Top 5 TextMate Plugins, 2011 Edition)
excerpt: I've put together a list of the indispensable TextMate plugins that take
  a great editor and make it awesome, including enhanced file finding, project search
  and Lion full screen support.
redirect_from: "/2011/08/28/pimpin-textmate-aka-top-5-textmate-plugins-2011-edition/"
category: Ops
tags:
  - mac os x
  - textmate
  - vim
  - lion
  - peepopen
  - ack
  - ctags
---
All the cool kids are using [Vim](http://www.vim.org/) these days. That's fine, y'all go right ahead, but sorry, it's not really my thing. I'm perfectly happy with [TextMate](http://macromates.com/), thanks.

Don't get me wrong; I've been using various flavours of Vi for 17 years now. I'm reasonably proficient at it, and it's my tool of choice when I'm, say, editing server configuration files. I can plan and execute a series of changes to a file like a boss, *when I already know what I'm doing*. The trouble occurs when I'm coding, and what I'm trying to achieve isn't yet a fully crystallised thought. Then, with Vi, I feel boxed in and a bit blinkered.

It's just me, I know. Maybe the root of the problem is that I code before thinking. :)

So I still use TextMate, where I feel just a little more free and creative.

Anyway, this isn't a post about Vim vs TextMate (there's [enough of them](http://www.google.co.uk/search?q=vim+vs+textmate) already!), I just wanted to get that off my chest.

I seem to be going through a phase of setting up fresh installs of my various desktop and laptop computers again (blame Lion). Instead of blindly installing all the same tools as I'm used to, I figured I'd reassess the landscape and see what's out there. Here are a few plugins for TextMate I've tried, and liked.

* [PeepOpen](http://peepcode.com/products/peepopen) is a file finder from the lovely folks at [PeepCode](http://peepcode.com/). It replaces the default "Go to file..." (*⌘-T*) pane with one that's a good deal smarter. Instead of matching just on the filename, it'll match on the entire path. This is invaluable if your project has 300 files called `show.html.erb`. If I'm looking for, say, an article's show template in a Rails project, typing `avartsh` (**a**pp/**v**iews/**art**icles/**sh**ow.html.erb) will get me there quickly.

  PeepOpen is $12, but it's free as part of your PeepCode Unlimited subscription which you'd be crazy not to have anyway, right?

* [EGOTextMateFullScreen](https://github.com/enormego/EGOTextMateFullScreen) is a plugin that gives you native full screen support on Mac OS X Lion. On my desktop computer, a 27" iMac, I didn't really the point of full screen support (I much prefer a few windows tiled with the assistance of [Sizeup](http://irradiatedsoftware.com/sizeup/)). But then I got my hands on a Macbook Air and suddenly it made a whole lot more sense.

* If you're making use of the full screen support, then there's one small snag: the drawer isn't visible. I quite like the drawer; not to find files – because PeepOpen does a much better job – but to remind me of the context I'm in. When you're editing a file, and need a reminder of the context, hit *ctrl-⌘-R* and your current file will be highlighted in the project tree.

  So if, like me, you'd miss the drawer in full screen mode, the old standby is the [MissingDrawer](https://github.com/jezdez/textmate-missingdrawer) plugin. This turns the drawer into a sidebar, which is part of the main window and, therefore, still visible in full screen mode.

* Finally, project-wide search. The default Find in Project is a little ... slow. And a bit beachball-y. For a while I'd been using a bundle that replaces the default Find in Project with one powered by Ack. Much faster, and a little more flexible too. When I went searching for it this time around, though, I discovered [AckMate](https://github.com/protocool/AckMate), a plugin which provides a more integrated experience. It's fast. It can show you the context of the search result. It even allows you to constrain the results to particular file types. In short, it's awesome. Be sure to read the instructions on how to [set the shortcut key to the default "Find in Project..." one](https://github.com/protocool/AckMate/wiki/Usage).

There's one final plugin that I'm planning on evaluating, but haven't quite gotten around to yet. The one, single, feature I liked in my brief affair with [RubyMine](http://www.jetbrains.com/ruby/) was the ability to jump to a method definition. I've got a similar mechanism set up in Vim using [exuberant ctags](http://ctags.sourceforge.net/) which works really well. (And back in the days before Mac OS X when Emacs was my hammer – and every C file a thumb – I lived by my `TAGS` files.) How I'd love project-wide "Go to symbol...". There's a plugin out there called [TmCodeBrowser](http://www.cocoabits.com/TmCodeBrowser/) that appears to do exactly what I'm after. I'm slightly wary as it hasn't been updated in quite some time, but perhaps that's because it still just works. I'll evaluate it soon and update this post when I do.

There's one plugin I wish existed, but doesn't seem to: split windows. I've got plenty of screen real estate. It would be crazy awesome to be able to have my model and its tests sitting side by side with a vertical split. If it's possible to write a TextMate plugin that realises this, **I would happily pay $12 for it** (same price point as PeepOpen). Just so you know. ;-)

That's it. I still love TextMate and I spend several hours working in it most days. Thanks for making code editing a lovely experience, Allan!
