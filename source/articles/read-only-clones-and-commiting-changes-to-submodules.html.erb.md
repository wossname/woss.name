---
published_on: 2008-04-10
title: Read-only clones and committing changes to submodules
redirect_from: "/2008/04/10/read-only-clones-and-commiting-changes-to-submodules/"
category: Programming
tags:
  - git
  - submodules
  - ruby
  - rails
  - plugins
---
Hopefully this will be a shorter article, but I thought I'd get the tip into
Google before I forget it and have to Google for the answer. :-)

Imagine the situation. You're using Git submodules to manage your external
dependencies, for example Rails plugins. Since not everybody on the project
has push access to some of the plugins, naturally you're using the public
clone URL as the submodule URL for your project:

    mathie@tullibardine:books$ git submodule add git://github.com/rubaidh/timestamped_booleans vendor/plugins/timestamped_booleans
    Initialized empty Git repository in /Users/mathie/tmp/src/books/vendor/plugins/timestamped_booleans/.git/
    [ ... ]

While some of the rest of your team don't have push access to that particular
repository, you do. While you're working away, you happen to make a change to
the submodule and commit it locally. Being a good submodule user, you know you
*must* push those changes before you push the main repository, otherwise your
coworkers will be stuck with a repository that references a tree that doesn't
yet exist in a repository they have access to. This is git speak for "the end
of the world".

So, how do we push those changes out when we've pulled from the read-only view
of the repository? Well, we add another remote:

    mathie@tullibardine:books$ cd vendor/plugins/timestamped_booleans/
    mathie@tullibardine:timestamped_booleans$ git remote add writable git@github.com:rubaidh/timestamped_booleans.git
    mathie@tullibardine:timestamped_booleans$ git push writable master
    [ ... ]

Sorted. The changes are now committed for that submodule and we can happily
push our other changes to the main repository too.
