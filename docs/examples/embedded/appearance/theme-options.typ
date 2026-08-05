#import "@local/mosaic:0.0.1" as mosaic

// `options` declares choices Mosaic knows nothing about. Each name becomes a
// named argument of the setup this definition produces, and the resolved values
// reach both `layouts` and `apply`.
#let seminar = (
  name: "Seminar",
  colors: mosaic.themes.light-palette + (accent: rgb("#0f766e")),
  options: (density: "airy"),
  layouts: options => (
    content: mosaic.layouts.content(
      variant: if options.density == "airy" { "header-body" } else { "header-body-footer" },
    ),
    title: mosaic.layouts.title(),
    section: mosaic.layouts.section(),
  ),
  apply: (body, colors: (:), options: (:)) => {
    set text(size: if options.density == "airy" { 26pt } else { 20pt })
    show heading: set text(fill: colors.accent)
    body
  },
)

#show: mosaic.themes.setup(seminar).with(density: "dense")

#mosaic.slide(layout: mosaic.layouts.content(variant: "header-body"))[
  One theme, two densities
][
  `density` is the theme's own option, not a Mosaic setting. It reaches
  `layouts` and `apply` together, so a single word changes both the type scale
  and which content layout the deck uses.
]
