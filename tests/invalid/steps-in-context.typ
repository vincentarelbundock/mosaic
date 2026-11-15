#import "@local/mosaic:0.0.3" as m

#show: m.setup

// A context block hides its content from the walk that resolves steps.
#m.slide[][
  Lead
  #context { m.steps.on(2)[Hidden from the runtime] }
]
