#import "@local/mosaic:0.0.3" as mosaic

// A deck default does not take a cell out of the positional pool: the footer
// counts, so five bodies on a two-column header-body-footer layout is one
// more than its four cells.
#show: mosaic.setup.with(cells: (footer: [Deck footer]))
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body-footer", columns: 2),
)[Title][Left][Right][Footer][Extra]
