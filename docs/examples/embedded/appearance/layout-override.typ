#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as m

#import "_tour-deck.typ": deck

// A section slide of our own: a rule across the top, the title beneath it.
#let chapter = m.grids.rows(
  m.grids.track(auto, m.grids.cell("rule", content: line(length: 100%, stroke: 3pt))),
  "section",
)

#show: m.setup.with(
  layouts: (
    title: m.layouts.title(variant: "bordered"),
    section: chapter,
  ),
)

#deck(m)
