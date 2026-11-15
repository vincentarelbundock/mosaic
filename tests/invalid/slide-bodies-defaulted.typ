#import "@local/mosaic:0.0.3" as mosaic

// A deck footer default does not change the count positional bodies accept:
// the footer is never filled positionally, so four bodies on a two-column
// header-body-footer layout is one too many.
#show: mosaic.setup.with(cells: (footer: [Deck footer]))
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body-footer", columns: 2),
)[Title][Left][Right][Footer]
