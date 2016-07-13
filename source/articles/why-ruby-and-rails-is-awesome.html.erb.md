---
published_on: 2009-01-16
title: Why Ruby (and Rails) is Awesome
redirect_from:
  - "/2009/01/16/why-ruby-and-rails-is-awesome/"
  - "/blog/2009/1/16/why-ruby-and-rails-is-awesome.html"
category: Programming
tags:
  - edinburgh
  - talk
  - slides
  - ruby
  - rails
  - migrations
  - deployment
  - velocity
  - scotland on rails
---
I was invited to give a short introduction to Ruby on Rails at [Tech Meetup](http://www.techmeetup.co.uk/) in Edinburgh a couple of days ago.  I'd been racking my brain for days on what to talk about -- 15 minutes is too short for me to give a meaningful introduction to Rails -- and eventually settled on telling a few stories.

<div style='width:425px;text-align:left'><object style='margin:0px' width='425' height='355'><param name='movie' value='http://static.slideshare.net/swf/ssplayer2.swf?doc=RubyandRailsisAwesome-12321018767-phpapp02&amp;stripped_title=Ruby-and-Rails-is-Awesome' /><param name='allowFullScreen' value='true'/><param name='allowScriptAccess' value='always'/><embed src='http://static.slideshare.net/swf/ssplayer2.swf?doc=RubyandRailsisAwesome-12321018767-phpapp02&amp;stripped_title=Ruby-and-Rails-is-Awesome' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='425' height='355'></embed></object></div>

The slides don't make much sense on their own, so I've included the "script" of what I talked about too.  I deviated quite a bit from the script as I got into it, so hopefully I should be able to provide audio (or, dread the thought, maybe even video) of the talk in due course.

# Intro

I’m Graeme.  I’m the Managing Director of Rubaidh Ltd, and have been developing Ruby on Rails applications professionally for 3 years now.

# Telling Stories

To be honest, I didn’t know what my audience this evening was going to be like.  I wasn’t sure if you’d all be business folks in suits, or whether you’d all be hardcore geeks that know more about web development than I could ever hope to. So I didn’t want to have slides full of code showing the technical prowess of Ruby.  And equally, I didn’t want a bunch of pie charts showing the return on investment you can make from choosing Ruby on Rails as your strategic development platform.

Instead I’m going to tell you a few stories.  These are stories that shaped my decisions and represent some of the things that make me realise the power of Ruby on Rails.  They are all true stories.  They all happened to me.  I may have changed the odd detail to protect the guilty parties, though.

I hope that, in imparting these stories to you all, not only will you appreciate my choice, but you will also reflect upon the choices you could make to improve your current (and future) business.

## Migrations

I used to have the pleasure of working full time on an open source email response management system.  It was the first open source business in Scotland to receive VC funding and was a fantastic product with huge potential.  (It still is, I’m sure, but I don’t keep up with development these days.)

As is always the case, there were a few skeletons in the development cupboard.  One was migration.  The first prototype of the product used an object database back end.  This database did not scale well.  In order to meet the scalability requirements of the hosted service for the business, we shifted to a SQL-based backing store.  We also made the decision to support multiple SQL databases – primarily MySQL and PostgreSQL, though there was demand in the open source community for MS SQL Server support too.

And there’s where we hit our major problem.  There was no database-agnostic layer between the application and the back end database.  It was a problem to maintain the slightly different SQL queries for different databases, particularly since a major part of the application was full text searching and we delegated that task to the database.

However, the biggest trouble we ran into was migration.  Migrating people from the object database back end to either PostgreSQL or MySQL.  Migrating people from one SQL schema to another.  Or, in the case of one client, migrating from the PostgeSQL back end to a MySQL one.  Our home grown solution was flawed and wound up with a number of client installations having subtly different database schemas (my fault!).  So, in addition to having to cope with different database back ends, the problem had grown exponentially into having to deal with different schemas.  Yeuch.

When I first looked at Ruby on Rails, one of the features that caught my eye was its built in support for database migrations.  In a back end-agnostic manner, it will allow you to plot the course of a database schema through the versions of an application, gracefully (and consistently!) moving from one version to the next.  This totally blew my mind after a day of dealing with a customer who’s database schema didn’t quite match my expectations...

## Deployment

This is another horror story about the very same application.  What can I say?  It’s what eventually made me jump to Rails.

The hosted service, at this point, was spread across two servers.  We had sharded the data -- free accounts on one server and paid accounts on the other.  This at least meant that when the free trial server got overloaded, at least the paid accounts didn’t suffer.

Deploying a new version of the application was a manual process.  We would ssh into each of the servers, stop the front end Apache server (so that nobody could mess with the application while it was in an inconsistent state), stop the application servers, update the code from the subversion repository, perform a number of other tidy-up tasks that I dread to recall, start the application servers, and finally restart the Apache servers.  Deployments would take up to an hour.

One nightmare involved a number of complex database migrations because the two servers had wound up with an inconsistent schema.  They needed to be made consistent because a free trial customer had just upgraded to a paid account.  It took us about 2 days to sort the production platform out.  Downtime was about 5 hours in total.

Shortly after that incident, I ran into Capistrano, the deployment tool of choice for Ruby on Rails applications.  It gracefully allows you to manage front end web servers, application servers and database servers, running on 1 machine or spread across 20.  With Capistrano, deployments are simple, fast and, mostly importantly, reversible.  In some of our applications, we’re doing in the region of 10 deployments a day.  This means that we are delivering production-ready features to the business users who are requesting them up to 10 times a day.   Can you offer that kind of turnaround?

Of course, it’s not just Capistrano’s deployment assistance that allows us that level of efficiency, but it is a key factor.

## Velocity

This last story is one from since I started working full time with Ruby on Rails, but it often reminds me why I still feel we made the correct business decision.  At the tail end of 2006, the Chief Operating Officer of a start up approached me for a bit of consultancy.  They had put together an awesome business plan for an online training platform which needed a large web application to be developed.  The COO had done his research and decided that Ruby on Rails was the right development platform and, in particular, that Rubaidh was the right company to deliver the platform.

In order to secure the funding required for the project, the company had put together a detailed specification for the application, including cost estimates and staffing requirements.  I  believe those estimates showed that it would take 4 developers around 9 months to build the application.

We came in as a full time team of three developers, and we delivered working software to the business every two weeks.  After 3 months, the system was complete enough to allow the editorial team to start entering the training courses.  And after 5 months, we had a production-ready application which the sales team could use as a demonstration of the system’s potential.

Just to underline the point here.  A project that was estimated (by an experienced software engineer and project manager) should have taken 36 person-months to deliver was, thanks to Ruby on Rails (and Agile development practices), delivered in 15 person-months.

# JumpStart

With apologies to Sun for stealing their name (and to Thoughtbot for apparently stealing their idea -- we thought of it independently, honest!), what presentation would be complete without pimping our own company a little?  We are offering a service to get your next project off the ground fast.  We will:

* Start building your dream web application, working as an experienced in-house team, immediately.

* Help you hire, and train, your in-house team.

* Gradually step away and let your in-house team take over, when they are ready.

We’ve already done this once, and it was a major success for both us and client, so we’ve decided to turn it into a service we offer.

# Scotland on Rails

Scotland on Rails Conference 2009 is running on 26th-28th March in Pollock Halls in Edinburgh.  Keynote speaker, and Rails Core member, Michael Koziarski, recently described last year’s conference as “the best small conference” he’d ever attended.  That’s high praise, because he attends a lot of conferences!

This year, we’re featuring keynotes from Marcel Molina Jr, long time Rails Core team member, and Michael Feathers, an early adopter of Extreme Programming and Agile development practices, who is probably best known for his book, “Working Effectively with Legacy Code.”

We also have presentations from big names in the Ruby community, like Yehuda Katz (Merb), Dave Thomas (Pragmatic Programmers), Scott Chacon (GitHub) and Jim Weirich (definitely, without a doubt, a werewolf!).

Tickets are £175 for the conference, though there’s an early bird offer of £150 available until Feb 8th.

Prior to the two day conference, Chad Fowler and Marcel are running an all day charity tutorial.  All the proceeds go to the Children’s Hospice Association Scotland.  It’s a £75 minimum donation, but considering these folks are both Pragmatic Studio teachers (where the courses are nearly £300/day), it’s an utter steal.

Run, don’t walk, to [scotlandonrails.com](http://scotlandonrails.com/) to sign up.

To close, I’d like to share a story from Jim Weirich, one of our speakers at Scotland on Rails.  He was talking a couple of years ago at RailsConf Europe about a financial application he and his team had developed in Java. It took a team of 4 of them about 6 months.  As an experiment, they tried a spike of it in Ruby.  It took them 4 evenings.

That’s not the impressive part, though.  After all, since they now had a deep understanding of the problem domain, naturally they would be able to translate the solution into another language quicker than they could have written it in the first place.

The impressive part?  The total number of lines of Ruby code required to implement the application was less than the number of lines of the Java version ...’s XML configuration.

# I can haz questions?

So, questions?
