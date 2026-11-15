#import "@local/mosaic:0.0.3" as mosaic
#import "support/grid.typ" as grid-test
#import "../mosaic/src/layout/resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings
#import "../mosaic/src/settings.typ": compact-cell-inset

#let settings = make-settings()

#assert("content" in mosaic.layouts)

// The root facade is the Default theme, so a bare call builds what a `==`
// heading builds under it: a header over a body, with no footer row.
#let content-layout = mosaic.layouts.content()
#let resolved-content = resolve-layout(content-layout, settings)
#assert(resolved-content.tracks == (auto, 1fr))
#assert(grid-test.count(resolved-content) == 2)
#assert(content-layout == mosaic.definition.layouts.content)
#assert(mosaic.layouts.section() == mosaic.definition.layouts.section)

#let footer-layout = mosaic.layouts.content(variant: "header-body-footer")
#let resolved-footer = resolve-layout(footer-layout, settings)
#assert(resolved-footer.tracks == (auto, 1fr, auto))
#assert(grid-test.count(resolved-footer) == 3)

#let basic-grid = mosaic.layouts.content(variant: "body")
#let resolved-basic = resolve-layout(basic-grid, settings)
#assert(resolved-basic.tracks == (1fr,))
#assert(grid-test.count(resolved-basic) == 1)
#assert(grid-test.info(resolved-basic, "body").cell.id == "body")
#assert(grid-test.info(resolved-basic, "body").cell.content == none)
#let basic = mosaic.slide(layout: basic-grid)[Body content]

#let structured-grid = mosaic.layouts.content(
  variant: "header-body-footer",
  columns: 2,
  tracks: (2fr, 1fr),
)
#let resolved-structured = resolve-layout(structured-grid, settings)
#assert(resolved-structured.kind == "split")
#assert(resolved-structured.axis == "height")
#assert(resolved-structured.tracks == (auto, 1fr, auto))
#assert(resolved-structured.children.at(1).kind == "split")
#assert(resolved-structured.children.at(1).axis == "width")
#assert(resolved-structured.children.at(1).tracks == (2fr, 1fr))
#assert(grid-test.count(resolved-structured) == 4)
#assert(grid-test.info(resolved-structured, "header").cell.content == none)
#assert(grid-test.info(resolved-structured, "header").cell.style.content-sized)
// A content-sized cell keeps the deck inset horizontally and equal, shallower padding
// above and below, so a recolored header or footer reads as a balanced band
// that is no deeper than the single line it carries.
#assert(
  grid-test.info(resolved-structured, "header").cell.style.inset
    == compact-cell-inset(settings.spacing),
)
#assert(
  grid-test.info(resolved-structured, "header").cell.style.inset.x
    == settings.spacing.inset,
)
#assert(
  grid-test.info(resolved-structured, "header").cell.style.inset.y
    < settings.spacing.inset,
)
#assert(
  grid-test.info(resolved-structured, "footer").cell.style.inset
    == compact-cell-inset(settings.spacing),
)
#assert(
  grid-test.info(resolved-structured, "footer").cell.style.inset.x
    == settings.spacing.inset,
)
#assert(
  grid-test.info(resolved-structured, "footer").cell.style.inset.y
    < settings.spacing.inset,
)
// `compact-inset` sets the vertical half; `auto` derives it from `inset`.
#assert(
  settings.spacing.compact-inset == 0.55 * settings.spacing.inset,
)
#let deep-settings = make-settings(spacing: (compact-inset: 1em))
#assert(
  grid-test.info(
    resolve-layout(structured-grid, deep-settings),
    "header",
  ).cell.style.inset
    == (x: deep-settings.spacing.inset, y: 1em),
)
#assert(grid-test.info(resolved-structured, "body-1").cell.content == none)
#assert(grid-test.info(resolved-structured, "body-2").cell.content == none)
#assert(grid-test.info(resolved-structured, "footer").cell.content == none)
#assert(grid-test.info(resolved-structured, "footer").cell.style.content-sized)
// Cells are structural: no text, fill, or align styles are threaded through
// the grid record. Appearance is native, via <mosaic-cell-ID> label rules.
#assert(
  "text" not in grid-test.info(resolved-structured, "footer").cell.style,
)
#assert(
  "fill" not in grid-test.info(resolved-structured, "header").cell.style,
)
#let structured = mosaic.slide(layout: structured-grid, cells: (
  header: [Structured header],
  body-1: [Left body],
  body-2: [Right body],
  footer: [Structured footer],
))

// Native rules restyle the content layout's canonical cells, deck-wide or
// scoped to one slide command.
#let styled = [
  #show label("mosaic-cell-header"): it => block(
    width: 100%,
    fill: rgb("#1f4b66"),
    text(fill: white, weight: "bold", it),
  )
  #show label("mosaic-cell-body"): set text(fill: rgb("#123456"))
  #show label("mosaic-cell-footer"): set align(right)
  #mosaic.slide(layout: footer-layout, cells: (
    header: [Styled header],
    body: [Body region],
    footer: [Independent footer style],
  ))
]

#let header-body-layout = mosaic.layouts.content(variant: "header-body")
#let header-body-grid = resolve-layout(header-body-layout, settings)
#assert(header-body-grid.tracks == (auto, 1fr))
#assert(grid-test.count(header-body-grid) == 2)
#let header-body = mosaic.slide(layout: header-body-layout)[== Header][Body]

#let body-footer-layout = mosaic.layouts.content(variant: "body-footer")
#let body-footer-grid = resolve-layout(body-footer-layout, settings)
#assert(body-footer-grid.tracks == (1fr, auto))
#assert(grid-test.count(body-footer-grid) == 2)
#let body-footer = mosaic.slide(layout: body-footer-layout)[Body][Footer]

#show: mosaic.setup
#basic
#structured
#styled
#header-body
#body-footer
