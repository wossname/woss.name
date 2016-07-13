---
published_on: 2011-01-27
title: Using SagePay in your Ruby Projects
redirect_from: "/2011/01/27/using-sagepay-in-your-ruby-projects/"
category: Programming
tags:
  - ruby
  - rails
  - sagepay
  - protx
  - active_merchant
  - payment
  - gem
---
Once upon a time, in a galaxy far, far away ... Ok, I'll stop now. A few years back, I was working on a client project and they needed to integrate with a billing platform. They'd already picked Protx (now [SagePay](http://www.sagepay.com/)) as their platform of choice, and in particular, the Server variant. Wait, I'll backtrack. SagePay has three variants:

* **Form** which is basically just sticking a random form/button on your web page that redirects to SagePay's servers and redirects back afterwards. Useful if your budget is low, you don't have a web developer on hand and your requirements are utterly trivial.

* **Server** which is more full featured, and allows much finer control of the billing process, including delayed billing, recurring subscriptions, that kind of thing.  It's a little more involved, but you still don't capture the credit card details themselves (that is still a redirect step to SagePay's servers) so you get to sidestep the painful parts of PCI-DSS compliance. Which you want to do, unless you have a bucketload of money and want to be labelled clinically insane.

* **Direct** which involves you doing the store/forward of the credit card details. Its the ultimate in flexibility and doesn't tie you to SagePay in the long term (say, because they have all the CC numbers for your recurring payments!). Choosing this option, however, is one of the criteria for free entry to the PCI DSS loony bin.

I'd previously built an integration for a client with Protx Form, and had modified [ActiveMerchant](http://www.activemerchant.org/) to support it ([forked here](https://github.com/rubaidh/active_merchant/tree/feature/protx-vsp-form-integration), not that the patch ever got merged, but n'mind). So, naturally, the second time, I reached for ActiveMerchant again and started hacking away. Unfortunately, SagePay Server's model doesn't really work with ActiveMerchant because it's half way between an integration and a gateway. We struggled on and got that working (see [this fork here](https://github.com/rubaidh/active_merchant/tree/feature/protx-vsp-server-integration)). (That patch was never merged back upstream either, but I'm less surprised by that.)

Fast forward a couple of years, and another client wants an integration with SagePay. Their requirements are more complex in that its a SaaS offering which requires flexible recurring billing, so the Server version definitely fits well. But this time I've decided for sure that AM is not a good fit.

So we start from scratch and model SagePay Server's API natively in Ruby. The [sage_pay](https://github.com/mathie/sage_pay) gem is the result of our efforts. There's also an [example Rails application](https://github.com/mathie/sage_pay_rails_example) using most of it's features just so you can see what's happening. Its all available under a liberal license, so you're free to do what you like with it. I'd love to here from you if you use it. I'd also be utterly delighted to accept patches and improvements.

* Grab the source on GitHub: <https://github.com/mathie/sage_pay>

* Grab the source to the [example Rails application](https://github.com/mathie/sage_pay_rails_example).

* Install from [Rubygems](http://rubygems.org/gems/sage_pay): `gem install sage_pay`

Documentation is a little sparse so far, so your best bet is to check out the sample app and work from there. I'd be particularly happy to accept pull requests that contain documentation. ;-)

(Oh, and while I'm on the subject of ActiveMerchant forks that never made it back upstream, here's one for [Barclays ePDQ](https://github.com/rubaidh/active_merchant/tree/feature/barclaycard-integration) too.)
