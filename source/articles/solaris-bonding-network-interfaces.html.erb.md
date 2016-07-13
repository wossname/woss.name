---
published_on: 2007-06-09
title: "Solaris: Bonding network interfaces"

category: Internet
tags:
  - thumper
  - solaris
  - dladm
  - aggregation
  - networking
---
I've managed to find a new home for the Thumper.  The noise it's making is driving me absolutely batty, and I have to switch it off at night.  I'm also worried about it overheating as the weather starts to improve.  So I've managed to secure a deal with [Below Zero](http://belowzero.biz/), an ISP based in Edinburgh with an amazing world-class network.  We're going to shift it into the new place tomorrow, so I'm preparing by changing IP addresses before it moves.

So anyway, one of the things I'd been wanting to do was figure out how to bond two network interfaces to give me some resilience on the net connection.  Turns out it's pretty easy, though I did have one mental stumbling block, which we'll come to in a moment. The instructions here are correct for a server with at least two e1000 interfaces, where the first one was configured during the install as the network interface.  You'll also want to do this from the console, because the first thing we're going to do is take down the network interface:

    mathie@kilchoman:~$ pfexec ifconfig e1000g0 unplumb

Now let's use `dladm` to bond the two network interfaces together and bring the bonded interface back up:

    mathie@kilchoman:~$ pfexec dladm create-aggr -d e1000g0 -d e1000g1 1
    mathie@kilchoman:~$ pfexec ifconfig aggr1 plumb

Now we give it an IP address:

    mathie@kilchoman:~$ pfexec ifconfig aggr1 192.168.0.253 netmask 255.255.255.0 up

There's one last thing you'll want to do:

    mathie@kilchoman:~$ pfexec mv /etc/hostname.{e1000g0,aggr1}

Now here's the thing that confused me: that's it!  The information you give to `dladm` automatically persists and you've already associated the IP address with the interface by shifting `/etc/hostname.<interface>`.  You don't need to go putting the information in `/etc/network/interfaces` or some file in `/etc/sysconfig`.  That makes life a lot easier. :-)

**Update** I incorrectly said that the changes made with `ifconfig` automatically persist.  It turns out they don't, it uses a combination of `/etc/hostname.<interface>`, `/etc/hosts` and `/etc/inet/netmasks` to infer the IP address of the interface.  Thanks to [Dick Davies](http://number9.hellooperator.net/) for correcting me. :-)
