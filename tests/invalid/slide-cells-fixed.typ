#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#mosaic.slide(
  grid: mosaic.grid.h(
    mosaic.grid.cell("logo", content: [LOGO]),
    mosaic.grid.cell("body"),
  ),
  cells: (logo: [Nope], body: [Body]),
)
