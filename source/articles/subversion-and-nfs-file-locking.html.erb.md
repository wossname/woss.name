---
published_on: 2005-08-25
title: Subversion and NFS file locking
redirect_from: "/2005/08/25/subversion-and-nfs-file-locking/"
category: Ops
tags:
  - subversion
  - nfs
  - locking
  - c
  - berkeley-db
---
I should prefix this with a warning:  I know *next to nothing* about file locking and the implications of what I've just done.  However, it now appears to work, and I'm not *too* worried about simultaneous access to my subversion repository since I'm the only one that uses it.  (Even the [web interface](/svn/) is currently running from a read-only mirror of the repository.)

Since [DreamHost](http://www.dreamhost.com/rewards.cgi?wossname) have upgraded my shell machine to Sarge, my subversion repository has stopped working.  Which is not entirely unexpected, since one of the libraries the `svn` binary dynamically linked to (`libgdbm`) had shifted its SO_NAME from 1 to 3 in the upgrade.  OK, so a rebuild was done and the binaries were working.  Except for one major problem:

```bash
mathie@Tandoori:mathie$ svn up
svn: Error opening db lockfile
svn: Can't get shared lock on file '/home/mathie/svnroot/locks/db.lock': No locks available
```

It couldn't successfully lock the repository.  Now my subversion repository uses the fs_fs backend (rather than Berkeley DB), and it's on an NFS mount.  It would appear that file locking isn't working over NFS in this particular situation.  Looking at `apr/file_io/unix/flock.c`, I see there's code to use either `fcntl()` or `flock()` to do the locking, but given the choice, it'll use `fcntl()`.  So I tried out a wee test: [readlock.c](/wp-content/readlock.c)  This attempts to create a read lock on a file using both methods.  Both methods work fine on a local filesystem with my laptop (Mac OS X 10.4) and on the shell server (Debian GNU/Linux 3.1).  However the `fcntl()` method fails on the latter machine when it's on an NFS mount.  `flock()` does work.  Yee ha.  Solution?  Edit `apr/include/arch/unix/apr_private.h` and comment out the line that reads:

```bash
#define HAVE_FCNTL_H 1
```

Rebuild apr with a `make clean && make && make install` and your copy of subversion now 'works' (as in doesn't fail in the obvious way!) on an NFS-mounted filesystem.

Your job is to tell me how much I risk screwing up my repository having made this change...
