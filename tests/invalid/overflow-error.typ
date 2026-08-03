#import "@local/mosaic:0.0.1" as mosaic

// "error" reports the same records "warn" queries, but from a context where
// introspection has converged, so the slide number it names is the one the
// author can navigate to. Slide 2 is the offender here, not slide 1.
#show: mosaic.setup.with(overflow: "error")

#mosaic.slide[Fits.]
#mosaic.slide[#lorem(200)]
