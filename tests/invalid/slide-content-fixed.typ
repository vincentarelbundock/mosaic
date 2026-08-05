#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grids.h(
    mosaic.grids.cell("logo", content: [LOGO]),
    mosaic.grids.cell("body"),
  ),
  content: (logo: [Nope], body: [Body]),
)
