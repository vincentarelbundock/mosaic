#import "@preview/mosaic:0.0.1" as m

#show: m.setup
// Fitting hides its body from the runtime's incremental walk, so a reveal
// inside one would silently collapse into a single frame.
#m.slide[#m.fit[A #m.steps.pause B]]
