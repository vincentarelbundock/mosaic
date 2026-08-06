// Everything main.typ imports: the shared Mosaic API and a deck-local Mosaic
// theme.
//
// The theme re-creates the look of the Clean theme for
// Touying and Quarto (https://github.com/kazuyanagimoto/quarto-clean-typst,
// MIT): light Roboto throughout, a teal accent that shows up only in the
// subtitle, the list markers, and the section titles, and no chrome beyond a
// position indicator in the corner.
//
// Clean is quiet, and so is Mosaic's own Default theme, so this file states
// the difference between them rather than a whole look. It starts from
// Default's exported definition and overrides four things: the two accents,
// the type, two layouts, and the handful of rules Clean owns.
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic: slide, note, fit, surface, grids, layouts, steps, components

#let base = mosaic.themes.default.definition

// Clean names three colors: jet, an accent, and a second accent for alerts.
// Everything else stays on Mosaic's light palette.
#let colors = base.colors + (
  canvas: rgb("#ffffff"),
  text: rgb("#131516"),
  accent: rgb("#107895"),
  warning: rgb("#9a2515"),
  error: rgb("#9a2515"),
)

#let apply(body, colors: (:), options: (:)) = {
  // Default's rules first. Clean's follow and win, because a rule declared
  // later takes precedence and everything below is inside the body Default
  // styles: links, tables, captions, and the section cell's alignment all come
  // from there unchanged.
  show: (base.apply).with(colors: colors, options: options)

  set text(weight: "light")
  show heading: set text(weight: "light")
  show heading.where(depth: 1): set text(weight: "bold", fill: colors.accent)
  // Clean's third tier is a standfirst under the slide title, not a heading in
  // the ordinary sense.
  show heading.where(depth: 3): set text(size: 1.1em, fill: colors.accent, style: "italic")

  // The accent lives in the markers, never in the body copy.
  set list(indent: 1em, marker: (
    text(fill: colors.accent)[▸],
    text(fill: colors.accent)[→],
  ))
  set enum(indent: 1em, numbering: n => text(fill: colors.accent)[#n.])

  show label("mosaic-title-display"): set text(size: 1.4em, weight: "light")
  show label("mosaic-cell-section"): set text(weight: "bold", fill: colors.accent)

  body
}

#let definition = base + (
  name: "Clean",
  colors: colors,
  // Clean holds its content well inside the page and spaces the title stack
  // generously. The cell inset is the slide margin; the gap is the title
  // stack's vertical rhythm. Default's corner progress ring is inherited.
  defaults: base.defaults + (spacing: (inset: 1.6em, gap: 1.2em)),
  options: base.options + (
    font: ("Roboto", "Source Sans 3", "Liberation Sans", "DejaVu Sans"),
    base-size: 20pt,
  ),
  layouts: base.layouts + (
    // Clean's title page is the `ruled` arrangement with the rule taken away:
    // a flush-left heading stack at the vertical center over the author block.
    title: mosaic.layouts.title(variant: "ruled", rule: false),
    section: mosaic.layouts.section(variant: "plain"),
  ),
  apply: apply,
)

#let setup = mosaic.themes.setup(definition)
