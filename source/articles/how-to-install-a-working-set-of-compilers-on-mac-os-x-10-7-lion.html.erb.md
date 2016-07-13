---
published_on: 2012-01-24
title: How to install a working set of compilers on Mac OS X 10.7 (Lion)
excerpt: Xcode 4.2 removed GCC, which seems to be causing a bit of confusion. Here's
  a bit of background and a workaround 'til the dust settles.

category: Internet
tags:
  - mac os x
  - lion
  - compilers
  - gcc
  - xcode
  - clang
  - llvm
---
With the advent of Xcode 4.2, Apple have removed GCC from the Xcode installer. Up 'til now, when you installed Xcode (say, 4.1), you'd get:

* The original GNU Compiler Collection (GCC), version 4.2.1.

* LLVM-GCC, which is a modified version of GCC designed to emit LLVM's intermediate representation, so that it can hook into LLVM's back end optimisers and code generation (as I understand it).

* Clang, the shiny new compiler freshly built with LLVM goodness all the way through.

However, with Xcode 4.2 onwards, the original GCC variant has disappeared, and `/usr/bin/gcc` is now being served by the (mostly) compatible llvm-gcc.

This is only an issue if you freshly install Xcode 4.2 on a computer where the developer tools weren't previously installed. If you upgrade from Xcode 4.1 to 4.2, it will still leave gcc-4.2 lying around (suboptimal package management, but I'm not complaining today!). I suspect this is why more people aren't getting upset.

It's entirely understandable for Apple to stop distributing gcc: they're moving forward, innovating with LLVM, and there's only so long they should have to maintain a legacy (as far as their commercial platform is concerned, at least) compiler. In fact, llvm-gcc is only there as a temporary crutch; wait 'til they remove that too, leaving us with only Clang…

However, there's a slight snag: all compilers are not built alike. You'd think that compilers implement a standard correctly, and users of the compiler write code to that standard. It never quite works out that way, though: compilers have bugs and proprietary extensions. Worse still, coders write code until the compiler validates it, not necessarily 'til it's right.

So, flipping to a new compiler, even gcc -> llvm-gcc, will uncover problems. One of the apps I rely on that has been having problems is Ruby, which is why I wound up messing around with this in the first place.

So, what to do? There are a couple of newly popular mechanisms out there for installing a set of compilers on Mac OS X without installing the whole Xcode behemoth (largely as a way to save disk space):

* Soren Ionescu's [GCC Without Xcode](https://github.com/sorin-ionescu/gcc-without-xcode), which uses the Xcode installer you download from the App Store to generate a slimline installer with just the bits you need. Soren is careful to do it this way so as not to distribute any of Apple's binary packages on their behalf (something they, naturally, can get a little grumpy about). Unfortunately, this means it's using the Xcode 4.2 installer, which ... doesn't have GCC.

* Kenneth Reitz's [OSX GCC Installer](https://github.com/kennethreitz/osx-gcc-installer), which, in the project's download section, has a pre-built package, ready for installation. Here's the key thing: the pre-built package is built against Xcode 4.1, so still includes gcc-4.2.1. Hallelujah, we're saved. (Kenneth, please for the love of all things that compile, please don't update that package!)

So, when you've got a fresh Lion installation, and you're looking for something you can build the widest range of apps on (from things that *require* gcc all the way through to that shiny iOS 5 project you're working on), do the following:

* Grab the [OSX GCC Installer](https://github.com/kennethreitz/osx-gcc-installer/downloads) (as of writing, the 10.7-v2 package is the way forward).

* Run the package to install it.

* Grab Xcode from the App Store.

* (Prior to Xcode 4.3) Run the Xcode installer. (From Xcode 4.3 onwards, it's a regular app, ready to go in `/Applications`.)

* (If you're on Xcode 4.3+) start Xcode, go to Preferences, then to the Downloads section, then the Components tab. Choose to install the Command Line Tools.

Finally, you should be good to go. `/usr/bin/gcc` will still point to `llvm-gcc-4.2` but at least you'll have `gcc-4.2` installed. If you're having trouble compiling things, try forcing it to use gcc with `CC=gcc-4.2` or equivalent. I think the likes of Homebrew and RVM will try to be clever on your behalf if they can.

**Update** How about that? As of Xcode 4.3, `/usr/bin/cc` now points to clang for fresh installations. The above sequence of steps will still install a full set of compilers for you, though. If you need to force a build to use a particular compiler, use the `CC`, `CXX` etc environment variables and 99% of the time you should be good to go.

As of Xcode 4.3, you can skip the full Xcode installation and *just* install the [command line tools](https://developer.apple.com/downloads/index.action?=command%20line%20tools) (Developer Connection login required, but free). However, that just gives you `llvm-gcc` and `Clang`. **You still need the OSX GCC Installer if you want `gcc-4.2`.**
