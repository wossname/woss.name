---
published_on: 2014-09-08
title: Personal Code Review

excerpt: |
  I have a micro work flow I use when I working with git, usually -- but not
  always -- while I'm developing software. Most git work flows talk about a
  larger scale, so I thought I'd share my own, personal, micro work flow.
category: Software development
tags:
  - workflow
  - git
  - branching
  - stories
  - merging
---
Git is a my distributed version control system of choice. I almost always pair
it with GitHub since, despite it centralising a distributed system, sometimes
the conversation around code is just as important as the code itself. (Now I
think about it, a distributed issue tracking system which stashes its data,
meta-data and history in an orphan branch would be pretty cool.) I've been a
user, and proponent, of Git, since [my friend Mark](http://www.sirena.org.uk)
did a talk on it at the [Scottish Ruby User Group](http://scotrug.org/), and
convinced us all it was better than Subversion.

Fundamentally, git (or any other version control system) gives us a couple of
useful features:

* The ability to keep track of changes over time. If we're a little careful
  about creating and describing those changes at the time (instead of a 3,000
  line change entitled, "New version") then we can make use of this information
  in the future to reconstruct the context in which a decision was made.

* The ability to share those changes with others.

That's about it, really. All the rest is just bells and whistles that allow us
to create larger work flows and processes.

I've seen many, and contributed to some, conversations on work flow using Git.
These tend to focus around the second point: sharing changes with others. It's
all about collaboration amongst team members, how to manage releases and how to
build larger features. Depending on the size of the team and the business
goals, it can be around parallelisation of effort, too.

The 'right' answer in these situations is certainly product specific. There are
work flows that suit versioned shrink-wrapped products. And if you have to
simultaneously support several shrink-wrapped versions, you're going to build a
more complex model for that, too. If you've got a web application that's
continuously delivered to production, and you only ever have one version in the
wild, you'll have a different work flow.

The right answer is often team- and culture-specific, too. And, for good
measure, the team's culture can (and probably should) change over time, too.
The work flows that work well for an open source project consisting of well
meaning, but externally constrained, volunteers might be very different from
the work flow required by the next big startup. And neither of those work flows
are necessarily going to work in a large corporation who is suffering under
rigorous compliance policies imposed upon them by HIPPA, PCI, ISO29001 or
Sabarnes-Oxley, for example.

## Sharing

These conversations often revolve around sharing changes with others. They talk
about branching (to work on larger features away from the main, stable,
production code), the length of time that branches should be allowed to survive
for, the maintenance overhead in branching and how, and when, to merge code.
They go beyond git, describing how to merge code, but selectively deploy it, or
selectively activate it (usually referred to as 'feature switches', allowing
the business to make a decision about enabling or disabling features, instead
of imposing it directly at a code level).

And these conversations are very interesting. They're important, too. But
they're not what I want to talk about today. What I want to describe is my low
level, deliberate, git work flow. It's the way of working that I, personally,
think enables these higher level work flows to happen smoothly.

## Atomicity

The key result of my git micro work flow is that I want each individual commit
to represent a single, atomic, change which makes sense in isolation. A branch,
turned into a patch (in traditional git workflow) or turned into a GitHub pull
request is a collection of these atomic commits that tell a single, larger,
cohesive story. The key thing is that neither commits, nor pull requests
(that's how I usually work) are a jumble of unrelated stories, all interwoven.

This is how I attempt to achieve that.

It's hard. I'm as scatter-brained as it comes. When I'm hacking on a bit of
code, I'll often spot something entirely unrelated that *needs* fixing. *Right
now*. If I'm being exceptionally well disciplined, I resist the urge, make a
note on my todo list (an 'internal' interruption in Pomodoro parlance) and
carry on with what I'm supposed to be doing.

## A Rabbit hole full of yaks

More often than not, though, I'm not that good. I'll get distracted by some yak
shaving exercise and spend the next hour working on it instead. Of course,
everybody knows that yak shaves are recursive, because they always take you to
another section of the code where you discover something you *need* to fix. A
recursive yak shave is collectively known as a 'rabbit hole'.

Hours later, we emerge. We've successfully dealt with all these crazy bald
yaks, and figured out how they fitted in a rabbit hole in the first place.
We've popped our stack all the way back to our original problem and solved it.
Win.

The trouble is that our working copy if now a complete shambles of unrelated
changes. That's OK, nobody cares about these things.

    git add .
    git commit -m "New version."
    git push

Time to head to the pub and regale our colleagues with tales of those
vanquished yaks!

Well, no, not quite. How is the poor sod that's been assigned to review my
change going to discern the two line change in logic to implement what I was
intended to do from the 3,000 line diff that 'refactors' all the junk I came
across on the way? When I come across a line of code in two years time and
wonder, "why did I make that change?", is the comment of 'New version' and a
bunch of unrelated code changes going to help me?

## Responsibility

No. I can't possibly lump this up into a single pull request, never mind a
single, atomic, commit. That would be irresponsible. But how do I get out of
this mess? It's perhaps telling that there are three git commands I use so
frequently that I've aliased them in my shell:

* `git diff` which I've aliased to the lovely, short, `gd`. This tells me the
  changes that I've made compared to what I've already staged for commit. When
  I just get started untangling this mess, these are all the changes I've made.

* `git diff --cached`, which I've aliased to `gdc`. I'm surprised this command
  is relatively difficult to 'get to' and really deserves an alias, because I
  use it all the time. These are the changes that I've staged for commit. This
  is essentially the work-in-progress of 'what I'm about to commit next'.

* `git add --patch`, which I've aliases to `gap`. This shows me each fragment
  of change I've made in turn (not just each file, but (approximately) each
  change within a file), asking me for each in turn, 'would you like to stage
  this fragment to commit next?'

The combination of these three commands -- along with `git commit` (which I've
aliased to `gc`) obviously -- and a bit of fiddling, allow me to turn my rabbit
warren of a working tree into those atomic, cohesive, commits that I desire.

## Patching

Let's take an (abstract) example. I've wound up with a working tree where I've
implemented two related things. They're both part of the current story that I'm
telling, but they're obviously discrete components of that story. And then
there's the rabbit hole. I noticed that one of the patterns we were using for
the `Controller#show` action was still living in Rails 2.3, and I've updated
all of them to the shiny new Rails 4 idioms. While I was doing that, I had to
tweak a few models to support the new Rails 4 idioms that the controllers now
rely on.

What a mess! We've got four sets of changes in the current working tree:

* The two atomic changes which are related to the current branch -- or plot
  arc, as I like to think of it.

* The two completely unrelated sets of changes, which are sweeping across the
  entire code base and, although minor conceptually, are a massive number of
  line changes.

Let's start with the two bits that are related to the current plot arc I'm
trying to tell? How do I extract them from each other, never mind from the rest
of the code? This is where `git add --patch` comes into its own. It's going to
show you each individual change you've made (not just the files, but the
individual changes in those files) allowing you to choose whether to stage that
change for commit or not.

## Staging

It's worth talking about staging at this point. Maybe I should have brought it
up earlier, but it's one of these things I take for granted now. The 'index'
(the place where changes are staged prior to commit) is a place for you to
compose a commit into a cohesive whole before committing it. This offers you
the opportunity to gradually add changes to the index, create a cohesive whole,
review it, then finally commit to that hand-crafted, artisanal change. It's the
difference between git and prior version control systems I've used (RCS, CVS,
Subversion) because it has a staging area between what you're working on, and
what you're committing.

When you're working through the hunks offered by `git add --patch` it's down to
making a semantic choice. What story do you want to tell next (following on
naturally from the previous story in this plot arc)? In some cases, it's easy
because there's a natural ordering. Pick the prerequisite first. Otherwise, I
tend to just accept the one that shows up first, then accept all the other
changes atomically associated with that hunk.

## Reviewing

When you've accepted all the hunks associated with that change, you can review
the proposed commit with `git diff --cached`. This is your chance to cast a
final eye over the change, make sure it's complete, makes sense in isolation,
and doesn't have unrelated changes. This is also your chance for a personal
code review:

* Does the code look correct?

* Are there unit/integration tests covering the changes you've made?

* Is it accurately, and completely, documented?

* Have you accidentally left in any debugging code from while you were
  implementing it?

* Does the code look pretty? Is there any trailing white space, or duplicate
  carriage returns, or missing carriage returns for that matter? Are things
  lined up nicely?

* Does the commit tell a good story?

This is the time to get inspiration for the commit message, too, which is a
fundamental part of the story you're telling, because it's the headline people
will see when they're reviewing these changes, and it's what they'll see when
they attempt to find out why this code exists in six months time. You've
already described *what* you've changed by, well, changing the code. We'll know
from the meta data surrounding the commit *who* changed it and *when*. The
*where* is, depending upon how you look at it, either irrelevant (I don't care
if you fixed it while you were sitting on the toilet, but I hope you washed
your hands afterwards) or supplied by the changes (you changed line 3 of
`foo.c`). The *how* you changed it is the subject of many editor wars, but is
largely irrelevant, too.

Now is the time to explain *why* you changed it, what problem you were solving
at the time (preferably with a reference to the context in which that change
was decided).

Now that I'm satisfied about what I'm committing, I commit that chunk. And then
I repeat this process of the other, related, changes that are part of this pull
request's plot arc.

## Unrelated Changes

But there's a complication. What about the other, unrelated, changes? They
don't have a place in this plot arc. Sometimes they're part of a plot arc of
their own, but more often than not, they're like the standalone 'filler'
episodes that TV writers bung in to fill up a season.

What shall we do with them? They're separate stories -- no matter how small --
so they deserve their own separate plot arcs, of course (whether you represent
plot arcs in git as patches or pull requests)!

If you're lucky, then you can create a new branch (new plot arc!) straight
away, with the current master (or whatever your root branch point currently
is), keeping your dirty working tree intact:

    git checkout -b shiny-refactoring master

then use `git add --patch`, `git diff --cached` and `git commit` to build up
and review atomic commits on the new branch for your shiny refactoring.

If your current working tree's changes will not cleanly apply to master, then
the easiest way to deal with it is to temporarily stash them, and pop them from
the stash afterwards.

    git stash save --include-untracked
    git checkout -b shiny-refactoring master
    git stash pop

You'll still need to resolve the conflicts yourself, though.

## Splitting Patches

When things get a bit more complicated, `git add --patch` still has your back.
When you've got an intertwined set of changes which are close to each other in
the source, but are semantically unrelated, it's a bit more effort to unpick
them into individual commits. There are two scenarios here.

If you have two unrelated changes in the same fragment, but they're only in the
same fragment because they share some context, then you can hit `s`. The
fragment will be split into smaller constituent fragments and you'll be asked
if you'd like to stage each one individually.

If the code is seriously intertwined, then you can ask git to fire up your
favourite editor with the patch fragment in question. You can then *edit* that
patch to the version you want to stage. If the patch is adding a line that you
don't want to add, delete that line from the patch. If the patch is removing a
line that you don't want removed, turn it into a context line (by turning the
leading `-` into a space). This can be a bit finickity, but when you need to do
it, it's awesome.

## Resistance

I've had a couple of people pushing back a little on this work flow (usually
when I'm in the driving seat while pairing) over the past few years.

The first was from a long-time eXtreme Programmer, who rightly pointed out,
"but doesn't that mean you're committing untested code?" Even if the entire
working tree has a passing test suite, the fragment that I'm staging for commit
might not. It's a fair point and one I occasionally have some angst over. If
I'm feeling that angst, then there is a workaround. At the point where I have a
set of changes staged and ready to commit, I can tweak the work flow to:

    git stash save --keep-index --include-untracked
    rake test # Or whatever your testing strategy is
    git commit
    git stash pop

This will stash away the changes that aren't staged for commit, then run my
full suite of tests, so I can be sure I've got a passing test suite for this
individual commit.

The other argument I hear is, "why bother?" Well, that's really the point of
this article. I think it's important to tell stories with my code: each commit
should tell an individual story, and each patch/pull-request should tell a
single (albeit larger) story, too.

(Not that I always listen to my own advice, of course.)
