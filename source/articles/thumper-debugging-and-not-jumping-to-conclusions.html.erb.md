---
published_on: 2007-05-26
title: "Thumper: Debugging and not jumping to conclusions"

category: Internet
tags:
  - thumper
  - x4500
  - solaris
  - zfs
  - blastwave
---

In a previous post,
[Thumper: Putting Blastwave on ZFS](/articles/thumper-putting-blastwave-on-zfs/),
I quickly saw some information and jumped to completely the wrong conclusion.
In the comments, Boyd kindly pointed out that I should probably investigate it
a little more thoroughly. So I have. Just to recap, effectively I am trying to
install software, with `pkgadd` onto a ZFS filesystem. The full filesystem is
17 terabytes, and still has 17TB available. The steps I followed were:

    zfs create zpool1/software
    zfs create zpool1/software/blastwave
    zfs set mountpoint=/opt/csw zpool1/software/blastwave
    pkgadd -d http://www.blastwave.org/pkg_get.pkg

And the errors I was receiving were along the lines of:

    pkgadd: ERROR: unable to create package object </opt/csw/bin>.
        pathname does not exist
        pathname does not exist
        unable to fix attributes
    /opt/csw/bin

for pretty much every file/directory in the package. This resulted in `pkgadd`
noting that "`Installation of <cswpkgget> partially failed.`" As Boyd
suggested, I reran the failing scenario under truss:

    truss -Df -o pkgadd.truss pkgadd -d http://www.blastwave.org/pkg_get.pkg

so we're getting timestamps, following child processes and dumping that lovely
trace out to a file for later examination. Examining the output is fun, because
the errors appear to `write()` one character at a time, so grepping through the
file took a while. Still, here are (what I think are) the relevant calls before
the error message:

    910:     0.0001 lxstat(2, "/opt/csw/bin", 0xFEFAAF40)           Err#2 ENOENT
    910:     0.0001 lstat64("/opt/csw/bin", 0x080450D0)             Err#2 ENOENT
    910:     0.0002 mkdir("/opt/csw/bin", 0755)                     = 0
    910:     0.0001 xstat(2, "/opt/csw/bin", 0xFEFAAF40)            = 0
    910:     0.0001 door_info(8, 0x080430C0)                        = 0
    910:     0.0001 door_call(8, 0x080430F8)                        = 0
    910:     0.0001 statvfs("/opt/csw/bin", 0xFEFAAFC8)             Err#79 EOVERFLOW

So, what's happening here? Well, first of all the program is looking to see if
`/opt/csw/bin` exists. Since it determines that it doesn't (which is fine, not
an error), it creates the directory with `mkdir()`. The interesting bit is that
we're then calling `statvfs()` which returns file system information, and is
erroring on with `EOVERFLOW`. There, methinks, is the problem. So, what does
that error mean? According to the manual page:

> One of the values to be returned cannot be represented correctly in the
> structure pointed to by buf.

OK, interesting. A little googling finds a similar problem with `bootadm` in
[bug 6419989](http://bugs.opensolaris.org/bugdatabase/view_bug.do?bug_id=6419989)
on OpenSolaris. Jan succinctly describes the problem:

> The long and short of it is that if the amount of free space available in the
> root filesystem is greater than can be represented in the vfstat's f_bavail,
> the statvfs call will fail with EOVERFLOW. To fix this, bootadm must be
> compiled with -D_FILE_OFFSET_BITS=64 \[ ... \]

So it looks like `pkgadd` is suffering the same problem on Solaris 10 U3. To
try and verify that this was the problem, I tweaked the `/opt/csw` file system
so that the quota was somewhat less than 2TB (the maximum size of filesystem
that can be represented in 32 bits):

    zfs set quota=2g zpool1/software/blastwave
    pkgadd -d http://www.blastwave.org/pkg_get.pkg

which worked without error. Score! It looks from the bug tracker that there are
a number of applications with the same problem, but that folks testing out the
ZFS root file system support are quickly finding & reporting them. Question is,
do I need to report this one, or has it already been sorted? Since it's Solaris
10 U3 (rather than OpenSolaris), how do I go about correctly reporting issues?
