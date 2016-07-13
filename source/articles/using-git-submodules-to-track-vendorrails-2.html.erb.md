---
published_on: 2008-04-11
title: Using git submodules to track vendor/rails

category: Software development
tags:
  - git
  - submodules
  - ruby
  - rails
  - vendor
  - edge
  - stable
---
In a previous post, [Using git submodules to track plugins](/articles/using-git-submodules-to-track-vendorrails/)
I introduced the idea of using git submodules as part of your workflow in
developing Rails applications. At the time, Rails itself wasn't using git, but
that has finally happened. You can find the official Ruby on Rails source code
repository at <http://github.com/rails/rails>. So, how to we track Rails with
git submodules?

Let's start from our books application of the [previous post](/articles/using-git-submodules-to-track-vendorrails/).
And we'll add in the submodule for Rails:

    mathie@tullibardine:books$ git submodule add git://github.com/rails/rails.git vendor/rails
    Initialized empty Git repository in /Users/mathie/tmp/src/books/vendor/rails/.git/
    remote: Generating pack...
    remote: Done counting 67937 objects.
    remote: Deltifying 67937 objects...
    remote:  100% (67937/67937) done
    remote: Total 67937 (delta 52081), reused 67937 (delta 52081)
    Receiving objects: 100% (67937/67937), 9.88 MiB | 20 KiB/s, done.
    Resolving deltas: 100% (52081/52081), done.

and let's see what that's done:

    mathie@tullibardine:books$ git stat
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #	modified:   .gitmodules
    #	new file:   vendor/rails
    #
    mathie@tullibardine:books$ git diff --cached
    diff --git a/.gitmodules b/.gitmodules
    index 228959d..64ce630 100644
    --- a/.gitmodules
    +++ b/.gitmodules
    @@ -4,3 +4,6 @@
     [submodule "vendor/plugins/timestamped_booleans"]
            path = vendor/plugins/timestamped_booleans
            url = git://github.com/rubaidh/timestamped_booleans
    +[submodule "vendor/rails"]
    +       path = vendor/rails
    +       url = git://github.com/rails/rails.git
    diff --git a/vendor/rails b/vendor/rails
    new file mode 160000
    index 0000000..f46fd6f
    --- /dev/null
    +++ b/vendor/rails
    @@ -0,0 +1 @@
    +Subproject commit f46fd6f2fceb22f00669f066fc98f92a18e5875f

So we've successfully added in a new submodule for Rails, for the current
HEAD. Let's commit that and push it upstream:

    mathie@tullibardine:books$ git commit -m "Use git submodules to track HEAD of rails repository."
    Created commit 4bb82c9: Use git submodules to track HEAD of rails repository.
     2 files changed, 4 insertions(+), 0 deletions(-)
     create mode 160000 vendor/rails
    mathie@tullibardine:books$ git push
    [ ... ]

That's all well and good, but we don't always want to track edge Rails.
Sometimes we want to track the stable branch or pin ourselves to a particular
version. Let's first of all pin to version 2.0.2:

    mathie@tullibardine:books$ cd vendor/rails/
    mathie@tullibardine:rails$ git tag
    [ ... ]
    v2.0.2
    [ ... ]
    mathie@tullibardine:rails$ git co v2.0.2
    Note: moving to "v2.0.2" which isn't a local branch
    [ ... ]
    HEAD is now at c8da518... Tagged Rails 2.0.2
    mathie@tullibardine:rails$ cd ../..
    mathie@tullibardine:books$ git status
    # On branch master
    # Changed but not updated:
    #   (use "git add <file>..." to update what will be committed)
    #
    #	modified:   vendor/rails
    #
    no changes added to commit (use "git add" and/or "git commit -a")
    mathie@tullibardine:books$ git add vendor/rails
    mathie@tullibardine:books$ git commit -m "Pin ourselves to Rails v2.0.2."
    Created commit 5e66474: Pin ourselves to Rails v2.0.2.
     1 files changed, 1 insertions(+), 1 deletions(-)
    mathie@tullibardine:books$ git push
    [ ... ]

What we've done here is look at the Rails repository's list of tags to see
which one tags version 2.0.2. We find that it's called "v2.0.2" so we will
check out that particular tag. Since we're not making any changes, just
wanting to check out the tree at that particular state, we don't need to worry
that we're not on a branch. We then shift back up to our project root and do a
`git status`. This notes that we have made a change to `vendor/rails` in that
we're tracking a different commit id. Do a `git diff` and you'll see what I
mean. We're happy to add that to the index, commit and push it upstream. Now
everybody we're sharing with is also pinning their clone to Rails 2.0.2.

How about we want to track the stable branch instead?  Just as easy:

    mathie@tullibardine:books$ cd vendor/rails
    mathie@tullibardine:rails$ git co origin/2-0-stable
    Note: moving to "origin/2-0-stable" which isn't a local branch
    If you want to create a new branch from this checkout, you may do so
    (now or later) by using -b with the checkout command again. Example:
      git checkout -b <new_branch_name>
    HEAD is now at 2c96f50... Merge [9124] from trunk: Avoid remote_ip spoofing.

This time we're just checking out a copy of the remote branch
`origin/2-0-stable`. The rest is exactly the same as before -- add the fact
that you're tracking a different commit to the index of your main project,
commit it and push. Every time you want to update to the latest version of the
2-0-stable branch (just like when you did `piston update`), you repeat this
process.
