---
published_on: 2014-11-19
title: Specifying Ruby on Rails Controllers with RSpec
subtitle: "Part 1: Query-style actions"
excerpt: |
  RSpec has come a long way since I last used it in anger. Today, I'm starting
  through a worked example on test-driving a Ruby on Rails controller with
  RSpec, Capybara feature specs, and plenty of mocking. Along the way, we'll
  see some neat new features of RSpec in action.
category: Programming
tags:
  - rails
  - ruby
  - rspec
  - test-driven development
  - behaviour-driven development
  - cucumber
  - capybara
  - unit testing
  - microtesting
---
To my mind, Ruby on Rails controllers are a simple beast in the
Model-View-Controller (MVC) pattern. They simply:

* take an HTTP action (`GET`, `POST`, `PUT` or `DELETE`) for a particular
  resource. The mapping between the HTTP verb, the resource, and the
  corresponding action is handled above the controller, at the routing layer.
  By the time it gets down to the controller, we already know what the desired
  action is, and we have an identifier for the resource, where applicable.

* communicate the intent of the action to the underlying model.

* return an appropriate response, whether that's rendering a template with
  particular information, or sending back an HTTP redirect.

There are two possibilities when it comes to communicating the intent of the
action to the underlying model:

* It can query the model for some information, usually to render it as an HTML
  page, or emit some JSON representation of the model; or

* it can send a command to the model, and return an indication of the success
  or failure of the command.

That's it. The controller is merely an orchestration layer for translating
between the language and idioms of HTTP, and the underlying model. I should
probably note at this point that the underlying model isn't necessarily just a
bunch of `ActiveRecord::Base`-inherited models, it can be composed of service
layers, aggregate roots, etc. The point is that the controllers are "just"
about communicating between two other parts of the system (at least that's how
I always interpreted Jamis Buck's famous [Skinny Controller, Fat Model](http://weblog.jamisbuck.org/2006/10/18/skinny-controller-fat-model)
post).

That's handy, because it makes them nice and easy to test. I've been brushing
up on [RSpec][] over the past couple of weeks, learning all about the new
syntax and features, and applying them to a couple of demo projects. I thought
I'd share what I'd learned about rspec in the form of a worked example.

We've got a requirement to keep track of Widgets. Widgets are pretty simple
things: they have a name, and they have a size in millimetres (you wouldn't
want to get different sized widgets mixed up!). Our client, who manufactures
these widgets, is looking for a simple web app where she can:

* list all widgets;

* create a new widget; and

* delete an existing widget.

We've been developing their in-house stock management system for a while, so
we've got an established Ruby on Rails project in which to hang the new
functionality. It's just going to be a case of extending it with a new model,
controller, and a couple of actions. And we're all set up with rspec, of
course. Better still, we're set up with [Guard][], too, so our tests run
automatically whenever we make a change. You can find the starting point of the
project on the [initial setup](https://github.com/mathie/widgets/tree/initial-setup) branch.

## Listing all the widgets

Let's start with an integration test. I like the outside-in flow of testing
that BDD encourages (in particular, the flow discussed in [The RSpec Book][]),
where we start with an integration test that roughly outlines the next feature
we want to build, then start fleshing out the functionality with unit tests.
So, our first scenario, in `spec/features/widgets_spec.rb`:

```ruby
RSpec.feature 'Managing widgets' do
  # All our subsequent scenarios will be inside this feature block.

  scenario 'Finding the list of widgets' do
    visit '/'

    click_on 'List Widgets'

    expect(current_path).to be('/widgets')
  end
end
```

I always like to start simple, and from the user's perspective. If I'm going to
manage a set of widgets, I need to be able to find the page from another
location. In this scenario, we're checking that there's a 'List Widgets' link
somewhere on the home page. It saves that embarrassing conversation with the
client where you've implemented a new feature, but she can't find it.

The first thing to note is that, by default, rspec now no longer creates global
methods, so Capybara's `feature` DSL method (and RSpec's `describe`, which
we'll see in a minute) are both defined on the RSpec namespace. Perhaps the
other thing to note is that I'm just using RSpec feature specs -- with
[Capybara][] for a nice DSL -- instead of Cucumber, which I've advocated in the
past? Why? It turned out that people rarely read my Cucumber stories, and those
that did could cope with reading code, too. RSpec features are more succinct,
consistent with the unit tests, and have fewer unwieldy overheads. You and your
team's mileage may, of course, vary!

Finally, there's rspec's new `expect` syntax. Instead of adding methods to a
global namespace (essentially, defining the `should` and `should_not` methods
on `Object`), you have to explicitly wrap your objects. So, where in rspec 2.x
and older, we'd have written:

```ruby
current_path.should eq('/widgets')
```

(which relies on a method called `should` being defined on your object) instead we now wrap the object under test with `expect`:

```ruby
expect(current_path).to eq('/widgets')
```

It still reads well ("expect current path to equal /widgets" as opposed to the
older version, "current path should equal /widgets"). Combined with the `allow`
decorator method, it also gives us a consistent language for mocking, which
we'll see shortly. To my mind, it also makes it slightly clearer exactly what
the object under test really is, since it's (necessarily) wrapped in
parentheses. I like the new syntax.

Let's just assume we've implemented this particular scenario, by inserting the following into `app/views/layouts/application.html.erb`:

```erb
<li><%= link_to 'List widgets', widgets_path %></li>
```

It does bring up the issue of routes, though: how to we specify that the list
of widgets is located at `/widgets`? Let's write a couple of quick specs to
verify the routes. I swither between testing routes being overkill or not. If
there is client side JavaScript relying on the contract that the routes
provide, I err on the side of specifying them. It's not too hard, anyway. So,
in `spec/routing/widgets_controller_routing_spec.rb` (what a mouthful, but it's
what [rubocop][] recommends):

```ruby
RSpec.describe 'WidgetsController' do
  it 'routes GET /widgets to widgets#index' do
    expect(get: '/widgets').to route_to('widgets#index')
  end

  it 'generates /widgets from widgets_path' do
    expect(widgets_path).to eq('/widgets')
  end
end
```

In order to make these specs pass, add the following inside the routes block in `config/routes.rb`:

```ruby
resources :widgets, only: [:index]
```

But one of our specs is still failing, complaining about the missing controller. Let's create an empty controller to keep it happy. Add the following to `app/controllers/widgets_controller.rb`:

```ruby
class WidgetsController < ApplicationController
end
```

We've still got a failing scenario, though -- because it's missing the index
action that results from clicking on the link to list widgets. Let's start to
test-drive the development of that controller action. This is what I describe
as a "query"-style action, in that the user is querying something about the
model and having the results displayed to them. In these query-style actions,
there are four things that typically happen:

* the controller asks the model for some data;

* it responds with an HTTP status of '200 OK';

* it specifies a particular template to be rendered; and

* it passes one or more objects to that template.

Let's specify the middle two for now. I've a feeling that will be enough to
make our first scenario pass. In `spec/controllers/widgets_controller_spec.rb`,
describe the desired behaviour:

```ruby
RSpec.describe WidgetsController do
  describe 'GET index' do
    def do_get
      get :index
    end

    it 'responds with http success' do
      do_get
      expect(response).to have_http_status(:success)
    end

    it 'renders the index template' do
      do_get
      expect(response).to render_template('widgets/index')
    end
  end
end
```

Defining a method to perform the action is just one of my habits. It doesn't
really add much here -- it's just replacing `get :index` with `do_get` -- but
it helps to remove repetition from testing other actions, and doing it here too
gives me consistency amongst tests. Now define an empty `index` action in
`WidgetsController`:

```ruby
def index
end
```

and create an empty template in `app/views/widgets/index.html.erb`. That's
enough to make the tests pass. Time to commit the code, and go grab a fresh
coffee.

Next up, let's specify a real scenario for listing some widgets:

```ruby
scenario 'Listing widgets' do
  Widget.create! name: 'Frooble', size: 20
  Widget.create! name: 'Barble',  size: 42

  visit '/widgets'

  expect(page).to have_content('Frooble (20mm)')
  expect(page).to have_content('Barble (42mm)')
end
```

Another failing scenario. Time to write some code. This time it's complaining
that the widgets we're trying to create don't have a model. Let's sort that out:

```bash
rails g model Widget name:string size:integer
```

We'll tweak the migration so neither of those columns are nullable (in our
domain model it isn't valid to have a widget without a name and a size)

```ruby
class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.string :name,  null: false
      t.integer :size, null: false

      t.timestamps null: false
    end
  end
end
```

Run `rake db:migrate` and we're good to go again. Our scenario is now failing
where we'd expect it to -- the list of widgets are not appearing on the page.
Let's think a bit about what we actually want here. Having discussed it with
the client, we're just looking for a list of all the Widgets in the system --
no need to think about complex things like ordering, or pagination. So we're
going to ask the model for a list of all the widgets, and we're going to pass
that to the template to be rendered. Let's write a controller spec for that
behaviour, inside our existing describe block:

```ruby
let(:widget_class) { class_spy('Widget').as_stubbed_const }
let(:widgets)      { [instance_spy('Widget')] }

before(:each) do
  allow(widget_class).to receive(:all) { widgets }
end

it 'fetches a list of widgets from the model' do
  do_get
  expect(widget_class).to have_received(:all)
end

it 'passes the list of widgets to the template' do
  do_get
  expect(assigns(:widgets)).to eq(widgets)
end
```

There are a few interesting new aspects to rspec going on here, mostly around
the test doubles (the general name for mocks, stubs, and spies). Firstly,
you'll see that stubbed methods, and expectations of methods being called, use
the new `expect`/`allow` syntax for consistency with the rest of your
expectations.

Next up is the ability to replace constants during the test run. You'll see
that we're defining a test double for the `Widget` class. Calling
`as_stubbed_const` on that class defines, for the duration of each test, the
constant `Widget` as the test double. In the olden days of rspec 2, we'd have
to either use dependency injection to supply an alternative widget
implementation (something that's tricky with implicitly instantiated
controllers in Rails), or we'd have to define a partial test double, where we
supply stubbed implementations for particular methods. This would be something
along the lines of:

```ruby
before(:each) do
  allow(Widget).to receive(:all) { widgets }
end
```

While this works, it is only stubbing out the single method we've specified;
the rest of the class methods on `Widget` are the real, live, implementations,
so it's more difficult to tell if the code under test is really calling what we
expect it to.

But the most interesting thing (to my mind) is that, in addition to the normal
mocks and stubs, we also have test spies. Spies are like normal test doubles,
except that they record how their users interact with them. This allows us, the
test authors, to have a consistent pattern for our tests:

* Given some prerequisite;

* When I perform this action;

* Then I have these expectations.

Prior to test spies, you had to set up the expectations prior to performing the
action. So, when checking that the controller asks the model for the right
thing, we'd have had to write:

```ruby
it 'fetches a list of widgets from the model' do
  expect(widget_class).to receive(:all)
  do_get
end
```

It seems like such a little thing, but it was always jarring to have some specs
where the expectations had to precede the action. Spies make it all more
consistent, which is a win.

We're back to having a failing test, so let's write the controller
implementation. In the `index` action of `WidgetsController`, it's as simple as:

```ruby
@widget = Widget.all
```

and finish off the implementation with the view template, in `app/views/widgets/index.html.erb`:

```erb
<h1>All Widgets</h1>

<ul>
  <%= render @widgets %>
</ul>
```

and, finally, `app/views/widgets/widget.html.erb`:

```erb
<%= content_tag_for :li, widget do %>
  <%= widget.name %> (<%= widget.size %>mm)
<% end %>
```

Our controller tests and our scenarios pass, time to commit our code, push to
production, pack up for the day and head to the pub for a celebratory beer! In
part 2, we'll drive out the behaviour of sending a command to the model, and
figuring out what to do based upon its response.

You can find a copy of the code so far on the [part 1 branch](https://github.com/mathie/widgets/tree/part-1) in GitHub. Once you've
had that celebratory beer, head across to [part 2](/articles/specifying-rails-controllers-with-rspec-part-2/) to continue our
exploration of RSpec while implementing a command-style action.

[rspec]: https://relishapp.com/rspec "RSpec is a Behaviour-Driven Development tool for Ruby programmers."
[the rspec book]: https://pragprog.com/book/achbd/the-rspec-book "Behaviour-Driven Development with RSpec, Cucumber, and Friends"
[capybara]: http://jnicklas.github.io/capybara/ "Test your app with Capybara"
[rubocop]: https://github.com/bbatsov/rubocop "A Ruby static code analyzer, based on the community Ruby style guide."
[guard]: http://guardgem.org "Guard is a command line tool to easily handle events on file system modifications."