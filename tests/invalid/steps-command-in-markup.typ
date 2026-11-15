#import "@local/mosaic:0.0.3" as m

#show: m.setup

// A body that is not content is a drawing command, which means something
// only to `steps.drawing`. Written in a slide it used to print its record.
#m.slide[][
  Lead #m.steps.on(2, "text")
]
