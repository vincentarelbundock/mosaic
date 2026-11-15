#import "@local/mosaic:0.0.3" as mosaic

// Positional bodies do not reach a cell with a deck default: the footer is
// addressed by name, and the diagnostic lists the cells bodies do fill.
#show: mosaic.setup.with(cells: (footer: [Deck footer]))
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body-footer", columns: 2),
)[== Title][Left][Right][Footer]
