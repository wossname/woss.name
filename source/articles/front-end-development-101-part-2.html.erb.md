---
published_on: 2014-12-06
title: Front-end Development 101
subtitle: "Part 2 (of 3): Using Grunt to automate CSS compilation"
excerpt: |
  In the second part of this series, I'm taking a look at using Grunt to
  automate repetitive tasks and to automatically build artefacts when a source
  file changes. And we'll use Grunt to compile our stylesheets, from our own
  Less CSS source, and Twitter Bootstrap.
category: Software development
tags:
  - JavaScript
  - Grunt
  - Less
  - CSS
  - Bootstrap
  - CoffeeScript
  - Go
---
Since I'm playing around with [Go](http://golang.org/) for back end development
on my current project, I thought I'd investigate current practices for managing
assets on the front end. This is part 2 of a rambling log of what I learned
while I was playing around. I'd recommend reading
[part 1](/articles/front-end-development-101-part-1/) for some
background if you haven't already.

## Installing Grunt

Grunt is a task runner, which manages dependencies amongst tasks, just like
`make`. It seems to be a rite of passage that every programming language on
every platform must reinvent `make`. (I think it's something to do with an
allergic reaction to tab characters.) Let's install grunt and make it a
"development" dependency (i.e. a dependency that's only required if I'm
developing, or packaging, this application, not if I'm just running it in
production):

    npm install --save-dev grunt

This downloads and unpacks the grunt into the `node_modules` folder, and adds
it to `package.json`. In addition, in order to run the grunt command line tool,
I need to globally install the `grunt-cli` package:

    npm install -g grunt-cli

All this command line tool does is to find the version of grunt that's
associated with the `Gruntfile` it's attempting to use, then invoke it.

## Building stylesheets with Less

Since Bootstrap is developed with Less (even if there is now an automagic Sass
port for the Rails punters who like fewer dependencies), let's use that for our
own stylesheets, too. I'll use Less's import mechanism to generate a single CSS
file. Since I'm a Rails weenie, and I'm quite happy with its folder structure,
I'm looking to turn `app/assets/stylesheets/application.less` into
`public/assets/stylesheets/application.css`.

Fortunately, grunt has an officially maintained module for that, called
[`grunt-contrib-less`](https://www.npmjs.org/package/grunt-contrib-less). Let's
install that as a development dependency:

    npm install --save-dev grunt-contrib-less

Now let's configure grunt to take some of the grunt work out of producing CSS
files. The bulk of the configuration happens in the `Gruntfile`. Now this file
can either be `Gruntfile.js` or `Gruntfile.coffee`, depending on what you'd
rather write. I'm quite fond of CoffeeScript, but most of the examples are in
straight JS, so there's a fine line between paths of insanity. Let's give
CoffeeScript a go. Create `Gruntfile.coffee` with the following content:

```coffeescript
module.exports = (grunt) ->
  grunt.initConfig
    # Import package metadata from package.json, just in case it's useful.
    pkg: grunt.file.readJSON('package.json')

  grunt.loadNpmTasks('grunt-contrib-less')
```

All that remains to do is configure the less task. This code block is inserted
as part of the JS object that's passed as an argument to `grunt.initConfig()`:

```coffeescript
# less tasks for converting less source to CSS.
less:
  options:
    paths: [ 'bower_components' ]
  development:
    files:
      "public/assets/stylesheets/application.css": "app/assets/stylesheets/application.less"
```

It's pretty straightforward, with two things happening:

* The generated file in `public/assets/stylesheets/application.css` is
  generated from the source file, `app/assets/stylesheets/application.less`.
  (It in turn imports other files, but that's our entry point into
  [less][lesscss]-land.)

* The `bower_components` folder is added to the search path.

The latter allows more sensible imports inside a less file, to be able to:

```css
@import 'bootstrap/less/bootstrap.less';
```

instead of:

```css
@import '../../../bower_components/bootstrap/less/bootstrap.less';
```

which is a bit unwieldy. I can regenerate the CSS by running `grunt less`:

    grunt less
    Running "less:development" (less) task
    File public/assets/stylesheets/application.css created: 0 B → 21.4 kB

    Done, without errors.

Reloading <http://localhost:8080/> shows up the page with the stylesheet
applied. I've got a simple set of stylesheets so far, split into a couple of
files just to prove that less is successfully importing files. First of all,
`app/assets/stylesheets/application.less`:

```css
@import 'base.less';
```

Then `app/assets/stylesheets/base.less`:

```css
// Pull in the minimal bits of Bootstrap I need right now:

// Core variables and mixins
@import 'bootstrap/less/mixins.less';
@import 'bootstrap/less/variables.less';

// Bootstrap reset
@import 'bootstrap/less/normalize.less';
@import 'bootstrap/less/print.less';

// Core CSS
@import 'bootstrap/less/scaffolding.less';
@import 'bootstrap/less/type.less';

// Customise some of the bootstrap variables.
@import 'variables.less';
```

And, finally, `app/assets/stylesheets/variables.less`:

```css
@body-bg: #ccc;
```

I've also added `/public/assets` to my `.gitignore` so I don't accidentally
check in generated files if I can possibly avoid it.

## Watching for file changes

The trouble is that the workflow here isn't terribly elegant: every time I make
a change to a less source file, I have to run `grunt less`, wait for it to
complete, and reload the page to see the effect of the change. Let's fix that
with the grunt [watch](https://www.npmjs.org/package/grunt-contrib-watch)
plugin (another one that's officially maintained by the Grunt team). First of
all, install it:

    npm install --save-dev grunt-contrib-watch

Now to configure it, I've added the following configuration inside the
`grunt.initConfig()` arguments:

```coffeescript
# Watch source files for changes and rebuild the associated assets
watch:
  options:
    livereload: true
    spawn: false
  gruntfile:
    files: [ "Gruntfile.coffee"]
    options:
      reload: true
  stylesheets:
    files: [
      "app/assets/stylesheets/**/*.less",
      "bower_components/**/*.less"
    ]
    tasks: [ "less" ]
```

and load the module in the main `module.exports` method:

```coffeescript
grunt.loadNpmTasks('grunt-contrib-watch')
```

This tells it to watch all the less files in `app/assets/stylesheets` and
`bower_components` and, if any of them change, trigger the `less` task, which
will rebuild them all. If, in future, I find this is taking too long to
complete, and that I have different entry point stylesheets for different parts
of the app, I can break this down to be more fine grained, but it'll do nicely
for now.

There's also a task in there to watch for changes to the `Gruntfile.coffee` and
reload, so I don't have to restart it manually when I'm mucking around with it.
Now start it up with:

    grunt watch

Leave that running in a terminal. It'll let you know when one or more tasks are
triggered.

The watch plugin also has built in support for [Live Reload](http://livereload.com/)
so if you've got the browser plugin installed and enabled (I'm using the
[Google Chrome Live Reload extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei)
it will automatically refresh your page when the stylesheets have been rebuilt.

## Conclusion

That's it for today. We've figured out how to use Grunt to automate repetitive
tasks, and we've figured out how to build our stylesheets, starting with
Twitter Bootstrap as a solid foundation. Not bad. Next time, we'll finish off
with a whirlwind tour of JavaScript, image optimisation, and a little bit on
tidying up after ourselves.

[lesscss]: http://lesscss.org "Less is a CSS pre-processor, meaning that it extends the CSS language, adding features that allow variables, mixins, functions and many other techniques that allow you to make CSS that is more maintainable, themable and extendable."