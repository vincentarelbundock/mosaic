#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grid.h(
    mosaic.grid.cell("logo", content: [LOGO]),
    mosaic.grid.cell("body"),
  ),
  content: (logo: [Nope], body: [Body]),
)
