#import "@local/mosaic:0.0.2" as mosaic

// A heading-policy key that is not a canonical decimal integer must report
// itself through fail() rather than aborting in a raw int() conversion.
#show: mosaic.setup.with(headings: ("two": "slide"))

= Section
