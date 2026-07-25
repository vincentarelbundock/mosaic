#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/grid-model.typ": styled-cell, apply-cell-styles

#let requested = (
  section: (
    align: left + horizon,
    fill: red,
    text: (fill: white),
  ),
)
#let command = mosaic.slide(
  grid: mosaic.templates.section(),
  cell-styles: requested,
)[Section].value
#assert(command.cell-styles == requested)

// Slide overrides replace surface fields and merge text fields over the
// template's typography rather than discarding its size and weight.
#let base = styled-cell(
  "section",
  style: (
    inset: 20pt,
    align: center + horizon,
    fill: white,
    text: (size: 30pt, weight: "bold", fill: black),
  ),
)
#let resolved = apply-cell-styles(base, requested)
#assert(resolved.style.inset == 20pt)
#assert(resolved.style.align == left + horizon)
#assert(resolved.style.fill == red)
#assert(resolved.style.text == (size: 30pt, weight: "bold", fill: white))

#set page(width: 240pt, height: 135pt, margin: 0pt)
#show: mosaic.setup
#mosaic.slide(
  grid: mosaic.templates.section(),
  cell-styles: requested,
)[Section]