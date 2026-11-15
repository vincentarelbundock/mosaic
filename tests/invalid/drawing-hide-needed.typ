#import "@local/mosaic:0.0.3" as m

#show: m.setup

// The default state outside a range is "hidden", which only the drawing
// library can draw.
#m.slide[][
  #m.steps.drawing(render: commands => commands.join(", "), "base", m.steps.on(2, "later"))
]
