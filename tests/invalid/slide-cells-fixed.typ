#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grids.columns(
    mosaic.grids.cell("logo", content: [LOGO]),
    mosaic.grids.cell("body"),
  ),
  cells: (logo: [Nope], body: [Body]),
)
