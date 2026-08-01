#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#mosaic.slide(
  grid: mosaic.grid.h(mosaic.grid.cell("a"), mosaic.grid.cell("b")),
  cells: (a: [Only a]),
)
