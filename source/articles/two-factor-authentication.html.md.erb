---
published_on: 2014-12-07
title: Two-Factor Authentication
exceprt: |
  Two-factor Authentication is a good thing. It increases the security of your
  accounts on the Internet, while not proving a major inconvenience. Here's a
  little bit of background, some options for apps that support it, and a plea
  to 1Password to support it natively!
category: Internet
tags:
  - passwords
  - authentication
  - two-factor
  - authy
  - duo
  - google
  - security
  - authorisation
  - banking
  - credit cards
  - chip and pin
  - yubikey
  - rsa
---

The Internet is full of Bad People Who Want To Steal Your Stuff. Well, no, not
really. The Internet is full of good people (so long as you don’t read the
comments), but it does give the bad people access to an unprecedented amount of
computing power, and a large audience with which to play. When you’ve got
enough computing power, and enough bandwidth, it’s no big deal to guess
somebody’s password by just trying out every possible combination (called a
"brute force" attack).

Of course, it’s good practice to have a secure password. You know, one with
capital letters, lowercase letters, numbers, and even a few symbols thrown in.
The kind of passwords where you have to have a particular kind of memory to
recall them. If you’re the kind of person who can recall every car number plate
they’ve ever owned, you probably already choose good passwords. On the other
hand, if you’re the kind of person who can’t remember the number plate of the
car they’ve been driving for the past five years, you might want to start using
it as your password — at least that way you’ll have one less thing to remember.

(Forget I said that. If somebody is targeting you, specifically, instead of the
Internet At Random, they’re going to try passwords related to you. Things like
variations on your car numberplate.)

## What is Authentication?

So what is authentication, anyway? It’s being able to demonstrate that you are
who you claim to be. For example, when I log in to my Google Mail account, with
the email address “mathie@woss.name” and the password, “Password1234”, I’m
authenticating myself as the individual entitled to access that email account.

The trouble is, especially now that I’ve told you my super-secret password,
passwords by themselves just aren’t secure enough. As we’ve discovered, a bunch
of clever hackers, with their hands on a frightening amount of computing power,
can easily guess a password if they really want to (and often they do it just
because there’s money to be made from having access to other people’s email
accounts).

What more can we do? There are three things we can offer when we’re trying to
authenticate ourselves:

* Something only you *know*. This would be the password from before.

* Something you *have*. This could be a credit card (the actual, physical, bit
  of plastic, complete with a built-in chip, not just the number printed on the
  front), a door key, some other physical token, or even just your mobile
  phone/computer.

* Something you *are*. This last one refers to biometrics: your fingerprint, a
  retina scan, a skin sample, or something even more invasive.

Each one of these can be compromised. Passwords can be guessed. Credit cards
can be lost or stolen. (I still haven’t replaced our “spare” car key after
losing it on the sleeper train to London last year!) Even biometrics can be
faked well enough to fool our current technologies for reading them.

## Two-Factor Authentication

But what if we were to combine a couple of these? Sure, a l33t h4x0r in Russia
coordinating a botnet of thousands of computers can brute force my password,
but it’s unlikely that he’ll steal my mobile phone, too. Some schemey ned might
mug me and steal my credit cards, but it’s unlikely he’ll stop long enough to
torture me into revealing my PIN, too.

That’s what two-factor authentication is all about. Since biometric sensors are
relatively expensive (though there are some things available to us mere
mortals, like Apple’s TouchID on the newer iPhones), the two factors are
usually something you have and something you know. Like a credit card and a
PIN. Or a key fob and a password. The key (pun intended) is that it’s two
separate factors. It’s not just two passwords (which you write on the same
Post-It note), or two door keys (which you keep them on the same keyring),
which aren’t much more secure than one.

Given that we understand two factors are better than one, how does that work in
practice? We need to enable "two-factor authentication" on all the web apps we
want to trust (at least those who implement it!). Most (UK, at least) banks
support this by supplying their customers with a Chip & PIN reader. This is a
small, battery-powered, device that can communicate with the chip on your
credit card. When you supply with Chip & PIN reader with a valid PIN for your
card (which combines something you have -- the card -- with something you know
-- the PIN) then it responds with a unique code which demonstrates your
possession of the card. This code is, helpfully, short enough that you can then
type it into a web form to confirm that you are who you claim to be.

Unless you're a credit card provider, though, it's difficult to justify the
cost of issuing unique cards -- which, if I recall correctly from University
days, run JVM byte code -- and card readers. On the plus side, there are a
couple of standard protocols that enable apps on disconnected devices to
generate codes that are suitable for two-factor authentication. The actual
details of these protocols are well beyond the scope of this article, but
suffice to say they're "good enough" to be trusted by security professionals.
Which is good enough for me. Mostly, they rely on a universal concept of the
current time (within a minute or so).

## Hardware Keys

So, armed with the knowledge that two-factor authentication is a good thing,
what are the options? There are a few hardware devices that you can buy, which
will generate a token you can use -- in addition to your password -- that
demonstrates you currently have that hardware device in your possession.
Devices like the [RSA SecurID][] work well here. There's a very clever device
called a [Yubikey][] which bypasses the need to type in the generated number:
it acts like a USB keyboard, so you just plug it into your laptop and hit its
button, and it "types" the code for you!

The disadvantage to these hardware devices is that you have to remember take
them with you. Most will attach to a keyring, so they're safe until you lose
your keys! In my particular case, I have to be honest, I've lost my house keys
far more frequently than I've lost my mobile phone, or my wallet. (Perhaps that
suggests something about the relative importance I attach to each of these
things!)

## Mobile Apps

Since my mobile phone is my prized, most carefully looked after, most available
possession, I wonder if we could use it to satisfy the "something we *have*"
requirement? It turns out yes, we can. There are two ways in which our phone
can help:

* We could receive a call, or SMS message to the phone with some code. This
  code, when typed back into the web service we're trying to access,
  demonstrates that we're in possession of the phone. The downside of this is
  that it requires a cellular signal. It's not always true to say that, when
  your laptop is connected to the Internet and you're trying to log in to
  PayPal (for instance), that you also have a mobile phone signal which enables
  you to receive SMS messages. (I've experienced this in practice, where I had
  limited WiFi access, but no mobile reception, in the basement of a hospital
  in Plymouth.)

* It can run an application which implements the necessary protocols to produce
  codes suitable for two-factor authentication. Since these protocols -- after
  initial setup -- only rely on a close approximation of the current time, they
  work fine even if the phone is disconnected from the Internet. Phones
  typically keep themselves close to the correct time when they're offline, and
  have mechanisms to synchronise with an accurate clock source whenever they're
  connected to the Internet.

There are a few apps available for the iPhone and Android:

* [Google Authenticator][] is the de facto app for doing two-factor
  authentication. It's available for the iPhone, Android, and Blackberry, and
  it's even an
  [open source project](https://github.com/google/google-authenticator) which
  would make you hope there have been enough eyeballs looking at the code to be
  confident it is secure. To be honest, I haven't used it in quite some time --
  last time I tried it out, they hadn't updated the interface to the new iPhone
  5, so it looked pretty ugly. Still, it works, and it supports all the
  standard protocols.

* [Duo Security](https://www.duosecurity.com) has been recommended to me by a
  friend, though I haven't actually tried it out yet. For web services that
  integrate with Duo, it has a beautifully simple variation on the online
  workflow. Instead of receiving a call, or a text message, with a code to
  enter in a web form, when you log in to a web service, it'll send you a push
  notification saying, "was that you?" If you answer "yes", the log in will
  succeed. That's quite elegant.

* [Authy](https://www.authy.com) is the one I've actually been using in anger
  for the past couple of years (ever since I lost my keyring with a hardware
  token attached). It supports two-factor authentication for all the popular
  services that have enabled it.

And Authy has a unique twist: you can back up your tokens to their cloud. This enables a couple of things:

* you can install the Authy app on multiple devices, and any one of those
  devices will be able to give you the authentication code you need; and

* if you upgrade your device (say you've just upgraded your iPhone to the shiny
  new iPhone 6+), then you can transfer your accounts across to the new device.

It's important to note that this is a trade-off. You're weakening the
"something I *have*" requirement for authentication. It's now down to something
you, or anyone with access to your Authy account, has. But the trade-off in
convenience might be worthwhile. As in all things, it's a trade-off between
absolute security and convenience. Enabling two-factor authentication, no
matter how you do it, increases security and reduces convenience. So maybe
Authy tweaking that trade-off a little isn't such a bad thing.

## Web Services

Thankfully, mostly down to services like Authy and Duo, it's become really easy for developers to incorporate two-factor authentication into their apps, so it's becoming a standard feature of popular web apps. Here's the list of web services I have two-factor authentication enabled on:

* [Google](https://www.google.com/). If you're a Google Apps user, then your
  administrator has to enable it -- and you should encourage her to do so --
  but you should definitely be using it for your personal Google account.

* [Amazon Web Services](https://aws.amazon.com/). This used to be the one place
  I thought was important enough that I used a hardware token. I'd be well
  pleased if they enabled two-factor authentication support for my general
  (consumer) Amazon account, too.

* [Evernote](https://www.evernote.com/), which has two-factor support built
  into all its apps.

* [GitHub](https://github.com/), where I store all the code I write.

* [Dropbox](https://www.dropbox.com/).

* [Microsoft](https://www.microsoft.com/). It's impressive how little I have
  call to use my Microsoft account, given their influence on the computing
  industry. Still, it's good to see they implement standard two-factor
  authentication.

* [Facebook](https://www.facebook.com/). In researching this article, it turns
  out I use a relatively weak password for Facebook, and one that I haven't
  changed in a while. I think it's testament to two-factor authentication that
  I haven't had my account hacked yet. (Or maybe I'm just not that important.)

If you're using any of these services, you can enable two-factor authentication today, using Authy or Google Authenticator. There are a couple of other services where I have two-factor authentication enabled but, irritatingly, they send messages to your phone to demonstrate that you have it:

* [Twitter](https://twitter.com/). This will send a code to the Twitter app on
  your phone, if you have it installed. But if you're using a third party
  Twitter client, then you have to rely on SMS messages getting through.

* [PayPal](https://www.paypal.com/) which insists on using SMS. I love that I
  can pay for Domino's Pizza with PayPal, but the number of times I've failed
  to acquire pizza because I have no SMS signal is ... uncountable.

## Conclusion

If you're going to take one thing away from this article, I really hope it's
this: two-factor authentication is a good thing, and you really want to start
using it. It's not *that* much hassle to get setup, but it adds a huge hurdle
to the Bad People Who Want To Steal Your Stuff, while not inconveniencing you
much. OK, so once in a while, you'll have to trek all the way through to the
bedroom, take your phone off charge, launch an app, and type in a code to get
that pizza ordered but, you'll sleep well that night knowing that nobody else
is ordering pizza with your PayPal account too.

There's one thing I really wish supported two-factor authentication. I use
[1Password](https://agilebits.com/onepassword) to store all of my passwords. It
enables me to have different, secure, passwords for every web service I use,
while still providing the convenience of a single master password that I have
to actually remember. It's also the place where I store the "backup" codes that
services provide, for if you've lost your two-factor authentication device. I
wish that 1Password -- both on the Mac and the iPhone -- had the facility to
generate two-factor authentication codes. In fact, with 1Password on the
iPhone, it would give me three-factor authentication:

* something I know: my master password;

* something I have: my mobile phone, with 1Password installed on it; and

* something I am: my fingerprint, verified with TouchID.

Given those three factors, it can produce two results:

* my password, which is a randomly generated string I don't even know; and

* a token which indicates I'm currently in possession of the hardware I claim
  to own.

What could better strike the balance between security and convenience?

[RSA SecurID]: http://www.emc.com/security/rsa-securid/rsa-securid-hardware-authenticators.htm
[Yubikey]: https://www.yubico.com/products/yubikey-hardware/
[Google Authenticator]: https://support.google.com/accounts/answer/1066447?hl=en