---
published_on: 2011-10-12
title: Understanding the Rails Logger
redirect_from: "/2011/10/12/understanding-the-rails-logger/"
category: Programming
tags:
  - ruby
  - rails
  - logging
  - activesupport
  - atomicity
  - flushing
  - buffering
  - delayed job
---
I’ve lost track of why now, but I’ve spent a bit of time this afternoon trying to understand how the Rails logger works in production. For years we’ve been using a [Hodel 3000 Compliant Logger](http://nubyonrails.com/articles/a-hodel-3000-compliant-logger-for-the-rest-of-us), which is dead straightforward. Recently, though, we switched back to using the built in logger with Rails, which is a little more subtle.

The default logger in Rails is the `BufferedLogger` from `ActiveSupport`. It can be configured to only flush log messages to disk every so often, instead of writing out each message as soon as it’s logged. There are a couple of key advantages to buffered logging:

Perhaps a slight performance increase, since you’re writing stuff out to disk less often. At the volumes we’re logging (just a few gigabytes/day right now), I doubt this is much of a concern.

More usefully, we get atomic(ish) writes of log messages. Say you’ve got 42 Unicorn workers all taking a share of the load of your web app. They’re all writing to a single, shared, log/production.log file. If we’re individually writing out each log message as we’re asked to, then all the messages from the various workers will be interspersed, making it difficult to figure out which log message is part of which request.

However, if you `write()` out all the log messages for a request together, that write will happen atomically(ish), meaning the messages will all stay together, making debugging that little bit easier. Win.

I say ‘ish’ because it’s still individually writing out each message, so there’s nothing to stop two Unicorn workers from writing out at the same time, but the writes are happening over the course of a single millisecond instead of (up to) a couple of hundred milliseconds.

So, how does the Rails `BufferedLogger` work? Well, it has an internal buffer (an array) created on demand for each thread in the system (by virtue of a hash with a default value). When a new message is logged, it chucks the message on to the end of the array.

Once it’s added the message to the buffer, it calls the `auto_flush` method which checks to see if the current buffer size is larger than the `auto_flushing` period. If it’s more than we’re supposed to store before auto flushing, flush the buffer to disk and delete it. Straightforward enough.

A couple of other things to note about the auto_flushing method:

* If you do `logger.auto_flushing = true` then it will set the period to 1, meaning it will flush after every log message.

* If you do `logger.auto_flushing = false` then it will set the period to MAX_BUFFER_SIZE (set to 1,000), which means it will only flush every 1,000 log messages.

* If you do `logger.auto_flushing = 54` (or any other arbitrary integer), then you can control the period (the number of messages between flush) yourself.

* The default is to flush after every single log message (you can see from the initializer setting `@auto_flushing` to 1).

That’s it for ActiveSupport for now. If we want to further understand the Rails behaviour for logging in production, we have to jump over to where the logger is initialised, in railties, specifically in bootstrap.rb.

The logger is initialised early on in the file, setting the `Rails.logger` to be an instance of `ActiveSupport::BufferedLogger`. It sets the log level. Then we hit the paydirt:

```ruby
logger.auto_flushing = false if Rails.env.production?
```

So, we have two possibilities for our log flushing behaviour:

* In every environment other than production (including that staging environment you swore was an exact duplicate of production!), log messages are flushed immediately after they are created.

* In the production environment, log messages are flushed to disk every 1,000 messages.

I don’t like my staging (or any other non-development/test) environment behaving differently from production. Let’s fix that as quickly as possible in the initialization process. I’ve added the following to config/application.rb, inside the Application class:

```ruby
module Freeagent
  class Application
    initializer :initialize_logger_auto_flushing, :after => :initialize_logger do
      Rails.logger.auto_flushing = (Rails.env.development? || Rails.env.test?)
    end
  end
end
```

which should set `auto_flushing` to 1 (after every message) in development and test environments, but 1,000 in all other environments. Much more sensible. If you wanted to tweak the threshold for auto flushing, this would be the place to do it, too. Set it to an integer value depending on your environment instead of true or false.

That’s not the end of the story, though. Most of the Rails’ internal logging goes through a publish/subscribe (or notify/subscribe in Rails’ parlance) mechanism. And there’s a handy wee middleware supplied by railties which pitches in called `Rack::Logger`. The interesting thing it does is to flush all log subscribers at the end of every request.

The net effect is that `Rails.logger` (our buffered logger) is force-flushed at the end of every request. This is a good thing, because it means we get timely delivery of logs, though the circumspect route by which it happens makes it a little tricky to prove to yourself that’s what is going on.

However, if you happened to have other loggers which were part of the request/response cycle, but didn’t happen to use the Rails notification system, you’d be surprised to see they didn’t log very often in production.

Speaking of the request/response cycle, that reminds me of why I went investigating in the first place: delayed job! Our background worker system is, naturally, outside the request/response cycle. It also sees relatively little in the way of log messages (certainly compared to the web workers!). It often takes a while for 1,000 log messages (the default in production) to build up before it flushes them out to a log file.

In our case, I would like it to have a similar behaviour to the web workers: it flushes the logs after each “request” (job) is completed. Here’s a wee monkey patch to make that happen:

```ruby
module Delayed
  Worker.class_eval do
    def run_with_log_flushing(job)
      run_without_log_flushing(job).tap do
        logger.try(:flush) if logger.respond_to?(:flush)
      end
    end
    alias_method_chain :run, :log_flushing
  end
end
```

I reckon that’ll do the trick. I know the cool kids don’t use `alias_method_chain` though, so perhaps there’s a better way. Fork, patch and pull request, for example! :-)

There is another problem with our delayed job workers. When you quit them, you lose those buffered messages (up to 1,000 log messages!). It turns out that’s fixed in the latest version of Rails. As of some version of Rails > 3.0.10 and < master, it now also sets up an `at_exit` handler to flush the Rails log as the process exits. Meantime, I think it’s enough to create a quick initialiser in `config/initializers/flush_logs.rb` with something along the lines of:

```ruby
at_exit { Rails.logger.flush if Rails.logger.respond_to?(:flush) }
```

An adventurous afternoon spelunking the Rails codebase, and now we have logs doing what we want in production again. What fun, eh?

*Side note: this article was originally published on the [FreeAgent Engineering Blog](http://engineering.freeagent.com/2011/10/12/understanding-the-rails-logger/).*