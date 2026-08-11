#import "@local/mosaic:0.0.2" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grids.columns(mosaic.grids.cell("a"), mosaic.grids.cell("b")),
  cells: (a: [Named]),
)[Positional]
