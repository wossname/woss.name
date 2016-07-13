---
published_on: 2006-11-20
title: OMG! EXTREME CRITICAL EMERGENCY!! EVERYTHING'S BROKEN! People are DYING!

category: Internet
tags:
  - dreamhost
  - dns
  - email
  - gmail
---
So my email isn't working this morning.  Somehow the MX record for `woss.name` has, well, disappeared.  Maybe [DreamHost](http://www.dreamhost.com/) got offended that I switched to [GMail](http://mail.google.com/) and decided to get their revenge.  Maybe I buggered something up (I was doing stuff in the DH control panel yesterday afternoon, but I don't *think* I touched `woss.name`).  Or maybe the gremlins got to it.

Nevertheless I've reinstated the record through the web panel about half an hour ago, though it's still not showing up in reality.  This means my personal email is all bouncing with 'relay denied' because after failing to find an MX record, one falls back to the A record, which is one of DH's web servers and doesn't relay mail.

Looks like, if you want to contact me today, best try <mathie@rubaidh.com> or IM instead...

**Update** It looks very much like something is buggered at DH.  I last received an email to my `woss.name` address at about 07:00 this morning (those irritating cron messages do have a use after all!), which means the first definite failure was 08:00.  DH's MX records are set with a TTL of 14400 seconds (4 hours), which suggests something happened to the MX record sometime between 04:00 and 08:00 GMT.  Trust me, I was asleep then. :-)

Also, it looks very much like DH's back end systems are not actually updating their DNS servers.  The new MX record is showing up in their web panel but over an hour after I first made the change (I've subsequently added a couple of spurious DNS records since then to try and prod it along), [dnscheck](http://www.squish.net/dnscheck/) still shows:

> 33.3% of queries will end in failure at 66.33.206.206 (ns1.dreamhost.com) - no such record
>
> 33.3% of queries will end in failure at 66.201.54.66 (ns2.dreamhost.com) - no such record
>
> 33.3% of queries will end in failure at 66.33.216.216 (ns3.dreamhost.com) - no such record

which means it's failing to resolve the MX and resorting back to the A record.

Argh!

**Update 2**:  Well, it looks like nearly 5 hours later it's actually propagated to one of their three NS servers.  So you currently have about a 1 in 3 chance of me receiving your email.  So now you've got to ask yourself a question: "Do I feel lucky?" Well, do ya, punk?

*sigh* I think I need a service provider in the same time zone as me.
