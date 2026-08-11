#import "@local/mosaic:0.0.2" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grids.cell("body"),
  cells: (body: [Body], background: [Nope]),
)
