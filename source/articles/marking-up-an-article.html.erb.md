---
published_on: 2014-12-07
title: Marking up an Article
subtitle: Supplying metadata to keep the robots happy
excerpt: |
  Let's have a bit of a dive into the metadata associated with blog posts, and
  figure out how to produce the right information that all our social media
  tools (Google, Facebook, Twitter, etc) can consume.
category: Software development
tags:
  - microdata
  - opengraph
  - facebook
  - twitter
  - google
  - search
  - seo
---

One of the key advantages to HyperText Markup Language (HTML) -- the language
used to mark up the majority of the content you read on the web -- is that it
allows us to attach semantic meaning to the words we write. While this can
often be useful for formatting the content, it can also be used to extract that
meaning automatically from the words.

For example, if I structure an article so that it has a series of headings,
from `<h1>` for the main title, through to `<h6>` for a chapter's
sub-sub-section, then I could have a lump of JavaScript code which would
extract these headings and automatically generate a table of contents.[^1] With
[HTML5][] we have an even richer vocabulary to give semantic meaning to our
words, so with HTML tags, we can mark up things like articles, sections, header
groups, figures, and captions. The more meaning we specify about our words, the
more that computers can automatically interpret that meaning and provide a
richer experience around those words. HTML 5 is, as of October 2014, now the
recommended version of HTML for use on the web. (At last!)

In addition to marking up the content itself, we can also provide additional
metadata to help computers get the right information about the article. For
example, if somebody posts a link to Facebook, it's helpful to show the title,
a short description and, perhaps, an associated image for that link. Providing
this information to Facebook (and similarly for Twitter) provides a richer
experience for everyone. If your article shows up in Google's search results,
it's good for Google to be able to show details on the article that are going
to help the user decide whether it answers their search query.

There are a few tools we can use to provide this metadata. Unfortunately, while
most of these tools all do the same sort of thing, they all do it in different
ways, so we need to duplicate content to make sure everyone gets what they need. For the rest of this article, I'll be focusing on four key topics and, in particular, focus on their use in generating meta data for a blog-style article:

* Standard, basic, metadata.

* Facebook's [OpenGraph Protocol](http://ogp.me) metadata.

* [Twitter Cards](https://dev.twitter.com/cards/overview).

* [HTML5 Microdata][], used by Google.

Let's have a bit of sample data to work from. The previous article I wrote, on the [HYPER key](/articles/hyperpower/) has the following set of meta data that I've specified in the article source:

```yaml
title: HYPERPOWER!
subtitle: Putting the caps lock key to work
excerpt: |
  Today, we'll figure out how to replace the caps lock key
  with the (far more useful) HYPER key on Mac OS X, and
  have a think about the ways we can put it to use.
category: Internet
tags:
  - hyper
  - capslock
  - Alfred
  - Seil
  - Karabiner
```

So, we've got an article title, a short description of the content, a main
category, and a list of tags associated with the article. That, combined with a
little standard information about your intrepid author, should be enough to
provide Facebook, Twitter, and Google with some appropriate meta data.

## Basic Metadata

Since forever, HTML has had a couple of properties that you can set in the
`<head>` of the document to specify some additional metadata. They're so often
abused that it's common knowledge they're ignored by most machines, but since
we're not going to abuse them, there's no harm in making proper use of them.
First, the title tag (which is used to display the title of the page in your
browser, and is often displayed in search results):

```html
<title>HYPERPOWER! | Notes from a Messy Desk</title>
```

Since the title shows up in a few places, it's common to stick the web site's
title in there too. Many views truncate the title, so it's a good idea to make
sure the article title is first. Then we have a couple of meta tags with the
description and the tags:

```html
<meta name="keywords" content="hyper capslock Alfred Seil Karabiner">
<meta name="description" content="Today, we'll figure out how to...">
```

(I'll shorten the description from now on, since it gets repeated a few times.
You get the idea, I'm sure.) It seems common to specify the article author, and the copyright owner, so we'll do that, too:

```html
<meta name="author" content="Graeme Mathieson"/>
<meta name="copyright" content="Graeme Mathieson"/>
```

Finally, we'll specify the canonical URL for the article, which is the One True Resource Location people should link to when they're sharing your article.

```html
<link rel="canonical" href="https://woss.name/articles/hyperpower/">
```

This is useful if, say, for example, you have individual pages for each
article, but you also display the latest article on the home page of your site.
Now, search engines will know where the page *really* lives, in addition to the
current location they've discovered. This sort of thing is useful if your
article is syndicated to other sites, too.

That's about it for the basic metadata.

## Facebook OpenGraph

Facebook has its own protocol for specifying metadata about an article, called
the [Open Graph Protocol](http://ogp.me). The protocol is open, and intended to
be used by others, but Facebook seems to be the main consumer. It's based upon
<abbr title="Resource Description Framework in attributes">RDFa</abbr> which,
roughly translated, means sticking additional `<meta>` tags in the header of
your HTML file. It allows you to specify the type of object you're showing, and
additional metadata about that object. The end result is that your article will
show up on Facebook with more detail than an 'ordinary' link. So, what can you specify to help Facebook out?

* an article title, similar to the `<title>` tag above;

* the article description, which would typically be the same as the meta
  description tag above;

* the canonical URL, which is probably the same as the canonical URL specified
  above;

* the main 'section' under which the article was published, and a set of keywords (tags) associated with it;

* when the article was last published & revised; and

* an image associated with the article.

In my particular case, I'm just using a standard image (one of my delightful
visage) for every article, and I'm pulling it from [Gravatar][]. This gives me the OpenGraph metadata for our article:

```html
<meta property="og:title" content="HYPERPOWER!">
<meta property="og:updated_time" content="2014-11-28T00:00:00+00:00">
<meta property="og:description" content="Today, we’ll figure out how to...">
<meta property="og:type" content="article">
<meta property="og:image" content="http://www.gravatar.com/avatar/e9ed0907ebed6ba7ac45c3243261b86d.png">
<meta property="og:image:type" content="image/png">
<meta property="og:image:width" content="80">
<meta property="og:image:height" content="80">
<meta property="og:url" content="https://woss.name/articles/hyperpower/">
<meta property="og:locale" content="en_GB">
<meta property="og:site_name" content="Notes from a Messy Desk">
<meta property="article:author" content="https://woss.name/">
<meta property="article:section" content="Ops">
<meta property="article:tag" content="hyper">
<meta property="article:tag" content="capslock">
<meta property="article:tag" content="Alfred">
<meta property="article:tag" content="Seil">
<meta property="article:tag" content="Karabiner">
<meta property="article:published_time" content="2014-11-28T00:00:00+00:00">
```

It's quite a mouthful, and much of it is repeated from previous metadata
already supplied. However, bandwidth is cheap (well, if you're Facebook), and
taking the effort to conform to their protocol means that you're explicitly
opting in to having the details parsed and used in the way they do so.

## Twitter Cards

[Twitter Cards](https://dev.twitter.com/cards/overview) are very similar to
Facebook's OpenGraph protocol. (One might wonder why they didn't just adopt a
common protocol, but I'm sure that, while they both saw the need for such a
protocol to exist, neither knew the other was working on it. That's a kind way
of looking at why multiple things exist that solve the same problem.) In the
case of my articles, I'm looking to supply a title, a description, the creator,
and an associated image. Here's how it looks:

```html
<meta name="twitter:title" content="HYPERPOWER!">
<meta name="twitter:description" content="Today, we’ll figure out how to...">
<meta name="twitter:card" content="summary">
<meta name="twitter:site" content="@mathie">
<meta name="twitter:creator" content="@mathie">
<meta name="twitter:domain" content="woss.name">
<meta name="twitter:image:src" content="http://www.gravatar.com/avatar/e9ed0907ebed6ba7ac45c3243261b86d.png">
```

At this point, you're beginning to realise what your Content Management System,
whether it's Wordpress, or Joomla, or Jekyll, is really doing for you. You get
to specify all this crazy metadata once, and it generates all the correct forms
for you, so you don't have to copy and paste titles into half a dozen different
meta tags!

## HTML5 Microdata

At last, we're onto something a little different. Instead of adding duplicate
metadata to the header of our HTML article, [HTML5 Microdata][] marks up bits
of the content of the article itself as being interesting. It does this by
using additional attributes on particular tags to indicate that the content
inside those tags (or other attributes on the tag) are useful metadata. In
particular, it allows us to identify:

* the author, creator, and copyright holder of the article;

* when the article was published or updated;

* the title and body of the article; and

* any breadcrumbs that lead the user in to the article.

This micro data is all about marking up our existing HTML elements with some extra information to allow an automated system to infer meaning from them. So, how does it look with our sample article? Well, first, here are the breadcrumbs that I've marked up as leading to the article. I've figured that the user is primarily interested in the category an article is posted in, so:

```html
<ol class="breadcrumb">
  <li itemscope itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/" itemprop="url"><span itemprop="title">Home</span></a></li>
  <li itemscope itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/articles/" itemprop="url"><span itemprop="title">All Articles</span></a></li>
  <li itemscope itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/categories/ops/" itemprop="url"><span itemprop="title">ops</span></a></li>
  <li itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="active"><span itemprop="title">HYPERPOWER!</span></li>
</ol>
```

For each of these breadcrumbs, we're specifying:

* The title of the breadcrumb, with `<span itemprop="title">`; and

* the URL that the breadcrumb points to, by adding the `itemprop="url"` attribute to the anchor tag.

We introduce the information that we're talking about a blog post in the first place -- which all the remaining attributes are part of -- with the following:

```html
<article itemprop="blogPost" itemscope itemtype="http://schema.org/BlogPosting">
```

Anything inside this article tag, with more specific item scope, will be part of the blog post. So, how do we specify the title? Easy:

```html
<span itemprop="name headline">HYPERPOWER!</span>
```

It's worth noting that these `itemscope`, `itemtype`, and `itemprop` attributes
can be added to any of your existing HTML markup, so you don't need to modify
the structure of your page in order to apply meaning to it. In my particular
case, the headline isn't in a `<span>` tag, it's really in an anchor tag, which
happens to link to the canonical location of the article. We can specify when the article was published, with the HTML5 `<time>` tag:

```html
<time datetime="2014-11-28T00:00:00+00:00" itemprop="dateModified datePublished">on 28 Nov 2014</time>.
```

This tag is a particularly useful one. It provides a timestamp that a computer
can understand, and it provides something human readable, too. In my case, I
have a bit of JavaScript that interprets the machine-readable version, and
changes the human readable one into a meaningful expression of how long ago the
article was published -- in this case, a couple of weeks ago.

We can specify the author of the post with:

```html
<span itemprop="author creator copyrightHolder" itemscope itemtype="http://schema.org/Person">
  <a href="https://plus.google.com/u/0/100653048199781266668" rel="publisher" itemprop="url">
    <span itemprop="name">
      <span itemprop="givenName">Graeme</span>
      <span itemprop="familyName">Mathieson</span>
    </span>
  </a>.
</span>
```

This is quite detailed. It's specifying that the author, creator and copyright
holder are all the same (me). It's associating the author with his Google+
account (which Google are want to do), and it's specifying what my first and
last name are. All in all, there's detailed, machine-readable, information
about the author of the post. Finally, we can specify the article body itself:

```html
<div id="article-body" itemprop="text description articleBody">
```

so that any machine parsers can differentiate between the article itself, and
all the surrounding paraphernalia like headers, footers, social share buttons,
and the like.

## An Example

This web site happens to implement all the metadata mentioned above. If you're
looking for an example of what to implement, you could check out the page
source. If you're familiar with [Jekyll](http://jekyllrb.com/) or
[Liquid Templates](http://liquidmarkup.org) in general, you can check out the
source at [mathie/mathie.github.io](https:/github.com/mathie/mathie.github.io/).

## Conclusion

Well, that's about it, really. The point of the article was to demonstrate all
the additional metadata you can supply in order to help the Robots of the
Internet to understand what you're trying to say. After all, if your post turns
up as a Twitter Card, or as a rich snippet on Facebook, it's more likely that
people are going to read it. And that's the point of writing stuff on the
Internet, right? Writing stuff to help other people learn. And we're more
likely to understand that we want to learn something if there's a little more
meta data shown to us about the link our friends have just shared.

I've deliberately not used the phrase so far, but this is really what Search
Engine Optimisation (SEO) is really all about. It's not about customising your
tags and keywords to maximise the number of Google hits. It's, mostly, about
providing good content. But it doesn't hurt to mark up that high quality
content so that computers can understand, interpret, and express it, too.

[^1]: Speaking of which, I would love to automatically generate a table of
      contents for articles on this site, which would stay on screen at the left
      side, highlighting the current selection in some way. I'm sure it can be
      done with Twitter Bootstrap's affix plugin, plus a bit of JS to extract
      the headings, but I've never figured it out. Can you help?

[HTML5]: http://www.w3.org/TR/html5/ "A vocabulary and associated APIs for HTML and XHTML"
[HTML5 Microdata]: https://support.google.com/webmasters/answer/176035?hl=en