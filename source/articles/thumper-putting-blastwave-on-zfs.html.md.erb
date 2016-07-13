---
published_on: 2007-05-25
title: "Thumper: Putting Blastwave on ZFS"

category: Internet
tags:
  - solaris
  - zfs
  - blastware
  - thumper
  - x4500
  - rbac
---

Since the root file system is a meagre 11GB, I figured I'd try and use my ZFS
pool for installing [Blastwave](http://www.blastwave.org/) which is a system
built on top of Solaris' own packaging mechanism with access to lots of extra
software that I can't live without. Like `sudo` for example, at least until I
figure out how the Solaris native RBAC mechanism works! So, I did something
along the lines of:

    zfs create zpool1/software
    zfs create zpool1/software/blastwave
    zfs set mountpoint=/opt/csw zpool1/software/blastwave
    pkgadd -d http://www.blastwave.org/pkg_get.pkg

But I noticed that, at installation time, I was getting errors:

    pkgadd: ERROR: unable to create package object </opt/csw/bin>.
        pathname does not exist
        pathname does not exist
        unable to fix attributes
    /opt/csw/bin

Looking at it now, in the cold light of morning, the answer might have been
obvious. However, it took me a while last night to figure it out. Eventually, I
compared the options the filesystems were mounted with, thinking that it might
be missing a `setuid`/`exec` flag and noticed that it was missing the `xattr`
flag. Hmm. "`xattr`" and "unable to fix attribtues" sound like they might be a
match, eh?

Digging around in the *ZFS Administration Guide* (I've got a PDF here, it's
page 19 if you're following along at home), it appears that the `xattr`
property on ZFS filesystems -- which enables extended attributes on a
per-filesystem basis -- was introduced in Nevada build 56 and doesn't appear to
be available in Solaris 10 U3. I am inferring from this information that ZFS in
Solaris 10 U3 doesn't actually support extended attributes.

Two questions I have at this stage:

* Am I correct in my inference?

* Does it matter, or can I just ignore those errors?

**Update** I've researched the matter more thoroughly and it turns out I'd
jumped to completely the wrong conclusion. Read the next round of investigation
at: [Thumper: Debugging and not jumping to conclusions](/articles/thumper-debugging-and-not-jumping-to-conclusions/).
