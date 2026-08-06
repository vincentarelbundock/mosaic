#import "@preview/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grids.columns(
    mosaic.grids.cell("logo", content: [LOGO]),
    mosaic.grids.cell("body"),
  ),
  cells: (logo: [Nope], body: [Body]),
)
