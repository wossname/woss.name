---
published_on: 2014-11-20
title: Specifying Ruby on Rails Controllers with RSpec
subtitle: "Part 2: Command actions"
category: Software development
tags:
  - ruby
  - rails
  - rspec
  - mocking
  - capybara
  - testing
  - test-driven development
  - behaviour-driven development
---

Back in [part 1](/articles/specifying-rails-controllers-with-rspec/),
we had a look at some of the new features of RSpec, and we used those features
to create a query-style controller action. In particular, it listed out all the
widgets in our inventory management system. This time around, we're going to
look at a command-style action: creating a new widget.

What do I mean by a "command"-style action, though? I think of these as the
kinds of actions where the user is telling the system to do something: create a
widget, delete a widget, or send an email, for example. There might be a more
complex workflow, too: creating a new user, adding them to an announcement
mailing list, and sending them an activation email to confirm their address.
That sort of behaviour could be encapsulated by a service object which performs
all the actions associated with the business requirements for creating a new
user.

They still follow a common pattern:

* the controller looks up the model on which an action has to be performed, if
  appropriate;

* then it tells the model to perform that action, noting the success or failure
  of the action.

Then we branch in two, depending on whether the model operation was successful. If it was:

* redirect to another action -- often the canonical url for the resource;
  and

* set a flash message to let the user know that the operation completed successfully.

If the operation wasn't successful, then:

* respond with an appropriate HTTP response code. Somewhat counterintuitively, if this is a web-based form a human is filling in, it will be a `200 OK`. If it's an API, then return an appropriate 4xx response code.

* re-render the template the user didn't fill in correctly, passing the appropriate object(s) to that template.

Let's see this in action. We'll start out by writing an integration test for creating widgets. First of all, let's make sure we can find the button:

```ruby
scenario 'finding the "new widget" button' do
  visit '/widgets'

  click_on 'New widget'

  expect(current_path).to eq('/widgets/new')
end
```

and implement that by adding the appropriate link on the widget listing page:

```erb
<%= link_to 'New widget', new_widget_path %>
```

Now our tests are failing all over the place, complaining about `new_widget_path` not existing. We should write a couple of routing specs to check that works:

```ruby
it 'routes GET /widgets/new to widgets#new' do
  expect(get: '/widgets/new').to route_to('widgets#new')
end

it 'generates /widgets from widgets_path' do
  expect(widgets_path).to eq('/widgets')
end

it 'generates /widgets/new from new_widget_path' do
  expect(new_widget_path).to eq('/widgets/new')
end
```

and, finally, changing the line in `config/routes.rb` to include the new action, too:

```ruby
resources :widgets, only: [:index, :new]
```

Running our tests reveals that all the other tests are back to passing again (phew!), but that our scenario is still failing, this time because the `new` action is missing. Let's start test-driving the implementation of that. The `new` action is just another query-style action, so I'll gloss over it quickly:

```ruby
describe 'GET new' do
  let(:widget) { instance_spy('Widget') }

  before(:each) do
    allow(widget_class).to receive(:new) { widget }
  end

  def do_get
    get :new
  end

  it 'builds a new widget from the model' do
    do_get
    expect(widget_class).to have_received(:new)
  end

  it 'responds with http success' do
    do_get
    expect(response).to have_http_status(:success)
  end

  it 'renders the new template' do
    do_get
    expect(response).to render_template('widgets/new')
  end

  it 'passes the new widget to the template' do
    do_get
    expect(assigns(:widget)).to eq(widget)
  end
end
```

You start to get a feel for the pattern, right? It all fits in a screenful of
code, too. The one other change I made was to pull the stubbing of the `Widget`
class out into the enclosing describe block, so it's available to every nested
describe block.

I have a confession to make here. The point of test-driven development is that
you write a single failing test, then write just enough code to make that test
pass. Wash, rinse, repeat. However, I did just write all four of these tests at
once, resulting in four failing tests. The thing with rules is knowing when
it's OK to break them, right? In this case, I already know the implementation is trivial, with the following `new` action:

```ruby
def new
  @widget = Widget.new
end
```

and the view in `app/views/widgets/new.html.erb`:

```erb
<h1>New Widget</h1>

<%= render 'form', widget: @widget %>
```

and, finally, the form in `app/views/widgets/_form.html.erb`:

```erb
<%= form_for widget do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :size %>

  <%= f.submit %>
<% end %>
```

(I still love that you can express forms so simply, while using a `FormBuilder`
subclass to express the tricky HTML gymnastics required to make forms look
pretty.) If it turns out that I'd been over-eager, and I still had failing
tests at this point, I'd backtrack a bit, remove (or comment out) some of the
tests, and choose a smaller thing to make the tests pass. But it turns out
that's enough to make our controller tests pass, and the initial scenario
passes, too. Time for a coffee, then onto the real meat: the `create` action.

We'll start with the happy case: a correctly entered, valid, widget:

```ruby
scenario 'creating a new widget with valid inputs' do
  visit '/widgets/new'
  within '#new_widget' do
    fill_in 'Name', with: 'Bazzle'
    fill_in 'Size', with: '54'
  end
  click_on 'Create Widget'

  expect(current_path).to eq('/widgets')
  expect(page).to have_content('New widget successfully created.')
end
```

Capybara has a nice, expressive, DSL doesn't it? I'd like to think that a
non-programmer could -- with some effort -- read and understand what's going
on. (But I'm a programmer, and it's pretty much my natural language, so I might
be way off!)

The scenario is failing, because it can't find the appropriate routes. Let's write a test for that route (the url generation for `widgets_path` has already been covered):

```ruby
it 'routes POST /widgets to widgets#create' do
  expect(post: '/widgets').to route_to('widgets#create')
end
```

So now we modify the routes to include the create action:

```ruby
resources :widgets, only: [:index, :new, :create]
```

and our integration test is now pointing at the next place we need to work on: the create action is missing. Let's write some tests for the common behaviour between the happy path and the error case:

```ruby
describe 'POST create' do
  let(:widget) { instance_spy('Widget', persisted?: true) }
  let(:widget_params) { { name: 'Widget', size: '10' } }
  let(:params) { { widget: widget_params } }

  before(:each) do
    allow(widget_class).to receive(:create) { widget }
  end

  def do_post(params = params)
    post :create, params
  end

  it 'attempts to create a new widget' do
    do_post
    expect(widget_class).to have_received(:create).with(widget_params)
  end

  it 'filters invalid data from the request parameters' do
    do_post params.merge(invalid: 'data')
    expect(widget_class).to have_received(:create).with(widget_params)
  end

  it 'checks to see if the operation was a success' do
    do_post
    expect(widget).to have_received(:persisted?)
  end
end
```

It turns out that the controller has an additional responsibility after all. As
of Rails 4.mumble it now figures out which parameters are valid for this
request, so we've got a wee spec in there to make sure it's filtering out
invalid (or malicious) data.

There's a (perfectly valid) argument against stubbing out the behaviour
underneath the controller here. What happens when you stub out the
implementation you expect, write just enough code to make the tests pass, then
discover it doesn't work in production because the behaviour you stubbed out
doesn't actually exist? In the example above, how do I *know* that there's a
`Widget.create` method that takes a hash? Fortunately, RSpec 3 has our backs,
with "verifying doubles". These doubles will, if the object they're standing in
for exists, verify that there really is a method which takes the same number of
arguments. Lets fat-finger our before block:

```ruby
before(:each) do
  allow(widget_class).to receive(:carrot) { widget }
end
```

Running our tests reveals our mistake:

```bash
1) WidgetsController POST create checks to see if the operation was a success
   Failure/Error: allow(widget_class).to receive(:carrot) { widget }
     Widget does not implement: carrot
   # ./spec/controllers/widgets_controller_spec.rb:84:in `block (3 levels) in <top (required)>'
   # -e:1:in `<main>'
```

The slight snag is that the object being stubbed needs to be around when it is
being stubbed, so that rspec can verify the methods really exist. In practice,
this means that you'll only see this sort of feedback when you run your entire
test suite, but not necessarily when (for example) Guard is only running the
tests that have changed. Still, it's useful feedback, and another great feature
from RSpec 3!

So, what happens on the happy path?

```ruby
describe 'when the widget is valid' do
  before(:each) do
    allow(widget).to receive(:persisted?) { true }
  end

  it 'redirects back to the list of widgets' do
    do_post
    expect(response).to redirect_to(widgets_path)
  end

  it 'sets a flash message' do
    do_post
    expect(flash.notice).to eq('New widget successfully created.')
  end
end
```

The before block here is unnecessary -- we've already stubbed out the
`persisted?` method to return true -- but it helps me to make the context of
the describe block explicit. Let's be bold and write some tests for the failure case, too:

```ruby
describe 'when the widget is invalid' do
  before(:each) do
    allow(widget).to receive(:persisted?) { false }
  end

  it 'renders the new template' do
    do_post
    expect(response).to render_template('widgets/new')
  end

  it 'assigns the faulty widget to the view' do
    do_post
    expect(assigns(:widget)).to eq(widget)
  end
end
```

and we can write a simple implementation:

```ruby
def create
  @widget = Widget.create(widget_params)
  if @widget.persisted?
    redirect_to widgets_path, notice: 'New widget successfully created.'
  else
    render 'new'
  end
end

private
def widget_params
  params.require(:widget).permit(:name, :size)
end
```

Done, our unit tests are passing and, better still, it's been enough to make
the integration test pass, too! Winning. :) Time to commit, push to production,
and treat ourselve to a takeout pizza for dinner. As with part 1, you can find
the code on GitHub, on the [part 2 branch](https://github.com/mathie/widgets/tree/part-2). Tomorrow, let's have a
look at how to test our model -- right now, since we don't have an integration
test to demonstrate it, we don't know that widgets without a name do the right
thing (I can honestly say I haven't tried this project in the browser, but I'm
confident that submitting a widget without a name is going to raise an
exception, which isn't the sort of behaviour our client would like.)
