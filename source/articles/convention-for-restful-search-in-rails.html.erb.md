---
title: Convention for RESTful search in Rails?
excerpt: I wonder aloud about a convention for search in Rails RESTful controllers.

published_on: 2007-07-22

category: Software development
tags:
  - rest
  - search
  - railsconf
  - ruby
  - rails
  - code
---
Back in RailsConf Europe last year, at [David's Keynote](/2006/09/30/railsconf-europe-2006-first-plenary-dhh/), it was said that:

> There are unresolved decisions with respect to the restful controllers. In particular, what should the convention be for searching? A separate action? Or parameters passed to the index action?

I don't suppose a convention has been adopted for this yet?  I'm just about to implement search in an application I'm working on and I'd rather go with the 2.0 convention now, rather than fight against it with my wrong decision later. :-)

**Update** Judging by the implementation of `ActiveResource#find` it's parameters passed to index, isn't it?

**Update 2** OK, so what's the elegant, reusable implementation for `FooController#index`, turning `params` into `find(:all, :conditions => ...)`?

**Update 3** I've started codifying what I'm doing into a plugin: [resource_search](http://svn.rubaidh.com/plugins/trunk/resource_search). It's still in its infancy.
