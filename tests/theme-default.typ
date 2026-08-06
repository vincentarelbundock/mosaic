#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.default as default-theme

#let shared = (
  "setup", "slide", "note", "surface",
  "grids", "layouts", "steps", "components",
)
#assert(shared.all(name => name in mosaic and name in default-theme))
#assert(mosaic.setup == default-theme.setup)
#assert(mosaic.slide == default-theme.slide)
#assert(mosaic.note == default-theme.note)
#assert(mosaic.steps.pause == default-theme.steps.pause)
#assert(mosaic.surface == default-theme.surface)
#assert(mosaic.grids == default-theme.grids)
#assert(mosaic.layouts == default-theme.layouts)
#assert(mosaic.steps == default-theme.steps)
#assert(mosaic.components == default-theme.components)

#show: default-theme.setup
#default-theme.slide[DEFAULT FACADE]
