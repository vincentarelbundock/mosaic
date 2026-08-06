#import "@preview/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test

#let grid = mosaic.grids.columns(
  gutter: 0.6em,
  mosaic.grids.track(2fr, "a"),
  mosaic.grids.track(1fr, mosaic.grids.rows("b", "c")),
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

#let native-tracks = mosaic.grids.columns(
  mosaic.grids.track(auto, "auto"),
  mosaic.grids.track(4cm, "fixed"),
  mosaic.grids.track(25%, "ratio"),
  mosaic.grids.track(25% + 1cm, "relative"),
  mosaic.grids.track(2fr, mosaic.grids.cell(id: "fraction")),
)
#assert(native-tracks.tracks == (auto, 4cm, 25%, 25% + 1cm, 2fr))
#assert(native-tracks.children.map(child => child.id) == (
  "auto", "fixed", "ratio", "relative", "fraction",
))

// Cells carry structure and identity; appearance is supplied natively via
// each cell's <mosaic-cell-ID> label.
#let structural = mosaic.grids.cell("flat", inset: 4pt)
#assert(structural.id == "flat")
#assert(structural.content == none)
#assert(structural.style.inset == 4pt)
#let structural-command = mosaic.slide(layout: structural)[Body].value
#assert(structural-command.layout == structural)
#assert("cell-styles" not in structural-command.keys())

// Rules stroke the interior track boundaries of a split.
#assert(grid.stroke == none)
#let ruled = mosaic.grids.columns(stroke: 0.6pt + red, gutter: 1em, "left", "right")
#assert(ruled.stroke == 0.6pt + red)

#show: mosaic.setup
#mosaic.slide(layout: grid)[Main][Details][Notes]
#mosaic.slide(layout: mosaic.grids.rows(
  stroke: 0.5pt + blue,
  mosaic.grids.track(2fr, mosaic.grids.columns(stroke: 1pt + red, gutter: 1.5em, "a", "b", "c")),
  mosaic.grids.track(1fr, "d"),
))[A][B][C][D]
