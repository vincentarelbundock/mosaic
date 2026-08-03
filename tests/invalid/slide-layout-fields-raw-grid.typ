#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(layouts: (
  content: mosaic.grid.v("header", "body"),
  title: mosaic.layouts.title(),
  section: mosaic.layouts.section(),
))
#mosaic.slide(columns: 2)[Left][Right]
