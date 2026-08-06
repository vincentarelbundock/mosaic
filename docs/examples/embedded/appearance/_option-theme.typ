// A theme with one option of its own, in the importable shape a deck expects.
#import "@preview/mosaic:0.0.1": (
  slide, note, fit, surface, grids, steps, components, themes, layouts,
)
#import "@preview/mosaic:0.0.1" as mosaic

#let base = mosaic.themes.default.definition

// `density` is the theme's own option. Mosaic knows nothing about it: the name
// simply becomes a named argument of the setup below, and its resolved value
// reaches `apply`.
#let seminar = base + (
  name: "Seminar",
  options: base.options + (density: "airy"),
  apply: (body, colors: (:), options: (:)) => {
    let size = if options.density == "airy" { 30pt } else { 22pt }
    show: (base.apply).with(colors: colors, options: options + (base-size: size))
    body
  },
)

#let setup = themes.setup(seminar)
