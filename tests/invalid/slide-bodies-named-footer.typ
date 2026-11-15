#import "@local/mosaic:0.0.3" as mosaic

// A footer named in cells: leaves header and body for positional bodies, so a
// third body is one too many; the message lists the cells that remain.
#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body-footer"),
  cells: (footer: [Source]),
)[Title][Body][Extra]
