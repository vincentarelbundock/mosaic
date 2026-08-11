#import "@local/mosaic:0.0.2" as mosaic

#let layouts = (
  content: mosaic.layouts.content(variant: "header-body"),
  title: mosaic.layouts.title(),
  section: mosaic.layouts.section(),
)

#let apply(body, colors: (:), options: (:)) = {
  set text(font: "DejaVu Sans", size: 24pt)
  show label("mosaic-cell-header"): set text(fill: colors.canvas, weight: "bold")
  show label("mosaic-cell-header"): it => block(width: 100%, fill: colors.accent, it)
  show label("mosaic-cell-footer"): set text(fill: colors.muted)
  body
}

#let theme = (
  name: "Engine consumed",
  colors: (
    canvas: rgb("#f8f4ea"),
    surface: rgb("#fffdf8"),
    text: rgb("#17243a"),
    muted: rgb("#52657f"),
    line: rgb("#aeb9c8"),
    accent: rgb("#a23b72"),
    warning: rgb("#E69F00"),
    error: rgb("#D55E00"),
  ),
  defaults: (
    spacing: (inset: 32pt),
    cells: (footer: [ENGINE CONSUMED THEME]),
  ),
  layouts: layouts,
  apply: apply,
)

#show: mosaic.themes.setup(theme).with(
  title: [Passive theme definition],
)

#mosaic.slide(
  layout: "title",
)

== Engine owns setup

The theme supplies design values and native rules without importing setup internals.

*Semantic accent*

#mosaic.components.progress(variant: "line", width: 100%)

#context assert(counter(page).final().first() == 2)
