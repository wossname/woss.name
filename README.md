# Wossname Industries

Yet again, I'm contemplating doing something different with the Wossname
Industries web site -- instead of getting on and doing something useful on a
real project, I'm fiddling with the meta tasks. But I'm not particularly happy
with Middleman for a static site generator for the web site. I've wound up with
a lot of cruft to support what should essentially be a straightforward set of
pages, and it feels tricky to maintain.

And that's the problem right there: I now have a barrier to doing what it is I
actually want to do, which is just to write. Now it takes a minute to regenerate
the static site from the source material (largely because there are a lot of
redirects from old versions of the site, so I don't wind up with a mountain of
404s). I don't get syntax highlighting for the articles in my text editor
because I have to name the files `.html.md.erb` because I want them to be
ERB-processed too (I have some macros I want to use to shortcut generating links
and images and suchlike), and that has to happen *before* they get Markdown
processed.

But it's all getting in the way of just writing, and that's the end goal. Well,
that's not quite true. The end goal is to find something I can write about that
other people enjoy reading, and appreciate, and come back to read more. That's
what I really want to do: be appreciated for having written stuff.

I can't help feeling that Ruby on Rails (my usual hammer) can do all the stuff I
want to in order to generate a pile of more-or-less static content, and that it
can do it on demand, then cache the results and have that served up in future.
So I just have to figure out how to go from a nice writing environment to a
nicely formatted set of static pages.

So I wonder if I can go from a bunch of Markdown-formatted content (with the odd
ERB tag, perhaps, to shortcut some things) sitting somewhere in the `app` folder
(`app/assets/articles` perhaps?) to a Rails app serving up that content,
enriched by some other metadata elsewhere?
