// A theme with one option of its own, in the importable shape a deck expects.
#import "@local/mosaic:0.0.3": (
  slide, note, fit, grids, steps, components, themes, layouts,
)
#import "@local/mosaic:0.0.3" as mosaic

#let base = mosaic.themes.default.definition

// `density` is the theme's own option. Mosaic knows nothing about it: the name
// simply becomes a named argument of the setup below, and its resolved value
// reaches `apply`.
#let seminar = base + (
  name: "Seminar",
  options: (density: "airy"),
  apply: (body, colors: (:), options: (:)) => {
    show: (base.apply).with(colors: colors, options: options)
    let airy = options.density == "airy"
    set par(leading: if airy { 0.9em } else { 0.5em })
    set list(spacing: if airy { 1.4em } else { 0.6em })
    set enum(spacing: if airy { 1.4em } else { 0.6em })
    body
  },
)

#let setup = themes.setup(seminar)
