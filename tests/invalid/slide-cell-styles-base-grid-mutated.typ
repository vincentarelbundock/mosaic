#import "@local/mosaic:0.0.1" as mosaic

#let command = mosaic.slide(
  grid: mosaic.grid.cell("body"),
  cell-styles: (body: (inset: 2em)),
)[Body]
#let value = command.value
#let grid = value.grid
#let style = grid.style
#style.remove("inset")
#grid.insert("style", style)
#value.insert("grid", grid)
#let mutated = metadata(value)

#show: mosaic.setup
#mutated