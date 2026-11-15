// Canonical passive Default definition.
//
// Mosaic's engine emits no typography at all, so a theme states its complete
// look here: base type, headings, captions, list rhythm, and the canonical
// <mosaic-cell-*> vocabulary that the layouts compose against. Default is the
// plainest complete statement of that set, which makes it the file to copy
// when starting a theme from scratch. Its quietness is deliberate: the other
// bundled themes are voices, and this one is the absence of one.
//
// Default has no dark twin. A deck flips it by passing a dark palette through
// `setup(colors: ..)`; every rule below paints from `colors.*`, and the one
// asset that cannot (the syntax highlighting theme) branches on the canvas.
#import "../../palettes.typ": light
#import "../../component/api.typ" as components
#import "../polarity.typ": is-dark-canvas, dark-code-theme
#import "layouts.typ" as layouts

#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  // The accent stays functional: links, list markers, and the section
  // baseline rule carry it, and nothing decorative does.
  set list(spacing: 0.8em, marker: text(fill: colors.accent)[•])
  set enum(spacing: 0.8em)
  set terms(spacing: 0.8em)
  set table(stroke: 0.8pt + colors.line)
  set raw(theme: dark-code-theme) if is-dark-canvas(colors)
  // Heading sizes are multiples of the deck's base size, not em values. An
  // em size would multiply with Typst's native per-level heading scale, which
  // follows the resolved level, so the same `==` heading would shrink under
  // `set heading(offset: 1)`. An absolute size replaces the whole chain.
  show heading.where(depth: 1): set text(size: base-size * 2.8, weight: "semibold")
  show heading.where(depth: 2): set text(size: base-size * 1.68, weight: "semibold")
  show heading: set block(below: 1em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show link: set text(fill: colors.accent)
  show label("mosaic-title-display"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: 2em, weight: "semibold")
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.62em, fill: colors.muted)
  body
}

#let definition = (
  name: "Default",
  colors: light,
  defaults: (
    // Designed face first, then the best slide sans each platform ships by
    // default, then the Linux workhorse, ending in Libertinus Serif. Typst
    // embeds no sans at all, so the terminal is a serif and some name here
    // is always unknown: it warns once per unknown family even when a later
    // one resolves, which is the price of rendering as designed anywhere.
    font: (
      "Inter",
      "Source Sans 3",
      "Avenir Next",
      "Segoe UI",
      "DejaVu Sans",
      "Libertinus Serif",
    ),
    base-size: 28pt,
    // The progress ring in the corner of every numbered slide, the one piece
    // of furniture the quiet theme carries. It resolves its colors from the
    // deck record, so a palette swap recolors it too, and the component
    // quiets itself on unnumbered pages such as titles.
    // Chrome, not content: the artifact wrapper keeps it out of the tagged
    // PDF's structure tree, so a screen reader never announces it.
    foreground: pdf.artifact(place(bottom + right, block(
      inset: (right: 18pt, bottom: 14pt),
      text(size: 0.55em, components.progress(variant: "circle")),
    ))),
  ),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
