---
published_on: 2011-01-20
title: Equality, Comparison and Uniqueness in Ruby

category: Software development
tags:
  - ruby
  - rails
  - sorting
  - equality
  - comparison
  - hashes
  - uniqueness
  - comparable
  - spaceship
---
Ruby has the `Comparable` module, which, if you implement the spaceship operator `<=>` (winner of "Best Named Operator" 10 years running!) then it will give you a bunch of comparator operators for free (`<`, `<=`, `==`, `>=` and `>`). Win. Enumerable's `#sort` method uses the spaceship operator to do sorting too, so implementing the spaceship gives you a whole bunch of interesting behaviour pretty much for free.

However, while you might think that `Array#uniq` used `==`, or even `<=>` directly, to implement its uniqueness semantics, you'd be wrong.

First, let's take a step back. There are a few ways to determine different qualities of equality in Ruby:

* `==` is value equality where you consider two values to be equal. So, `1 == 1` or `1 == 1.0`.

* `eql?` is stronger than `==` so that in addition to value equality they must have type equality. The above example demonstrates the difference: `1.eql?(1)` is true but `1.eql?(1.0)` is false.

* `equal?` is even stronger still; they must be the same object id. To be honest, the only time I've had call to use this is when testing that a DataMapper-style implementation was doing the right thing.

And it turns out that Ruby uses `.eql?` to determine whether an object is `uniq` or not.

Here's the first thing I found slightly surprising: `eql?` is not implemented in terms of `==`. To my mind, it's an obvious implementation:

```ruby
def eql?(other)
  self.class == other.class && self == other
end
```

and there would be faster implementation in C, of course, but I guess there's a reason it doesn't do that. Then again, I wonder if that should be:

```ruby
def eql?(other)
  is_a?(other) && self == other
end
```

It's not really obvious from the Pickaxe, and I can't think of an example to test it with. Anyway, back on track. So, if you're wanting to customise the way that `#uniq` works, you're going to have to implement `#eql?` on your own class.

And you're still going to be surprised that doing so doesn't make `#uniq` work. See, there's a bit of a performance optimisation going on here. First of all, it uses `#hash` to group together potential duplicates, then it uses `#eql?` to verify that the duplicates are definitely are the same.

So, if you want to customise the way `#uniq` works for your particular class, you also have to implement `#hash`. Here's what I came up with in the end (imagine that `nominal_code` fully encompasses the object's identity and ordering if you will):

```ruby
class NominalAccount
  attr_reader :nominal_code

  include Comparable

  def <=>(other)
    nominal_code <=> other.nominal_code
  end

  def eql?(other)
    self.class == other.class && self == other
  end

  def hash
    nominal_code.hash
  end
end
```

Now I can sort and uniqueify collections of these objects through their natural primary key. Win.
