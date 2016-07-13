---
published_on: 2011-08-30
title: Ruby Timeout Woes, Part 1

excerpt: in which I discover that the behaviour of Ruby's built in timeout mechanism
  has changed slightly between Ruby 1.8.x and Ruby 1.9.
category: Software development
tags:
  - ruby
  - rails
  - timeout
  - exceptions
---
I seem to be having a bad day with the built in `Timeout` class in Ruby. There are two problems; one is pretty innocuous, the other ... not so much.

When you're using `Timeout`, you'll typically wrap the block of code you're wanting to guard like this:

```ruby
require 'timeout'

begin
  Timeout.timeout(10) do
    # Block of code
  end
rescue Timeout::Error => e
  puts "Execution expired"
end
```

Your block of code will run for up to (approximately) 10 seconds and, if it hasn't completed in that time, will raise the `Timeout::Error` exception. Pretty straightforward.

The innocuous issue is just one trying to make me mistrust my memory. In Ruby 1.8.x, `Timeout::Error` inherits from `Interrupt`, so it's inheritance from `Exception` goes along the lines of:

```ruby
Timeout::Error < Interrupt < SignalException < Exception
```

The key thing to note here is that it *doesn't* inherit directly from `StandardError` and so a blank rescue block won't catch it:

```ruby
begin
  Timeout.timeout(10) { sleep 20 }
rescue
  puts "On Ruby 1.8.x I won't catch the timeout exception."
end
```

However, on Ruby 1.9.2, `Timeout::Error` inherits from `RuntimeError`, so in the above code example, the rescue block *will* get called. That's annoying, but it's not like it's the only incompatible change between Ruby 1.8.x and Ruby 1.9, so I'm OK with that. Plus, non-specific `rescue` blocks like that are a bad smell anyway.

The slightly more insidious problem needs further explanation. Come back again later on and I'll tell you all about it. In fact, it's already here, at [Ruby Timeout Woes, Part 2](/articles/ruby-timeout-woes-part-2/).
