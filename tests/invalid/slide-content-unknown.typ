#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grid.cell("body"),
  content: (body: [Body], sidebar: [Nope]),
)
