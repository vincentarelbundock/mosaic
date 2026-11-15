#import "@local/mosaic:0.0.3" as m

#show: m.setup

// The pause belongs to the second item, where it splits nothing.
#m.slide[][
  - One
  - Two #m.steps.pause
  - Three
]
