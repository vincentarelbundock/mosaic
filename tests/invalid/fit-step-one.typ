#import "@local/mosaic:0.0.3" as m

#show: m.setup

// A step on the first frame adds no frame, and is lost in a fitted block all
// the same.
#m.slide[][
  #m.fit[#m.steps.on(1)[Lost]]
]
