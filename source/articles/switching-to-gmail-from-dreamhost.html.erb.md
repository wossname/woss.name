---
published_on: 2006-10-19
title: Switching to Gmail from DreamHost
redirect_from: "/2006/10/19/switching-to-gmail-from-dreamhost/"
category: Ops
tags:
  - gmail
  - email
  - dreamhost
  - imap
  - smtp
  - dns
  - google apps
---
I've been using DreamHost for a number of things over the past couple of years -- web sites (including this one), email, subversion hosting, that kind of thing.  But really, things have been going wrong too often, particularly with email:

* I've had incoming messages that I know are going missing, but only because of out-of-bounds communication with the people who are trying to send me mail.  There doesn't seem to be a particular pattern to this.

* I've had incoming messages, from a friend's Yahoo address, turn up over a week late because of an apparent misconfiguration in the spam filtering system.

* I'm still having outgoing messages bounced because they are [regularly listed in Spamcop](/2006/07/17/outgoing-mail-grumps/).  See the linked post for a more balanced discussion of that, but it still doesn't help me communicate with the people who's ISP uses Spamcop!

* The spam filtering has been going remarkably downhill, with me getting much more spam in my inbox.  This could be something to do with the copy of amavisd dating from June 2003, though I don't know if they update the rules system separately/more frequently.

Umm, oops.  This wasn't actually meant to be a rant about DH's mail service, more just an explanation that I wasn't jumping to Gmail because it was the next kewl thing; rather that I've been planning to move elsewhere for a while and chose GMail because it suited me best.

So, anyway, over the weekend I finally bit the bullet and switched my email to Gmail, using their [Google Apps for your Domain](https://www.google.com/a/) service.  I had expected to try and signup only to be told that it was still a limited beta and that I'd have to wait.  However, after filling in a brief survery, it took me to a page to setup the account.  Excellent!

The switchover was reasonably painless.  I set up the Google side of things, did the verification process to demonstrate that I had control over the domain (uploading a file to <https://woss.name/>) and things were working nicely.  They have a 'test domain' that you can use to push mail into your new account until you've set things up properly (it has already disappeared, so I guess it only hangs around until your MX record is set up).

Next up was to switch across my configuration at DH.  I configured my existing accounts at woss.name to forward to equivalent addresses at the test domain Google had set up for me.  I then also changed the MX record for woss.name to point to Google, as they described for me.  However, I selected the checkbox that said DH should still accept mail for my domain.  This meant that, while the new MX records were propagating, my email still worked with no downtime.  However, you probably want to remember to switch that off again after the MX records have propagated.

As for actually reading mail, I started by enabling POP on my GMail account and continuing to use Mail.app on my client.  That lasted until the first time I tried the web interface.  Neat.  It's actually *really* nice.  Particularly if you then follow the tutorial at lifehacker called [Hack Attack: Become a Gmail master](http://www.lifehacker.com/software/gmail/hack-attack-become-a-gmail-master-161399.php) including grabbing the various [Greasemonkey](http://greasemonkey.mozdev.org/) scripts to make working from the keyboard easy.

In order to transfer existing email from Mail.app, go to the message you want to relocate, then do shift-apple-e to redirect and send it to your own email address.  You have to do this one at a time, but I just used it to shift some of my existing inbox across so I could continue to deal with it in the Gmail web interface.

The downsides?  Well, I'm not convinced that it behaves well with my existing Google Account.  For example, I couldn't transfer across my existing calendar, which it wanted me to shift to a new email address (thus changing the email address on my existing Google Account).  I think there are some mild integration issues there.  But for the most part it seems to work OK.

The other downside for me is that I no longer have access to my email archive when I'm offline.  But perhaps that's more of an encouragement to me to start using a different method for archiving information -- say Yojimbo -- instead of relying on grepping my mail archive.

Final downside?  I don't think I've copied across all of the email I should have responded to.  I kinda cheated and did a cheap [Inbox Zero](http://www.43folders.com/2006/03/13/inbox-zero/)-style thing.  OK, OK, I basically assumed that anything more than a couple of weeks old was too embarrassing to get around to replying to.  So if you're kinda awaiting a long overdue email from me, perhaps you might want to resend it. :-)  (Uh, Mike, I'm thinking of you, for example...)
