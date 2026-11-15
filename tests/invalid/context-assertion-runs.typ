#import "@local/mosaic:0.0.3" as mosaic

// Fixtures assert through `context` blocks written in automatic slides. This
// one must fail: if the deck compiler ever drops such a block again, every
// in-file assertion in the suite goes silent with it.
#show: mosaic.setup

== Slide

Body.

#context { assert(false, message: "context assertion ran") }
