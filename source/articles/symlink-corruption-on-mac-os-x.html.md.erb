---
published_on: 2012-01-29
title: Symlink corruption on Mac OS X

category: Internet
tags:
  - mac os x
  - lion
  - symlinks
  - corruption
  - imac
  - thunderbolt
  - promise
  - genius bar
---
Mac OS X on my desktop computer (a newish 27" iMac, using a Promise Thunderbolt disk array for the root filesystem) seems to be having filesystem troubles. I notice it through symlinks going awry, though I'm sure they're not the only victim. I tidied all the errant symlinks up two weeks ago, hoping it was a temporary glitch, but they're back again today. Here's an example:

    > find -L /System -type l -print0 |xargs -0 ls -l
    lrwxr-xr-x  1 root  wheel  24 15 Jan 09:42 /System/Library/Frameworks/ApplicationServices.framework/Frameworks/CoreGraphics.framework/Headers -> >File</string>????<key>L
    lrwxr-xr-x  1 root  wheel  24 15 Jan 09:42 /System/Library/Frameworks/ApplicationServices.framework/Frameworks/HIServices.framework/Headers -> ?6?s?A??]h?_?:d9?r?
    lrwxr-xr-x  1 root  wheel  24 15 Jan 09:42 /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/CoreGraphics.framework/Headers -> >File</string>????<key>L
    lrwxr-xr-x  1 root  wheel  24 15 Jan 09:42 /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Headers -> ?6?s?A??]h?_?:d9?r?
    lrwxr-xr-x  1 root  wheel  24 15 Jan 09:42 /System/Library/Frameworks/ApplicationServices.framework/Versions/Current/Frameworks/CoreGraphics.framework/Headers -> >File</string>????<key>L
    lrwxr-xr-x  1 root  wheel  24 15 Jan 09:42 /System/Library/Frameworks/ApplicationServices.framework/Versions/Current/Frameworks/HIServices.framework/Headers -> ?6?s?A??]h?_?:d9?r?

Each of those symlinks are pointing to some garbage. (Interestingly, the garbage quite often looks like the partial contents of a plist file.)

Here's another example, and this is one I *remember fixing* last time:


    lrwxr-xr-x  1 root  wheel  27 12 Nov 19:06 /System/Library/Frameworks/JavaVM.framework/Frameworks -> Versions/Current/Frameworks
    lrwxr-xr-x  1 root  wheel  24 15 Jan 09:43 /System/Library/Frameworks/JavaVM.framework/Headers -> Versions/Current/Headers
    lrwxr-xr-x  1 root  wheel  23 12 Nov 19:06 /System/Library/Frameworks/JavaVM.framework/JavaVM -> Versions/Current/JavaVM
    lrwxr-xr-x  1 root  wheel  26 15 Jan 09:45 /System/Library/Frameworks/JavaVM.framework/Resources -> Versions/Current/Resources
    lrwxr-xr-x  1 root  wheel   1  8 Jan 14:57 /System/Library/Frameworks/JavaVM.framework/Versions/Current -> c

The problem here isn't the first four symlinks – they're all pointing to the right places – but the last one (which they're all pointing through) which is pointing to 'c', not 'A' like it should.

The symlink targets all seem to be the right length, just the wrong characters.

How do I go about communicating with Apple about the problem so I can get it resolved? It doesn't really seem the sort of thing I can take to a Genius Bar...
