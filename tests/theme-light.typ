#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as light

#let shared = (
  "setup", "slide", "note", "surface",
  "grids", "layouts", "steps", "components",
)
#assert(shared.all(name => name in mosaic and name in light))
#assert(mosaic.setup == light.setup)
#assert(mosaic.slide == light.slide)
#assert(mosaic.note == light.note)
#assert(mosaic.steps.pause == light.steps.pause)
#assert(mosaic.surface == light.surface)
#assert(mosaic.grids == light.grids)
#assert(mosaic.layouts == light.layouts)
#assert(mosaic.steps == light.steps)
#assert(mosaic.components == light.components)

#show: light.setup
#light.slide[LIGHT FACADE]
