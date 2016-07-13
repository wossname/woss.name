---
published_on: 2012-04-30
title: Shower Power
redirect_from: "/2012/04/30/shower-power/"
category: Programming
tags:
  - modelling
  - javascript
  - abstraction
  - telling stories
  - principles
  - immediacy
---
A few weeks ago, I watched a talk from CUSEC 2012 by [Bret Victor](http://worrydream.com/) called [Inventing on Principle](http://www.youtube.com/watch?v=PUv66718DII) where he described the principle by which he lives his life. You should go watch the talk now, it's awesome. I'll wait.

Done? Wasn't it a great talk? That thing with the game, and the future paths of the character … wasn't that just awesome? I got a bit lost on the overall point of the talk (*you* should have a guiding principle and *you* should live your life by it), because I loved Bret's guiding principle; the whole idea of immediate connections really resonated with me.

Then I realised another thing that'd been on my todo list to read (because it was too beautiful to shove into Instapaper) was Bret's work too: [Up and Down the Ladder of Abstraction](http://worrydream.com/LadderOfAbstraction/). It's all about gaining a deeper understanding of a concept by exploring it at different levels of abstraction. But again, skipping the point itself, take a look at *and interact with* the examples. Instead of some dry, boring graphs, or even some sexy (but meaningless) infographics, there are visualisations of the model that you can play with. And playing with these models helps you properly understand how variables interact, helping you to deeply understand the model.

Then I read another of his articles, the [Scrubbing Calculator](http://worrydream.com/ScrubbingCalculator/) and something went *ping* in my head. (More on that another day, perhaps.)

I had to try it out on a wee project. It turns out that Bret also has a Javascript library called [Tangle](http://worrydream.com/Tangle/) which helps you to create "reactive" documents. These reactive documents allow you to create a narrative flow around a model, letting users pick numbers from the model and change them (by dragging), which is then immediately reflected throughout the rest of the narrative. So the readers of your document get instant feedback on the impact of changing the input values on your model. That's kinda cool.

As it happens, my son had spent … rather a long time in the shower that morning. We had a wee bit of a "discussion" about the money that was being wasted, but I wasn't really able to communicate the consequences effectively ("it must be costing a fortune!", I said to my wife, Annabel). Aha, I have my model. And so [Shower Power](http://shower-power.herokuapp.com/) was born.

It took me a wee while to research the model and understand how to get from "Malcolm spends 30 minutes in the shower" to "which costs £0.61". Either I wasn't paying attention in Standard Grade Physics at school, or I haven't used those brain cells in the intervening 18 years. (Was it really that long ago?!) I got there in the end, and I've outlined the algorithm on the [about page](http://shower-power.herokuapp.com/about).

It works, and I rather like it. [Have a play around](http://shower-power.herokuapp.com/) and let me know what you think? I like the idea that there's some narrative around it, rather than it just being a table of numbers. Given a little bit more thought, the narrative could be better crafted to bubble the important variables closest to the top, and defer the rarely used ones further down. I particularly like that it's not just numbers you can change, but discrete options too (e.g. how often you shower).

With the people I tested it on, it clearly wasn't obvious that you could pick an underlined number and drag it to change the effect – maybe a bit of signposting with [guiders.js](https://github.com/jeff-optimizely/Guiders-JS) would have helped there?

I was particularly surprised by one of the variables in the model: *it doesn't matter what temperature your boiler heats the water to* (well, it has to be higher than the desired shower temperature!). If I hadn't played around with the model in this way, I'd never have noticed that – in fact, I spent a couple of hours debugging why changing that value didn't change the results! So now we set the boiler temperature that bit lower, to reduce the chances of scalding from hot taps.

Anyway, it was a fun experiment, and I'm quite pleased with the results.

I'm feeling inspired to build something awesome (I'd tell you, but … bad experiences with that in the past … let me build an MVP first) with this sort of idea in mind. What do you reckon? Could be awesome? Crazy? Just a bit meh?

(Coming soon, a follow up post on how I built what is effectively a single-page static site with Rails (because when your only tool is a hammer, everything is a thumb) and how I used it as an excuse to explore the asset pipeline, efficient client side caching and CDNs.)
