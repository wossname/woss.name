---
published_on: 2014-09-10
title: Markdown Cheat Sheet
excerpt: |
  While I remember most of the Markdown syntax that's commonly available (after
  all, it's "just" like writing plain text email), there are some bits and
  pieces -- usually extensions to the language -- that I forget. This is my
  attempt to document them so I'll remember in future.
category: Writing
tags:
  - markdown
  - github flavoured markdown
  - kramdown
  - html
  - email
  - day one
---
While I remember most of the Markdown syntax that's commonly available (after
all, it's "just" like writing plain text email), there are some bits and pieces
-- usually extensions to the language -- that I forget. This is my attempt to
document them so I'll remember in future.

## Sources

Here are the canonical sources for Markdown documentation I've cribbed this
from:

* [Markdown](http://daringfireball.net/projects/markdown/) is the canonical
  source, particularly the [Markdown syntax](http://daringfireball.net/projects/markdown/syntax) page.

* Day One's [Markdown Guide](https://dayone.zendesk.com/hc/en-us/articles/200265094-Markdown-Guide)
  since it's quite often Day One I'm chucking writing into. Most often, I'll
  stick with the syntax it supports, only using extensions when the need
  arises.

* [GitHub flavoured Markdown](http://github.github.com/github-flavored-markdown/)
  which contains common extensions, plus some GitHub-specific hot sauce. It's
  most useful for writing in GitHub, but there are open source parsers which
  support (some of) the same extensions.

You can find the source to this post on GitHub:
[posts/2014-09-10-markdown-cheat-sheet.markdown](https://github.com/mathie/mathie.github.io/blob/master/\_posts/2014-09-10-markdown-cheat-sheet.markdown),
which shows off all the examples in their source form.

## Block-level elements

Block elements are those that affect the overall semantic structure of the
text. They're things like headers, paragraphs of text, lists, code blocks and
tables.

Except as otherwise noted, these Markdown elements are available in all
implementations of the Markdown processors I use.

### Paragraphs

Regular paragraphs of text are written as, well, regular paragraphs of text. A
paragraph is split by a blank line. Single line breaks are (normally —
GitHub-flavoured Markdown allows them to be treated differently) joined to a
single paragraph. This allows for flowing of text which has been broken into
multiple lines with hard line wraps at a standard width (e.g. 80 columns). So,
for example:

    This is the
    first paragraph.

    This is the second paragraph.

is turned into:

    <p>This is the first paragraph.</p>

    <p>This is the second paragraph.</p>

### Block quotes

Block quotes (primarily for quoting text from other people) are indicated by
prefacing each line with `> ` (that is, a greater than sign followed by a
space). Content inside the block quote is surrounded by HTML `<blockquote>`
tags, then interpreted as Markdown as usual. Block quotes can be nested, and
can contain any other Markdown, indented as usual. For example:

    > This is a block quoted paragraph.
    >
    > > This is a nested block quote.
    >
    > ## A header in a block quote
    >
    > Block quotes can contain *emphasised* text, inline `code`, lists, code blocks, etc.

It's no accident that block quotes look like quoted text in "traditional"
email. As for citations — attributing the original author of the block quote,
I've been having a wee play around, and this is what currently works best in
Day One:

    > The truth may be puzzling. It may take some work to grapple with. [ … ]
    > But our preferences do not determine what's true.

    <cite>— Carl Sagan, "[Wonder and Skepticism](http://www.example.com/)"</cite>

which looks like:

> The truth may be puzzling. It may take some work to grapple with. [ … ] But our preferences do not determine what's true.

<cite>— Carl Sagan, "[Wonder and Skepticism](http://www.example.com/)"</cite>


### Lists

Markdown supports both ordered and unordered lists, which can be arbitrarily
nested, and can contain other Markdown.

#### Unordered Lists

Unordered lists are represented by prefixing the list item with a `* `, `+ ` or
`- `. Personally, I prefer an asterisk, but that's mostly just out of habit.
So, for example:

    * This is the first item of a list.
    * This is the second item of a list.
      * This is a nested item in the second item of the list.
      * This is a second nested item.
        * Nesting can be done arbitrarily deeply.
      * This is a third nested item from the second item of the list.
    * This is the third item of the outer list.

If list items are not separated by a blank line, then they're treated as
"simple" list items, in that they're not surrounded by paragraph tags. So the
first list item above would be translated into: `<li>This is the first item of
a list.</li>`.

For more complex lists, it's more visually pleasing to separate them by blank
lines, as in:

    * This is the first item of a list. It's a bit longer than the previous
      idea, so it's a good idea to separate the list items with a blank line,
      which surrounds them with paragraph tags.

    * Of course, list items can contain *emphasised* text, `code blocks`,
      `[links][]` and other inline elements.

      Better still, list items can contain multiple paragraphs.

For second and subsequent paragraphs in a list, the new paragraph should be
indented by a couple of extra spaces. The simplest way to think of it is to use
a fixed-width font, and make sure the subsequent paragraphs line up with the
content of the first paragraph. It looks pretty that way, too.

#### Ordered Lists

Ordered lists follow exactly the same principles as unordered lists. The
difference is that they are identified by leading with `1. ` instead of `* `.
The actual numbers don't matter, just that they lead with a number. If you were
feeling particularly lazy, you could always do:

    1. This is the first list item.
    1. This is the second list item.
    1. This is the third list item.

but that wouldn't look so good in the source Markdown text. Each line item is
surrounded by `<li>` tags and the overall list is surrounded by `<ol>`, and
it's the CSS presentation that generates the numeric prefix on the list item.
The above would be translated into:

    <ol>
      <li>This is the first list item.</li>
      <li>This is the second list item.</li>
      <li>This is the third list item.</li>
    </ol>

### Headers

Headers are pretty straightforward: start a line with `#` marks equivalent to
the depth of the heading. Examples:

    # This is an <h1> header
    ## This is an <h2> header
    ### This is an <h3> header
    [ … ]
    ###### This is an <h6> header

It only goes up to six. Headings should be used to nest the content of an
article appropriately. Think of them as being an outline for the body of the
article. Extracted from the document, they should produce a sensible-looking
table of contents.

### Resorting to HTML

If there's something at the block level that you can't express in Markdown, or
that's easier to express that way, go ahead and do so. The only restriction is
that you must separate the HTML with blank lines either side. For example, if
you felt the need to write:

    <p style="display: none">A hidden paragraph.</p>

then it would be inserted directly into the HTML document. (This example
highlights one of the reasons you might want to insert HTML directly, since
Markdown doesn't support adding arbitrary attributes to the HTML elements it
supports — something that's generally accepted to be a good thing!

Anything inside an HTML tag is not processed any further by Markdown. So, for
example, `<p>A paragraph with a *starred* word.</p>` would be translated as-is;
the `*starred*` word would *not* be treated as Markdown emphasis and would not
be surrounded by `<em>` tags.

### Horizontal Rules

I never use 'em — it seems more like a presentation element to me — but I
suppose they have their uses. If you have a line with three or more dashes (or
asterisks) like `---` or `***` then they'll be translated into an `<hr/>`
element.

On that note, with autocorrect (or possibly TextExpander) enabled, it's a pain
in the derriere to insert sequences of dashes when you need them to stay as
sequences of dashes. Whatever I've got set up to do so will replace two dashes
— `--` — with an n-dash, and three dashes — `---` — with an m-dash. Normally,
this is awesome — I use n-dashes for subclauses with wild abandon because
that's how my brain speaks — but sometimes it's suboptimal. The only way I've
found to live with it so far is to watch for each time the sequence is
converted, then immediately hit `cmd-z` to undo. I ought to figure out a better
way…

### Code Blocks

The most portable way to do code blocks in Markdown is to indent the code by at
least four spaces (or one tab). For example:

    This is treated as a code block.

Inside a code block, leading space beyond the initial indent is preserved. So,
for example, if the first line is indented with four spaces, and the second
line is indented with six spaces, then the resulting code block will have the
first line with no indentation, and the second line indented two spaces. An
example:

    This is the first line indented by four spaces.
      This is the second line indented by six spaces.

Some Markdown implementations also support fenced code blocks, where code is
surrounded by three or more back ticks as a block element. For example:

    ```
    This is the code
    ```

For some reason I had it in my head that Day One didn't support this form of
code blocks, but it now appears to work, which is awesome. There are two key
advantages to using fenced code blocks:

* You don't need to indent every line, so it's much easier to copy and paste
  code snippets to/from other places; and

* There's a place to indicate the programming language of the code block,
  following the initial back ticks. This allows the code block to be processed
  with syntax highlighting to make code look pretty. Specify the programming
  language with:

      ``` ruby
      # Just testing
      def foo
        bar
      end
      ```

  which hints to the processor that it is Ruby code and will hopefully mark up
  the various keywords, strings, comments, etc, so they can be styled
  appropriately with CSS.

Code blocks are not further processed for Markdown markup, but HTML entities in
there are still escaped. So there's no need to monkey around with escaping
anything so that it correctly displays as HTML.

### Tables

Tables are an enhancement to the original Markdown specification, though they
are widely supported by Markdown Extra, GitHub-flavoured Markdown and Day One.
They take the form:

    Column 1 | Column 2
    ---------|---------
    Cell 1   | Cell 2
    Cell 3   | Cell 4

which turns into:

Column 1 | Column 2
---------|---------
Cell 1   | Cell 2
Cell 3   | Cell 4

With autocorrect automatically substituting sequences of dashes for em- and
n-dashes, it's a complete pain to enter the separator between the table headers
and the table body. Much like the rest of Markdown, tables look best in the
source text when you're using a fixed-width font. That way, all the columns
line up nicely.

The column headers are mandatory, at least in Day One.

GitHub enhances the table formatting to allow you to specify the alignment of
columns — and Day One supports it, too. The alignment is specified by using a
`:` in the separator row to indicate which side it's aligned to. For example:

    Left             | Centre           | Right            | Unaligned
    :----------------|:----------------:|-----------------:|----------
    Cell 1           | Cell 2           | Cell 3           | Cell 4
    Cell 10 (longer) | Cell 11 (longer) | (longer) Cell 12 | Cell 13

will produce:

Left             | Centre           | Right            | Unaligned
:----------------|:----------------:|-----------------:|----------
Cell 1           | Cell 2           | Cell 3           | Cell 4
Cell 10 (longer) | Cell 11 (longer) | (longer) Cell 12 | Cell 13

## Inline elements

There are a few inline elements for applying semantic meaning to regular text.
They are pretty much as you'd use in plain text email (which is kinda the point
of Markdown).

### Emphasis

Inline text can have simple styling applied to indicate emphasis in some way or
another. You can:

* emphasise text, by enclosing the text in single `*`s (also `_`s). For
  example, `*emphasised text*` will be rendered as "*emphasised text*". These
  forms are turned into `<em>` tags in HTML, which are typically rendered as
  italicised text.

* strongly emphasise text, by enclosing the text in pairs of `**`s (also
  `__`s). For example, `**strongly emphasised text**` will be rendered as
  "**strongly emphasised text**". These forms are turned into `<strong>` tags
  in HTML, which will typically be rendered in a bold font.

* strikethrough text, by enclosing the text in pairs of `~~`s. For example,
  `~~struck through text~~` will be rendered as "~~struck through text~~". This
  form is turned into the `<del>` tag in HTML, which will typically be rendered
  with a strike through it. (This is a GitHub extension, but also works in Day
  One.)

* indicate inline code, by enclosing the text in single `` ` ``s. For example,
  `` `some code` `` will be rendered as "`some code`". This form is surrounded
  by `<code>` tags. It's also a bit special, in that text inside the back ticks
  will not be processed as inline Markdown (so things like `*` and `_` — which
  are remarkably common in code! — aren't turned into emphasis and so don't
  need to be escaped). HTML entities will be escaped, though, so there's no
  need to monkey around with escaping `<` and `&` characters either.

### References

There are three similar forms of references: links, images, and footnotes. They
follow a similar format, and have similar variations.

#### Links

Links can be done in three different ways, each of which produce the same
output:

* A straight inline link: `[linked text](http://www.example.com/ "Link
  Title")`, which is translated into the anchor tag you'd expect in HTML: `<a
  href="http://www.example.com/" title="Link Title">linked text</a>`. The link
  title is optional and can be completely omitted, but if it's there, it must
  be quoted. This form is handy for one-off links, but it does somewhat disturb
  the flow of the text.

* An auto-linked URL: `<http://www.example.com/>` which turns into `<a
  href="http://www.example.com/">http://www.example.com</a>`. Handy if you want
  the URL directly in the source text.

* A reference-style link: `[linked text][link label]` in the source text.
  Somewhere else in the source text, there should be a definition of the link
  label, on a line by itself, of the form: `[link label]:
  http://www.example.com/ "Link Title"`. Some Markdown parsers (Day One, for
  example) are liberal in how you format the reference -- my personal
  preference was to have the URL in `<>` brackets, and to have the link title
  in `()` parentheses. [kramdown][] doesn't hold with that sort of thing,
  though, so no angle brackets and using quotes for the title seem the most
  portable option.

  Reference-style links also have a shortcut: `[link label][]` is equivalent to
  `[link label][link label]`. i.e. if the link text is the same as the label,
  you can leave the label empty. This, combined with the fact that labels are
  case insensitive, makes it easy to have low-overhead links to common things
  like `[Google][]`.

#### Footnotes

I love footnotes. It comes from reading too many Terry Pratchett
novels[^1][^2], I suspect. They are an extension, but they're available in Day
One. No sign of them working with GitHub flavoured Markdown, unfortunately.
With the [kramdown][] Markdown parser (used on this here blog), footnotes work,
but nested footnotes (ala Pratchett) don't[^3]. The syntax for referring to a
footnote is:

    This is pointing[^1] to a footnote.

And the footnote can be defined at the end of a section, or the end of the
document, as:

    [^1]: This is the footnote definition.

The footnote identifiers have to be numeric. They follow the same sort of
pattern/implementation detail as numbered lists, in that while the identifiers
have to be numbers — and, of course, have to match! — the numbers inserted into
the resulting document are in ascending numerical order as they are first
reference in the text. An example helps. The following footnote references:

    This is the first[^5], second[^3], and third[^19] footnote.

will (at least by Day One) be translated as if it were:

    This is the first[^1], second[^2], and third[^3] footnote.

This may confuse somebody referring to both the source text and the generated
HTML, so it is probably as well to make sure they do match when inserting new
footnotes in the middle of an existing document. Sadly, other footnote marks
(e.g. the most popular one in traditional text, `[^*]`) don't appear to work,
at least not in Day One, my reference implementation (since it's what I'm
writing this document in).

I've noticed in Day One, at least, that footnote definitions need to be
separate paragraphs — splitting with a single newline doesn't appear to
work[^4].

[kramdown]: http://kramdown.gettalong.org "A fast, pure-Ruby Markdown-superset converter"

[^1]: Sometimes the most fun part of the Discworld novels are the asides in the
      footnotes.

[^2]: Speaking of which, I should re-read some Discworld novels. @todo Look to
      see if there's a cheap place to buy all the early Discworld novels I
      already have paperback copies of.

[^3]: I should submit a GitHub issue to see what other people think...

[^4]: This might be a bug, or it might be a feature. Who knows? ;-)

#### Images

It's funny, I almost never use images in Markdown text. Perhaps it's a function
of me thinking in terms of plain text (in emails, Usenet News posts, etc), and
not really having images as part of the flow of that text (instead as an
attachment, or a URL reference to something elsewhere). Images are similar to
two of the link forms, except that they're prefixed with a `!`. (I think of it
as "insert here!" rather than "link to".)

* A straight inline image:
  `![alt text](http://www.example.com/image.png "Image Title")`, which is
  translated into the image tag you'd expect in HTML: `<img
  src="http://www.example.com/image.png" alt="alt text" title="Image Title">`.
  The image title is optional and can be completely omitted, but if it's there,
  it must be quoted. Unlike links, images do tend to be one-off within a
  document, but this form still does disturb the flow of the text a bit,
  particularly if the URL is long.

* A reference-style image: `![alt text][image label]` in the source text.
  Somewhere else in the source text, there should be a definition of the image
  label, on a line by itself, of the form: `[image label]:
  <http://www.example.com/> (Image Title)`. In principle, the URL doesn't need
  to be surrounded by `<>` and the image title can be surrounded by quotes
  instead, or omitted entirely, but I like them best that way. With the
  combination of both, it'll insert the image in the same way as the first
  example.

## GitHub enhancements

There are a few enhancements to Markdown that aren't widely implemented
elsewhere, or are totally GitHub-specific.

### Task Lists

Lists can be enhanced with ticky boxes, the state of which can be updated
without editing the markup directly. For example:

    * [ ] An unchecked list item.
    * [x] A checked list item.

These can be nested and ordered lists work, too. It would be awesome if Day One
supported these, too[^5].

[^5]: @todo I should submit a feature request!

### Auto-linking references

In addition to auto-linking URLs, GitHub will auto-link certain references:

* Individual commits can be linked from their SHA reference:
  `a5c3785ed8d6a35868bc169f07e40e889087fd2e`, optionally constrained to a
  particular user: `mathie@a5c3785ed8d6a35868bc169f07e40e889087fd2e` or to a
  particular repository:
  `mathie/mathie.github.io@@a5c3785ed8d6a35868bc169f07e40e889087fd2e`.

* Issues can also be referenced as `#42` (links to an issue in the current
  repository), constrained to a user: `mathie#42` or to an issue in a
  particular repository: `mathie/mathie.github.io#42`.

* Users and organisations are auto-linked using `@mathie`, for example. This
  has the side effect of subscribing that user — or all the users in that team
  — to the associated comment/issue if relevant.

### Emoji

Emoji icons are translated from name to their symbol. For example, `:smile:`
will be translated into a 😄  smiley.

