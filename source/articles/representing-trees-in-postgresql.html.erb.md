---
published_on: 2014-11-21
title: Representing Trees in PostgreSQL
category: Programming
excerpt: |
  Today we figure out a novel approach to the materialised path pattern for
  representing hierarchical data in SQL. It takes advantage of PostgreSQL's
  native support for array types. But it also poses a question: can we make use
  of ActiveRecord's preloading machinery for eager loading these trees?
tags:
  - trees
  - hierarchies
  - materialised path
  - adjacencies
  - nested sets
  - postgresql
  - ruby
  - rails
---
## Background

Trees are a very useful data structure for modelling real world entities. You
can use them to model an organisation's logical structure (teams, tribes,
squads, departments, etc) or you can use them to model a building's physical
structure (campuses, buildings, floors, rooms, etc). You can use them to model
conversations (nested comments). The possibilities are endless.

The trouble with hierarchical data like this is that it doesn't fit terribly
well into our traditional relational data model, where we're operating over a
set of data which matches some particular constraint. It's OK if the depth of the tree is fixed. So, if for example, we had a rigid model for our hierarchy which represented locations (a room on a floor within a building, say), then it's straightforward to write queries for that data. Let's say we wanted to find out which room a computer was in:

```sql
SELECT buildings.name building, floors.name floor, rooms.name room
FROM computers, locations buildings, locations floors, locations rooms
WHERE computers.name     = 'Arabica'
  AND computers.room_id  = rooms.id
  AND rooms.location_id  = floors.id
  AND floors.location_id = buildings.id
```

Unfortunately, here the structure of the tree is baked right into the query. If
we wanted to change the model -- say to break rooms out into individual desk
locations -- then we'd have to change the queries and other code to accommodate
that. Since trees of arbitrary depth and flexible structure are so useful,
people have come up with a few ways to shoehorn them into a SQL database model:

* **Adjacency model** is where the nearest ancestor of a particular row (the
  parent) has its id recorded on each of its children. Each child winds up with
  a `parent_id` column which refers to its immediate parent. This seems like a
  clean, natural, solution from a programming perspective but, in practice it
  performs poorly and is hard to manage.

* **Materialised Path model** is where each node in the tree has a column which
  stores its entire ancestral path, from the root node, down to its parent.
  These are typically stored a string and encoded with delimeters so they're
  easy to search on. If we have a structure along the lines of `A -> B -> C`
  (that is, `C` is a child of `B` who, in turn, is a child of `A`), then `C`'s
  path column might be `A/B`.

* **Nested Sets** are slightly more complex to contemplate. Each node is given
  a "left" number and a "right" number. These numbers define a range (or
  interval) which encompasses the ranges of all its children. To continue with
  the example above, A might have an interval of `(1, 5)`, B could have an
  interval of `(2, 4)` and C could have a short interval of `(3, 3)`. This
  particular representation is great for searching subtrees, but inserting a
  new node can potentially cause half the nodes in tree to need to be
  rebalanced (i.e. have their intervals recalculated).

There's also a twist on the Nested Sets model, called the **nested interval**
model, where the nodes are given two numbers that represent the numerator and
denominator of a fraction, but it doesn't seem so popular, and was too complex
to wrap my head around!

Each of these models have their advantages and disadvantages, both in terms of
their data representation, and in terms of the performance of common
operations. Some are blazingly fast for `INSERT`s, for example, while making it
unnecessarily hard to perform common queries. Choosing the right one depends on
your workload. (The good news, though, is that you can always migrate your data
from one pattern to another, if it turns out your real life workload requires
it.)

## PostgreSQL Arrays

For the current project I'm working on, I decided that the materialised path
pattern would probably be the most appropriate for our particular workload. And
it gave me a good excuse to try out an idea that's been on my todo list for a
couple of years now: using PostgreSQL's native array type to store the
materialised path.

## An Example

Let's work through a wee example to see it in action. Our application has a
hierarchical tree of nodes. There can be multiple root nodes (that is, nodes
without any ancestors), and each node simply has a name (which is required).
You can find the sample app up on GitHub:
[tree](https://github.com/mathie/tree) which includes a bit of UI to play
around with it, too. One thing to note is that we're dependent upon the [`postgres_ext`](https://github.com/dockyard/postgres_ext) gem to handle the conversion between PostgreSQL and native array types. Let's start with the migration:

```ruby
class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string  :name, null: false
      t.integer :path, null: false, array: true, default: []

      t.timestamps null: false
    end

    add_index :nodes, :path, using: 'gin'
  end
end
```

It's handy that ActiveRecord 4.x supports creating array types. So here we have:

* An integer `id`. This does also work with uuid-style ids, but there are a few
  more hoops to jump through.

* An array of integers as the `path`. This represents our materialised path of
  the ancestors of each node. It can't be `NULL`, but defaults to the empty
  array, which is how we represent a root of a tree (no ancestors).

* Timestamps, as usual, because it's easier to go with the flow. :)

* A Generalised Inverted Index (GIN) on the path column, which I'll explain in
  more detail later. Suffice to say, this means all our common operations on
  the tree should hit an index, so should be 'fast enough'.

Let's now think of some of the queries we might like to ask our tree. In each
of these cases, I'm keen for the resulting class to be an
`ActiveRecord::Relation`, since that way a client of the code can further
refine the search. (Say for example, I wanted to search a particular subtree
for all the nodes that had a green name, I could chain together,
`node.subtree.where('name LIKE ?', '%green%')`.)

### Finding Nodes

We'd probably like to get a list of the root nodes -- after all, we've got to start somewhere. What would that look like?

```ruby
class Node < ActiveRecord::Base
  def self.roots
    where(path: [])
  end
end
```

Which is just asking for all the nodes which have an empty array for the path.

Now that we've got an initial node to work from, what kinds of queries might we
want to do on it? Well, we might want to find the root of the tree that
contains it:

```ruby
def root
  if root_id = path.first
    self.class.find(root_id)
  else
    self
  end
end
```

That is, the first id in the path is the root of the tree. If there is one
(i.e. it's not an empty array), then look up the row with that primary key. If
the array is empty, we're already on the root node, so can just return
ourselves. Finding the parent of the current node is similar:

```ruby
def parent
  if parent_id = path.last
    self.class.find(parent_id)
  else
    nil
  end
end
```

The difference here is that if there's no parent, we return nil. We can also quickly find all the ancestors:

```ruby
def ancestors
  if path.present?
    self.class.where(id: path)
  else
    self.class.none
  end
end
```

Dead simple: load up the rows with the primary keys of all the ancestors. In
order to maintain consistency of always returning an `ActiveRecord::Relation` I
had to use the special 'null relation' here which, when executed, always
returns an empty set. Checking for siblings is straightforward, too; they have
the same path as the current node:

```ruby
def siblings
  self.class.where(path: path)
end
```

and direct children have the current node's path concatenated with its own id:

```ruby
def children
  self.class.where(path: path + [id])
end
```

The next one is a little more interesting. In order to find all the descendants
of a particular node (that is, the children, and the children's children and so
on) we're looking for any nodes that contain the current node's id anywhere
within its path. Fortunately, PostgreSQL has just such an operator, so we can
do:

```ruby
def descendants
  self.class.where(":id = ANY(path)", id: id)
end
```

### The N+1 Problem

There is a snag with all of this, though. While the individual queries are
simple, efficient, and hit indexes, they're not minimising the number of SQL
queries generated in the first place. Logically, in one of my views, I want to
display a nested list of the nodes and their children. In the controller I load
up the root nodes:

```ruby
def index
  @nodes = Node.roots
end
```

Then in my `app/views/nodes/index.html.erb` view, I'd like to do:

```erb
<ul>
  <%= render @nodes %>
</ul>
```

and in `app/views/nodes/_node.html.erb` I can simply do:

```erb
<li>
  <%= link_to node.name, node %>

  <% if node.children.present? %>
    <ul>
      <%= render node.children %>
    </ul>
  <% end %>
</li>
```

Nice, clean, tidy view code, right? The trouble is that it's got the classic
N+1 problem of SQL statements being generated: one to load the root nodes, and
one for each descendant of each root node! We could have retrieved all the
appropriate data with a single query, but that means reconstructing the tree
from a flat set of rows we got back from PostgreSQL. Doing that sort of thing
in the view would be hienous.

## In Theory

Here's what I'd like to do:

```ruby
@nodes = Node.roots.eager_load(:descendants)
```

which would load the root nodes, and would eager load all the descendant nodes.
It would be able to insert them into the `children` relation of each
appropriate node, and mark that relation as having already been loaded, just
like eager loading of associations that we're used to with ActiveRecord.

I have a sneaking suspicion that such a thing is possible. In fact, I suspect
that the machinery is already mostly in place, in
[`ActiveRecord::Associations::Preloader`](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/associations/preloader.rb).
So, a question: can it be done using the existing ActiveRecord code? If so, how?
