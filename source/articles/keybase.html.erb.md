---
published_on: 2014-12-30
title: "Keybase: A Web 2.0 of Trust"
excerpt: |
  A short introduction to public key cryptography, how the web of trust is
  formed, and what Keybase brings to the key signing party.
category: Internet
tags:
  - Keybase
  - PGP
  - GnuPG
  - keysigning
  - cryptography
  - security
---

Ever since [Tim Bray introduced me to Keybase][ongoing1], I've been waiting
patiently to get in on the beta. (OK, not so patiently.) At last, last week, my
invitation came through, and I've been messing around with it since.

So, what's it all about? Secure communication with people you trust. The secure
communication part isn't anything new. It's using public key cryptography --
specifically that provided by [GnuPG](https://www.gnupg.org) -- to:

* Allow you to encrypt a message you send to a third party so only they can
  decode (read) it; and

* sign a message that you send to a third party, so that they can verify it was
  really you that sent the message, and that the message they're reading hasn't
  been tampered with since it was signed.

This technology has been around for a good couple of decades now, and has
become easier to acquire since the US relaxed their attitude to cryptography
being a 'munition' and, therefore, subject to strict export regulations. Public
key cryptography is great. The implementations of it are fast enough for
general use, and it's generally understood to be secure 'enough'.

There are two components to public key cryptography:

* A **public** key, which you can share with the world. Anyone can know your
  public key. In fact, in order to verify the signature on something you've
  sent, or in order to send you something which is encrypted, the other person
  *needs* your public key.

* Your **private** key, which you must keep to yourself. This is a sequence of
  characters which uniquely identifies your authority to sign messages, and
  your ability to decode encrypted messages sent to you. Most software allows
  you to attach a password to the private key, giving you [two factor
  authentication][] (something you have -- the private key file -- along with
  something you know -- the password).

I'm comfortable that you know how to keep stuff private. You have a personal
laptop, FileVault protecting the contents of the hard disk, with encrypted
backups, have a password on your private key, and you don't leave your laptop
lying unlocked in public places. That's cool. You've got a safe place to store
that private key.

## Sharing Public Keys

But it leaves one key problem: how do you share your public key? And how do I
know that this public key, here, is really your key, not just somebody
pretending to be you? After all, the security of the whole system relies on me
having a public key that I trust really belongs to you.

Sharing public keys themselves is easy enough. There are many public key
servers which you can publish your key to, most of which (eventually)
synchronise with each other. From there, it's just a case of asking your
encryption software to download that key from the servers. In these examples,
I'll demonstrate with the GnuPG command line client, but the same principle
applies to most PGP implementations, including more friendly GUI tools. I can
tell you that my key id (a short, unique, identifier for every public key) is
`002DC29B`. You can now retrieve that key from the public key servers:

    $ gpg --recv-keys 002DC29B
    gpg: requesting key 002DC29B from hkps server hkps.pool.sks-keyservers.net
    gpg: key 002DC29B: "Graeme Mathieson <mathie@woss.name>" not changed
    gpg: Total number processed: 1
    gpg:              unchanged: 1

But how do you know that I'm really who I say I am? This whole article could be
an elaborate hoax from hackers in Estonia, who have commandeered my blog and
published this article, just to fool you into believing that this is really my
public key. If you're sending sensitive data, encrypted using this public key,
and it's not really me who owns the corresponding private key, the whole effort
has been in vain.

### Verifying Fingerprints

The traditional way to exchange public keys -- and therefore allow trustworthy,
secure, communication over the Internet -- is to meet in person. We'd meet up,
prove who we each were to the other's satisfaction (often with some
Government-issued photographic ID), and exchange bits of paper which had,
written or printed, a PGP fingerprint. This is a shorter, easier to verify (and
type!) representation of your PGP public key. For example, my public key's
fingerprint is:

    CF61 9DD5 6116 D3CD 4380 C1AE 8F7E 58DD 002D C29B

This hexadecimal string is enough to uniquely identify my public key, and to
verify that the key has not been tampered with. (Notice that the last two
blocks of the string correspond to the key id.) When you get back to your
computer, you can download my key from the public key server, as above, and
show its fingerprint:

    $ gpg --fingerprint 002DC29B
    pub   4096R/002DC29B 2012-07-20
          Key fingerprint = CF61 9DD5 6116 D3CD 4380  C1AE 8F7E 58DD 002D C29B
    uid       [ultimate] Graeme Mathieson <mathie@woss.name>
    uid       [ultimate] [jpeg image of size 9198]
    uid       [ultimate] Graeme Mathieson <mathie@rubaidh.com>
    uid       [ultimate] keybase.io/mathie <mathie@keybase.io>
    sub   4096R/4BDD1F4C 2012-07-20

If the fingerprint I handed you matches the fingerprint displayed, you can be
confident that the public key you've downloaded from the key servers really is
my key. If I'm confident that a particular key, and the identities on the key
(names, email addresses, sometimes a photograph), are correct, then I can
assert my confidence by "signing" the key, and publishing that signature back
to the public key servers.

### Verifying Identities

Once I've verified that I have the right public key by checking the
fingerprints, the next step is to verify that the identities on the key are
accurate. In the case of a photograph, this is easy enough to do, just by
viewing the image on the key. Does it match the person I just met? In the case
of email addresses, the easiest way to check is to send an email to each of the
addresses, encrypted using the public key we're verifying, including some
particular phrase. If the owner of the key responds with knowledge of the
phrase, then we have successfully confirmed they have control over both the key
and the email address.

Once we've verified the authenticity of the key itself, and of the identities
on it, all that remains is to sign the key. This indicates to our own
encryption software that we've successfully been through this process and don't
need to do so again. It also publishes to the world the assertion that I have
verified your identity.

## Web of Trust

That's all well and good if we can meet up in person to exchange public key
information in the first place. What if we can't? Is it still possible to
establish each other's public keys, and have a secure conversation? That's
where the web of trust comes in. In short, if I can't meet directly with you to
exchange keys, but we've each met with Bob, and exchanged keys with him, and I
trust Bob's protocol for signing keys, then I can be confident that the key Bob
asserts is yours, really is yours. This is where publishing the signatures back
to the key server comes in useful. If I can see Bob has signed your key, and I
trust Bob's verification process, then I can be confident that you really are
who you say you are.

The web can extend further than just one hop, so long as we trust all the
intermediate nodes in the graph to follow a rigorous verification process.
This, combined with [keysigning parties][] (where a large group of people,
often at user group meetings or conferences, get together to all exchange keys)
means a large network of people with whom we can securely communicate.

All these bits and pieces have been around for a long time. They're well
established protocols, have been battle tested, and I have confidence that
they're secure 'enough' for me (not only for secure communication, but for
software development[^1], and the distribution of software packages[^2]).

The trouble is that, despite all these systems having been around for a while,
they've never really reached mainstream acceptance. I suspect, if you've read
this far, you can see why: it's complicated. It relies on a number of "human"
protocols (as opposed to RFC-defined protocols that can be implemented entirely
by software), and careful verification. You kinda have to trust individuals to
follow the protocols correctly, and completely, in order to trust what they
assert.

### Levels of Trust

PGP does allow you to assign a 'level' of trust to each individual in your web
of trust -- that's where the output above says `[ultimate]` since I trust
myself completely! -- so you can reflect the likelihood of an overall path
between two people being trustworthy based on the trustworthiness of the
intermediate people. But it's still complex and, well, you'd have to *really*
want secure communication in order to go to all this trouble, and it's not like
most of us have anything to hide, right? (As I write this, I'm feeling slightly
unnerved, because I'm sitting in a Costa Coffee in Manchester Airport, where
two police officers are sitting across the room -- on their break, enjoying
espressos -- with their Heckler & Koch MP5s dangling at their sides. How sure
am I that *they* know I have nothing to hide?)

## assert(true)

The overall message, though, is that it's about assertions. And it's about
following the paths of those assertions so that you can make a single main
inference: the person I want to communicate with is the owner of this public
key.

## An Example

Let's follow through the protocol with a concrete example. I would like to send
a secure communication to my friend, [Mark Brown][]. We both use GnuPG to
communicate securely, and both already have established key pairs. However, I
haven't verified Mark's key id yet, so I cannot say for sure that the key
published on the public key servers really is the one he has control of.

### Meeting for a Pint

The first step is to meet with Mark. As is tradition with such things, we'll
retire to the Holyrood Tavern for a pint or two, and to exchange key
fingerprints. We've each brought our government-issued photographic ID (a
driving license in my case, and a passport in Mark's case). We've established
that the photograph on the ID is a good likeness, verified the name matches who
we expect, and had a laugh because, despite knowing each other for 20 years, we
didn't know each other's middle names! So now we've asserted that the person
who is handing us the key fingerprint really is the person we're trying to
communicate with. Mark tells me his fingerprint is:

    3F25 68AA C269 98F9 E813 A1C5 C3F4 36CA 30F5 D8EB

### Verifying the Fingerprint

The next step, back at home, on a (relatively) trusted Internet connection, is
to verify that the copy of the public key we have is the same as the one Mark
claims to have. Let's grab the key from the public key servers:

    $ gpg --recv-keys 30F5D8EB
    gpg: requesting key 30F5D8EB from hkps server hkps.pool.sks-keyservers.net
    gpg: key 30F5D8EB: "Mark Brown <broonie@sirena.org.uk>" not changed
    gpg: Total number processed: 1
    gpg:              unchanged: 1

Then display the fingerprint:

    > gpg --fingerprint 30F5D8EB
    pub   4096R/30F5D8EB 2011-10-21
          Key fingerprint = 3F25 68AA C269 98F9 E813  A1C5 C3F4 36CA 30F5 D8EB
    uid       [ unknown] Mark Brown <broonie@sirena.org.uk>
    uid       [ unknown] Mark Brown <broonie@debian.org>
    uid       [ unknown] Mark Brown <broonie@kernel.org>
    [ ... ]

It matches! Now we've successfully asserted that the public key we've got a
copy of matches the fingerprint that Mark gave me. From this, we can
confidently draw the inference that the public key I have is the one that
belongs to Mark.

### Verifying Identities

There's one further stage, and that's to assert Mark really has control over
all these email addresses (6 of them -- I elided some for brevity!). Let's send
him an encrypted message to each of these email addresses. For example:

    > gpg --encrypt --armor -r broonie@sirena.org.uk
    [ ... ]
    If you really own this key, reply with the password, "bob".

which spits out an encrypted message we can copy and paste into an email to
Mark. Strictly speaking, you should send a separate email, with a different
password, to each email address so you can indeed verify that Mark owns all of
them.

In the interests of brevity/clarity above, I elided some of the output from
GPG, but it's actually quite relevant. When you attempt to encrypt a message to
a recipient who is not yet in your web of trust, GPG will warn you, with:

    gpg: 4F7C301E: There is no assurance this key belongs to the named user

    pub  2048R/4F7C301E 2014-08-31 Mark Brown <broonie@sirena.org.uk>
     Primary key fingerprint: 3F25 68AA C269 98F9 E813  A1C5 C3F4 36CA 30F5 D8EB
          Subkey fingerprint: C119 C009 1F4F B17F DFE8  2A57 8824 E044 4F7C 301E

    It is NOT certain that the key belongs to the person named
    in the user ID.  If you *really* know what you are doing,
    you may answer the next question with yes.

    Use this key anyway? (y/N) y

That's what we're trying to achieve here, so this is the one and only situation
in which it's OK to ignore this warning!

So, we've sent Mark an email, and he's responded with the super secret password
to confirm that the email account really belongs to him. We've now asserted
that the person who controls the private key associated with this public key
also has control over the email address. By inference, we're pretty confident
that Mark Brown, the person we want to communicate securely with, really is the
owner of this key, and this email address.

### Signing the Key

Now that we're confident with this chain of assertions, it's time to commit to
it. Let's sign the key:

    > gpg --sign-key 30F5D8EB
    [ ... ]
    Really sign all user IDs? (y/N)

GPG will list all the identities on the key, and ask if you really want to sign
them all. If Mark has only acknowledged ownership of some of the email
addresses, then we'd only want to sign some of them but, in this case, he's
replied to all of them, so we're happy to sign them all. We can then publish
our assertion, so it becomes part of the public web of trust, with:

    > gpg --send-keys 30F5D8EB

Job done. Now we can confidently communicate securely with Mark. Not only that,
but anyone who has already signed my key, and who trusts my ability to verify
other peoples' identity, can also communicate securely with Mark. The chain of
assertions makes this possible.

This all sounds like a lot of hard work. It is. And that's the trouble: there
has to be some pay-off for all this hard work, so the way things are, you have
to really *want* secure communication to go to all this bother. There are tools
to make it a bit easier, but it's still a faff.

## Keybase

So, what does Keybase bring to the mix? It's all about assertions, but from a
slightly different perspective. The key assertion it allows you to make is that
the owner of a PGP public key is also the owner of:

* a particular Twitter account;

* a GitHub account;

* a domain name; and/or

* some random Bitcoin-related things I don't fully understand!

It does this by posting some PGP-signed content publicly on each of these
places. For example, I have a tweet with a message signed by my PGP key:

<blockquote class="twitter-tweet" lang="en">
  <p>
    Verifying myself: I am mathie on Keybase.io.
    yM6lUCOGe3AesUYQ8Vm7Y5_kmDTCWY3DfDpO /
    <a href="https://t.co/DaeiltlD1D">https://t.co/DaeiltlD1D</a>
  </p>
  &mdash; Graeme Mathieson (@mathie)
  <a href="https://twitter.com/mathie/status/546280993045618688">
    December 20, 2014
  </a>
</blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I have a Gist posted on GitHub with similar information:

{% gist mathie/5618f2ee53acacbcebd2 %}

And I've got a file hosted on this blog with the same PGP-signed information:
[keybase.txt](/keybase.txt). The latter two both have obvious PGP-signed blocks
of text, which we can save off and verify:

    > curl -s https://woss.name/keybase.txt | gpg
    gpg: Signature made Sat 20 Dec 12:34:08 2014 GMT using RSA key ID 002DC29B
    gpg: Good signature from "Graeme Mathieson <mathie@woss.name>" [ultimate]
    gpg:                 aka "Graeme Mathieson <mathie@rubaidh.com>" [ultimate]
    gpg:                 aka "[jpeg image of size 9198]" [ultimate]
    gpg:                 aka "keybase.io/mathie <mathie@keybase.io>" [ultimate]

I've elided the decoded, signed, body but it's another copy of the JSON hash
visible earlier in the file.

So that's what Keybase gives us: the ability to assert that the person who
controls a particular account (on Twitter, GitHub, Hacker News, Reddit, or a
personal domain name) is also the holder of a particular PGP key. This
effectively provides an alternative to the email verification step above in a
neat, publicly verifiable, way. Each time you interact with a new user on
Keybase (for example, sending an encrypted message), it will check each of
these assertions are still valid. It has on file, for example, that I've
tweeted the above message. When somebody tries to send a message to me, it will
verify that tweet still exists, ensuring the assertion is still valid. For
example, sending a message to Mark (aka broonie):

    > keybase encrypt -m 'Testing Keybase message sending' broonie
    info: ...checking identity proofs
    ✔ public key fingerprint: 3F25 68AA C269 98F9 E813 A1C5 C3F4 36CA 30F5 D8EB
    ✔ "broonie" on twitter: https://twitter.com/broonie/status/546630630059311104
    Is this the broonie you wanted? [y/N] y

It asserts that the public key I have locally matches the fingerprint Keybase
have stored. It also checks that the assertion published by broonie on Twitter
is still valid -- and displays the URL so I can check it myself, too. If I'm
happy that this really is the broonie I'd like to communicate with, I accept,
and it spits out a PGP-encrypted message that I can then paste into an email to
Mark.

### Tracking Users

Similar to the key signing stage above, we can short circuit this
trust-verification stage by tracking users. Instead of having to verify a
user's identity every time, we can track them once, which effectively signs
their keybase identity. Let's track Mark:

    > keybase track broonie
    info: ...checking identity proofs
    ✔ public key fingerprint: 3F25 68AA C269 98F9 E813 A1C5 C3F4 36CA 30F5 D8EB
    ✔ "broonie" on twitter: https://twitter.com/broonie/status/546630630059311104
    Is this the broonie you wanted? [y/N] y
    Permanently track this user, and write proof to server? [Y/n] y

    You need a passphrase to unlock the secret key for
    user: "Graeme Mathieson <mathie@woss.name>"
    4096-bit RSA key, ID 8F7E58DD002DC29B, created 2012-07-20

    info: ✔ Wrote tracking info to remote keybase.io server
    info: Success!

Now we can send him PGP-encrypted messages without verifying his assertions
every time. Win. Keybase makes it really easy to track people's identities with
their command line client. And it makes it really easy to send PGP-signed or
-encrypted messages to people.

Of course, "all" that Keybase has done is to allow us to assert that the owner
of a particular public key is also the owner of a set of Twitter, GitHub,
Hacker News and Reddit accounts. And a domain name. Is that set of assertions
enough to be confident in drawing the inference that we're securely
communicating with the person we want to?

It depends on the situation. Based on prior interactions on Twitter, I'm pretty
confident that Mark really is 'broonie' on Twitter. Similarly, based on
previous interaction with relativesanity on GitHub, I'm pretty confident he's
my friend, JB. And that might be good enough.

## Trade Offs

Security is all about trade-offs. Keybase has traded off some of the strict
verification procedures I've been accustomed to in PGP-land. But instead it's
introduced a new verification method which is much simpler to do, and might
just be 'good enough' for my needs. I'm still quite excited about Keybase, and
I'm interested to see where it's going to take secure personal communication.
If you'd like to track me on Keybase, I'm [mathie](https://keybase.io/mathie)
(as usual).

[ongoing1]: https://www.tbray.org/ongoing/When/201x/2014/03/19/Keybase
[two factor authentication]: /articles/two-factor-authentication/
[Mark Brown]: http://www.sirena.org.uk/
[keysigning parties]: http://cryptnet.net/fdp/crypto/keysigning_party/en/keysigning_party.html

[^1]: Git allows authors to PGP-sign tags in their source control system. This provides a verifiable way of saying that the author is confident the source code contains the code they intended. Since an individual commit is a function of all the preceding commits, signing a single one asserts the history of the entire tree.

[^2]: Most Linux distributions (both dpkg- and rpm-based distributions, at least) allow authors to PGP-sign their packages. That, combined with the complete web of trust (every Debian developer has their key signed by at least one other Debian developer, in order to develop this web of trust), means we can be confident that a software package really did come from that developer.
