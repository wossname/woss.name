---
published_on: 2014-11-18
title: Front End Development 101
subtitle: "Part 1: Goals, Go, Node and Bower"
category: Software development
tags:
  - JavaScript
  - Less
  - Sass
  - CSS
  - Bootstrap
  - CoffeeScript
  - Go
  - Node
  - Bower
---
I could easily be labelled as a "[Ruby on] Rails Developer" and I'm quite
content with the asset pipeline for managing various front-end web development
assets (Javascript, CSS, client side templates, images, fonts, etc). But since
I'm playing around with [Go](http://golang.org/) for back end development on my
current project, I thought I'd investigate current practices for managing
assets on the front end. This is a rambling log of what I learned while I was
playing around.

Here are the goals I'm aiming for:

* versioned package management for the client side, including their
  dependencies, giving us a consistent set of source files used to deliver the
  web site, both in development and in production;

* using [{less}](http://lesscss.org) as a preprocessor for generating CSS (or
  [Sass](http://sass-lang.com), maybe, if that's what my CSS framework of
  choice happens to use);

* using [Twitter Bootstrap][bootstrap] as a CSS framework to make my app look
  pretty enough while I'm developing it, while encouraging me to write semantic
  CSS and HTML so a real designer can do something sensible with it;

* using [CoffeeScript](http://coffeescript.org) as a preprocessor, at least for
  any front end code I have to write;

* dependency management for my JavaScript code so things are pulled in and used
  in the right order;

* efficient delivery of assets in production (where my understanding of
  "efficient delivery" is concatenation to minimise HTTP requests, and
  minification to reduce file size);

* a smooth workflow in development (automatically producing assets from my
  source files when I change them, live reloading of pages, that kind of
  thing); and

* the ability to debug in-browser errors, mapping them back to the source that
  caused them.

Hopefully, as I work through this guide, I'll achieve most of these goals!

If you're interested in the code I wound up with (along with the story arc I
took to get there), you can find it up on GitHub:
[style\_guide](https://github.com/mathie/style_guide). If you'd like to suggest
improvements (or, better still, submit pull requests!) I'd love to hear them.

## Project background

Let's have a worked example to keep us on track. Let's say I'm building a style
guide — a tiny application which shows off my "house style" for CSS and
JavaScript components. As it turns out, my house style is *identical* to the
default Twitter Bootstrap one, so there's not much to the app. ;-)

## Creating the project

Since I'm building a [Go](http://golang.org/) web app for the backend, let's
start out by having a simple project which serves static files from a `public/`
directory. I'm assuming that I already have a Go workspace set up. (If you
don't, follow along with the instructions in [Writing Go
Code](http://golang.org/doc/code.html) to create a workspace and set up your
environment.) My Go workspace for this project is rooted at `~/Development/Go`,
so my `$GOPATH` is set accordingly:

    export GOPATH=${HOME}/Development/Go

First of all, let's create the project and stash it in a git repository to keep
track of what I'm doing:

```bash
mkdir -p ${GOPATH}/src/github.com/mathie/style_guide
cd ${GOPATH}/src/github.com/mathie/style_guide
cat > README.md << EOF
# Style Guide

Welcome to the house style guide.
EOF
git init && git add . && git commit -m "Empty project."
```

I won't continue to nag you to commit changes as we're going along; that's up to you!

## A static file server

This isn't about Go, so it isn't the most exciting web application server,
either. I've created a basic server which will serve static files from the
`public/` folder. Call it `main.go` in the project root:

```go
// A simple Go web application which serves static files from the `public`
// folder in the project. By default, it listens on port 8080, though you can
// change that below, if you like.
package main

import (
  "net/http"
)

// The main function is the entry point into the application. It creates a file
// server which will serve static files from the `public` folder, listening on
// port 8080.
func main() {
  http.Handle("/", http.FileServer(http.Dir("public")))
  http.ListenAndServe(":8080", nil)
}
```

That's it. I can run the application server directly with:

```bash
go run main.go
```

and visit <http://localhost:8080/> which will display `404 page not found`
since we don't have any content to serve yet. Let's fix that, by creating
`public/index.html` with the default template that Bootstrap recommends:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Style Guide</title>

    <link href="/assets/stylesheets/application.css" rel="stylesheet">
  </head>
  <body>
    <h1>Style Guide</h1>

    <p>Welcome to my style guide.</p>

    <script src="/assets/javascripts/application.js"></script>
  </body>
</html>
```

It's currently referencing a couple of assets that don't yet exist. That's OK,
I just wanted to set myself a target for what files should be generated when we
get to that. At least visiting <http://localhost:8080/> now should succeed, and
show our plain, un-styled, style guide. Now we can get on with meeting some of
the goals!

## Installing client side packages

We have identified a single dependency for the front end application:
[Twitter Bootstrap][bootstrap]. Since we're making use of some of the
Javascript components, we also indirectly depend on [jQuery][]. Hopefully, I
won't have to think about recursive dependencies though. After doing a bit of a
dig around online, and in my own "stuff I've read recently" list, it seems like
[Bower][] is good enough for the job.

### Installing Node & Bower

The easiest way to install it on Mac OS X seems to be through [npm][] which, in
turn, can be installed as part of [NodeJS][] with [Homebrew][] (it really is
[package managers all the way down](http://en.wikipedia.org/wiki/Turtles_all_the_way_down)):

    brew install node
    npm install -g bower

I'll use `npm` to track development dependencies (i.e. bower) and their
versions, so I've got a consistent environment wherever I'm doing development.
Create a starting point for `package.json` in the project root:

```json
{
  "name": "style_guide",
  "version": "0.1.0",
  "description": "My simple CSS style guide.",
  "author": "Graeme Mathieson <mathie@woss.name> (https://woss.name/)",
  "homepage": "https://github.com/mathie/style_guide",
  "repository": "https://github.com/mathie/style_guide"
}
```

Now I've got enough basics to stop `npm` from warning me about missing bits, I
can add my first development dependency:

```bash
npm install --save bower
```

This both installs bower locally, in a `node_modules/` folder at the root of
the project, and adds it as a versioned dependency in `package.json`. (I did
toy with the idea of wanting to tidy up the unpacked local copy of the modules
into `vendor/node/` or equivalent, but it looks like that would involve a
fight.)

I'll also add `node_modules/` to my project's `.gitignore` file — I'm happy
enough that we've fixed a reference to the version of the package we're using,
so I don't feel the need to vendor it, too. Your mileage and opinions will, of
course, vary.

### Managing client side dependencies with Bower

Now we've got bower installed, it needs a configuration file at the root of the
project, called `bower.json` to hold its configuration. Let's create a sensible
default:

```json
{
  "name": "style_guide",
  "version": "0.1.0",
  "private": true,
  "ignore": [
    "node_modules",
    "bower_components"
  ]
}
```

The name and version are the same as `package.json`. Wouldn't it be nice if
they could be shared instead of being repeated? I guess there's a reason for
them being separate, but I loathe duplication, particularly with things like
version numbers, which are so easy to forget to change before distribution a
new release!

Anyway. I've set `private` to true, which should prevent me from accidentally
distributing my application as a bower module, and I've set it to ignore
folders containing the packages we're setting up to manage. (This is suggested
as a default, anyway, so seems sensible.)

### Installing Twitter Bootstrap

Finally, we can install Bootstrap:

    bower install --save bootstrap

This downloads both Bootstrap and jQuery, unpacks them into the
`bower_components` folder, and adds a note of the versioned dependency into our
`bower.json` so it knows which version to install next time (which gives us our
"consistent set of source files" goal).

We haven't yet got to the stage where we can serve up these components, though,
since they are outside the web root. Let's get the CSS sorted,
[in the next part](/articles/front-end-development-101-part-2/), then worry
about the Javascript in a bit.

[bootstrap]: http://getbootstrap.com/ "Twitter Bootstrap: The most popular front-end framework for developing responsive, mobile first projects on the web"
[jquery]: http://jquery.com "jQuery: Write less, do more"
[bower]: http://bower.io "Bower: A package manager for the web"
[npm]: https://www.npmjs.org "Node Package Manager"
[nodejs]: http://nodejs.org "NodeJS"
[homebrew]: http://brew.sh "Homebrew: The missing package manager for OS X"
[coffeescript]: http://coffeescript.org "CoffeeScript: a little language that compiles into JavaScript"
