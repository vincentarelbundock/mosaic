#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test

#let grid = mosaic.grid.h(
  gutter: 0.6em,
  mosaic.grid.t(2fr, "a"),
  mosaic.grid.t(1fr, mosaic.grid.v("b", "c")),
)

#assert(grid.kind == "split")
#assert(grid.axis == "width")
#assert(grid.tracks == (2fr, 1fr))
#assert(grid.gutter == 0.6em)
#assert(grid.children.at(0).kind == "cell")
#assert(grid.children.at(0).id == "a")
#assert(grid.children.at(0).content == none)
#assert(grid.children.at(1).kind == "split")
#assert(grid.children.at(1).axis == "height")
#assert(grid.children.at(1).tracks == (1fr, 1fr))
#assert(grid.children.at(1).children.at(0).id == "b")
#assert(grid.children.at(1).children.at(1).id == "c")
#assert(grid-test.count(grid) == 3)

#let native-tracks = mosaic.grid.h(
  mosaic.grid.t(auto, "auto"),
  mosaic.grid.t(4cm, "fixed"),
  mosaic.grid.t(25%, "ratio"),
  mosaic.grid.t(25% + 1cm, "relative"),
  mosaic.grid.t(2fr, mosaic.grid.cell(id: "fraction")),
)
#assert(native-tracks.tracks == (auto, 4cm, 25%, 25% + 1cm, 2fr))
#assert(native-tracks.children.map(child => child.id) == (
  "auto", "fixed", "ratio", "relative", "fraction",
))

// Cells carry structure and identity; appearance is supplied natively via
// each cell's <mosaic-cell-ID> label.
#let structural = mosaic.grid.cell("flat", inset: 4pt)
#assert(structural.id == "flat")
#assert(structural.content == none)
#assert(structural.style.inset == 4pt)
#let structural-command = mosaic.slide(layout: structural)[Body].value
#assert(structural-command.layout == structural)
#assert("cell-styles" not in structural-command.keys())

// Rules stroke the interior track boundaries of a split.
#assert(grid.rule == none)
#let ruled = mosaic.grid.h(rule: 0.6pt + red, gutter: 1em, "left", "right")
#assert(ruled.rule == 0.6pt + red)

#show: mosaic.setup
#mosaic.slide(layout: grid)[Main][Details][Notes]
#mosaic.slide(layout: mosaic.grid.v(
  rule: 0.5pt + blue,
  mosaic.grid.t(2fr, mosaic.grid.h(rule: 1pt + red, gutter: 1.5em, "a", "b", "c")),
  mosaic.grid.t(1fr, "d"),
))[A][B][C][D]
