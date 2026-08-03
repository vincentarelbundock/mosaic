#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grid.h(mosaic.grid.cell("a"), mosaic.grid.cell("b")),
  content: (a: [Only a]),
)
