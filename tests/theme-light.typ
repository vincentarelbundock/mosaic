#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as light

#let shared = (
  "setup", "slide", "note", "pause", "surface",
  "grid", "layouts", "steps", "components", "theme",
)
#assert(shared.all(name => name in mosaic and name in light))
#assert(mosaic.setup == light.setup)
#assert(mosaic.slide == light.slide)
#assert(mosaic.note == light.note)
#assert(mosaic.pause == light.pause)
#assert(mosaic.surface == light.surface)
#assert(mosaic.grid == light.grid)
#assert(mosaic.layouts == light.layouts)
#assert(mosaic.steps == light.steps)
#assert(mosaic.components == light.components)
#assert(mosaic.theme == light.theme)

#show: light.setup
#light.slide[LIGHT FACADE]
