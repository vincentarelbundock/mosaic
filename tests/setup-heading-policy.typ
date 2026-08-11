// A document whose hierarchy puts sections at `==` and slides at `===`
// compiles on its own heading levels rather than on Mosaic's default two.
#import "@local/mosaic:0.0.2" as mosaic

#show: mosaic.setup.with(headings: ("2": "section", "3": "slide"))

== Methods

Tagline under the section.

=== Estimation

Body of the first slide.

=== Inference

Body of the second slide.

// One section slide plus two content slides.
#context assert(counter(page).final().first() == 3)
