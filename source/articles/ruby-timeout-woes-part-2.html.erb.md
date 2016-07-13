---
published_on: 2011-08-30
title: Ruby Timeout Woes, Part 2

excerpt: in which I discover how Ruby's Timeout implementation actually works, and
  discover why some of our code inside a timeout block never really times out.
category: Software development
tags:
  - ruby
  - timeout
  - exceptions
  - threads
  - bugs
  - delayed job
---
Following on from [Ruby Timeout Woes, Part 1](/articles/ruby-timeout-woes-part-1/), I started digging into how Ruby's timeout mechanism worked this morning, in order to get to the bottom of a bug we've got.

Let me give you a little context. We use [Delayed Job](https://github.com/tobi/delayed_job) to run some of our longer running tasks. Delayed job wraps all its jobs in a timeout, which we've set to 20 minutes. That's a good thing: I don't really want a job running forever and, consequently, tying up one of our workers forever. So, we've got Delayed Job wrapping arbitrary code in Ruby's built in `Timeout`. What can possibly go wrong?

Well, it turns out that, for one particular job, the timeout mechanism wasn't working, and the job was carrying on well past the 20 minute timeout we'd set. Worse still, when a running job exceeds the maximum run time, Delayed Job will assume that the entire worker died, break the lock and hand the job to another worker. So we wound up with every single delayed job worker in our cluster running the same job, to completion, no matter how long it took.

Suboptimal, eh?

I started digging into Delayed Job, our code, and the `Timeout` implementation to see if I could figure out what was going wrong. Delayed Job is doing fine, nothing unusual there. The `Timeout` implementation is interesting. It creates a separate thread, which then sleeps for the timeout length. If the main thread completes its block before the timeout, it just kills the timeout thread and carries on happily. However, if the timeout thread wakes up before the main thread has completed execution, then it raises an exception on the main thread. The timeout method catches that exception on the main thread, tidies up and raises a `Timeout::Error` exception.

There are a few problems with that implementation (every call to `Timeout.timeout` creates a new thread, and it makes use of `Thread.raise` and `Thread.kill` which, as [Charles Nutter pointed out a few years back](http://headius.blogspot.com/2008/02/rubys-threadraise-threadkill-timeoutrb.html) is a little broken), but we'll gloss over them for now. That's not what was causing my woes today. Let's reduce the problem to a simple example:

```ruby
require 'timeout'

puts "#{Time.now}: Starting"
begin
  Timeout.timeout(5) do
    begin
      sleep 10
    rescue Exception => e
      puts "#{Time.now}: Caught an exception: #{e.inspect}"
    end
    sleep 10
  end
rescue Timeout::Error => e
  puts "#{Time.now}: Timeout: #{e}"
else
  puts "#{Time.now}: Never timed out."
end
```

Let's see what happens when we run that wee snippet:

    Tue Aug 30 13:38:56 +0100 2011: Starting
    Tue Aug 30 13:39:01 +0100 2011: Caught an exception: #<#<Class:0x1001337f0>: execution expired>
    Tue Aug 30 13:39:11 +0100 2011: Never timed out.

The inside rescue block is catching some exception after the timeout has expired, but the one expecting the timeout error never gets it. That's down to the implementation of `Timeout`. When the timer thread reawakened, it threw an exception on the main thread. The exception it threw on the main thread inherits from `Exception`, so anything that catches `Exception` will catch it before it bubbles back up the stack to the `timeout` method. So, while we've timed out the inner block, we've neutered the overall effect of the timeout method.

Lessons learned:

* Catching generic `StandardError` exceptions is crazy enough, but you probably never want to catch `Exception`. PS, library authors, your exceptions should inherit from `StandardError`, not `Exception`.

* Ruby's built in `Timeout` mechanism is crazy in a whole new and interesting way, too. Be careful how you use it.
