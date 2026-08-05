#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grids.h(mosaic.grids.cell("a"), mosaic.grids.cell("b")),
  content: (a: [Named]),
)[Positional]
