# Wossname Industries web site

[![Build Status](https://travis-ci.org/wossname/woss.name.svg?branch=master)](https://travis-ci.org/wossname/woss.name)

This is the source code to the [Wossname Industries](https://woss.name/)
website. It's built using [Middleman][] static site generator and deployed to
Amazon S3, fronted by CloudFront. I'm using more-or-less the same template for
all my websites right now, so there's a lot of duplication between this site
and others on <https://github.com/wossname>. I really ought to pull the common
bits out into a gem or something. Assets are managed through an external asset
pipeline, using gulp to generate CSS & JavaScript from the source.

Building and deploying the site is controlled through rake, which encapsulates
all the associated tasks required.

## Installing dependencies

Ruby dependencies are managed through Bundler, NodeJS ones through npm, and
client side code is managed through Bower. That all sounds a bit complicated,
so running:

```shell
rake deps
```

should install all the dependencies required to build the site.

## Running locally

To develop the site, it's helpful to run Middleman locally, which will serve up
live versions of the pages. As with every web app I develop, I'm running the
server via foreman, but there's a Rake task to abstract that away. Run:

```shell
rake serve
```

and the site should be available on <http://localhost:5000>, LiveReload should
be set up to automatically refresh a page when it changes, though that can
sometimes be a bit patchy if it involves the external pipeline. If you change
any of the Ruby code (`config.rb` or anything in `helpers/`) you'll want to
restart the server for the changes to be seen.

## Building the site

In order to build a static version of the site, run:

```shell
bundle exec rake build
```

which will kick off Middleman (which will, in turn, kick off the external asset
pipeline) to build everything. The resulting static site will wind up in the
`build` directory.

## Deploying the site

To deploy the site to Amazon S3, first build it as above, then run:

```shell
bundle exec rake deploy
```

This relies on `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` being set in the
environment. It will upload any changed files to S3, kick off a CloudFront
invalidation to make sure the new pages are being served, and it'll ping
Google/Bing with the new sitemap to let them know it's been updated. This
happens automatically through Travis CI when a new version is pushed to master.

## Links

These are mostly just for my benefit, since they're not all public!

* [Trello Board](https://trello.com/b/Fux05K1K/5-wossname-industries) (team
  visible, since it contains *everything* on my todo list for Wossname
  Industries, not just the web site!)

* [Google Analytics](https://analytics.google.com/analytics/web/#report/defaultid/a73667132w111651136p116531138/)
  which I'd make public if I knew how. ;-)

* [Google Tag Manager](https://tagmanager.google.com/?hl=en#/container/accounts/273912313/containers/2329943)
  which I'm playing around with for managing random lumps of JavaScript on the
  page.

Other places you can find Wossname Industries around the web:

* [GitHub](https://github.com/wossname/) obviously!
* [Twitter](https://twitter.com/wossname/)
* [Facebook](https://www.facebook.com/WossnameIndustries)
* [Google+](https://plus.google.com/+WossnameIndustries)

[Middleman]: http://middlemanapp.com/
