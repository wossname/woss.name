---
published_on: 2015-04-14
title: "Convincing Vim to accept ? and ! as part of keyword"
excerpt: |
  Last night I learned how to convince vim that `!` and `?` are part of a
  keyword. This is awesome, because both those characters are valid characters
  for method names in Ruby. In particular, it now means that when I hit
  `ctrl-]` with my cursor in a method name containing a `!`, it will take me
  to the correct method definition. Let's see how.
category: Software development
tags:
  - Ruby
  - Vim
---

Last night I learned how to convince vim that `!` and `?` are part of a
keyword. This is awesome, because both those characters are valid characters
for method names in Ruby. In particular, it now means that when I hit `ctrl-]`
with my cursor in a method name containing a `!`, it will take me to the
correct method definition. Let's take an example, with a couple of methods on
a `User` model:

```ruby
Class User
  def invite(message)
    InvitationMailer.invitation(message).deliver_later
    @invited = true
  end

  def invite!(message)
    invite(message)
    save!
  end
end
```

and elsewhere, I have some code in a controller:

```ruby
class UsersController < ApplicationController
  def invite
    @user.invite!(params[:message])
  end
end
```

With my cursor at the underscore on `@user.in_vite!`, I can hit `ctrl-]` and it
will take me to the method definition of the keyword under the cursor. Prior to
making last night's discovery, vim would have determined that the keyword was
`invite`, and it would have searched the ctags file for a match. Invariably, it
would have decided that the closest match was the one in the same file, so it
would take me to the method definition for the `invite` controller action —
just where I already was.

The first thing I wanted to double check was to see that ctags was correctly
storing the method names. In vim, you can jump directly to a tag definition
with the `:ta[g]` command. This will accept a string or a regular expression of
the tag we want to jump to. I tried jumping with `:tag invite!` and, sure
enough, it takes me to the right definition, so the tags are being generated
with the right method names, and vim is happy enough to accept them as
identifiers. That's not the problem then.

So, it would appear that the problem is with how vim determines the keyword
we're searching for based on the current cursor position. In other words, how
does vim take the line `@user.in_vite!(params[:message])` (with the cursor at
the `_`) and determine that the keyword we're looking to find the definition
for is `invite`? And how do we change it so that it picks up the correct
keyword, `invite!` instead?

At this point, I figured that what constitutes a keyword is probably
language-specific, so I went down a rabbit hole of digging through the Ruby
syntax file, seeing how it parsed and syntax highlighted various elements of a
Ruby source file. Wow, that's complex! However, it already correctly
understands that `?` and `!` are valid characters in a method name, so that led
me to believe vim wasn't using syntax information to figure out what
constitutes a keyword.

Eventually, I resorted to digging through the help files for the word ‘keyword'
and came across the option `iskeyword`. It transpires that this contains a list
of the ASCII characters that are considered to be part of a keyword. The
documentation here mentions that keywords are used in many commands, including
`ctrl-]`. It also hints that they can be changed per file type (e.g. help files
consider all non-blanks except for `*`, `"` & `|` to be part of a keyword). The
default list of characters is `@,48-57,_,192-255` which is:

* `@` is all the characters where `isalpha()` returns true, so it's `a-z`,
  `A-Z` and various accented characters.

* 48-57 are the ASCII digits `0-9`.

* `_` is the literal underscore character.

* 192-255 are the extended ASCII codes (accents, ASCII art symbols, that kind
  of thing).

So we can see that `!` and `?` are excluded from the list. I added them in to
my current vim session with:

    :set iskeyword=@,!,?,48-57,_,192-255

Then I tested it out by placing my cursor over `@user.invite!` and, sure
enough, `ctrl-]` took me to the method definition! I did a little Snoopy dance
at this point, but it was OK, because there was nobody else in the house. ;-)

It occurs to me that the definition of a keyword is language specific, so in
order to make the configuration permanent, I've added the following to my
`~/.vimrc`:

    autocmd FileType ruby set iskeyword=@,!,?,48-57,_,192-255

Restart vim to double check and yes, it's now considering `invite!` and
`password_required?` to be keywords. Winning!

Now that I've discovered the trick to tell vim what constitutes a keyword, I'm
wondering a couple of things. Firstly, are there any other characters that
should be part of a keyword in Ruby that aren't included in the new list? And
secondly, what other languages could do with their `iskeyword` being set to
something different?
