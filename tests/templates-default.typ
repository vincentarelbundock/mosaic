#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test
#import "../mosaic/src/template-resolver.typ": resolve-template
#import "../mosaic/src/settings.typ": make-settings

#let settings = make-settings()

#assert("default" in mosaic.templates)

#let default-grid = mosaic.templates.default()
#let resolved-default = resolve-template(default-grid, settings)
#assert(resolved-default.tracks == (auto, 1fr, auto))
#assert(grid-test.count(resolved-default) == 3)

#let basic-grid = mosaic.templates.default(variant: "body")
#let resolved-basic = resolve-template(basic-grid, settings)
#assert(resolved-basic.tracks == (1fr,))
#assert(grid-test.count(resolved-basic) == 1)
#assert(grid-test.info(resolved-basic, "body").cell.id == "body")
#assert(grid-test.info(resolved-basic, "body").cell.content == none)
#let basic = mosaic.slide(grid: basic-grid)[Body content]

#let structured-grid = mosaic.templates.default(
  columns: 2,
  tracks: (2fr, 1fr),
)
#let resolved-structured = resolve-template(structured-grid, settings)
#assert(resolved-structured.kind == "split")
#assert(resolved-structured.axis == "height")
#assert(resolved-structured.tracks == (auto, 1fr, auto))
#assert(resolved-structured.children.at(1).kind == "split")
#assert(resolved-structured.children.at(1).axis == "width")
#assert(resolved-structured.children.at(1).tracks == (2fr, 1fr))
#assert(grid-test.count(resolved-structured) == 4)
#assert(grid-test.info(resolved-structured, "header").cell.content == none)
#assert(grid-test.info(resolved-structured, "header").cell.style.content-sized)
#assert(grid-test.info(resolved-structured, "header").cell.style.inset == (
  top: settings.spacing.compact-gap,
  right: settings.spacing.inset,
  bottom: settings.spacing.compact-gap,
  left: settings.spacing.inset,
))
#assert(grid-test.info(resolved-structured, "body-1").cell.content == none)
#assert(grid-test.info(resolved-structured, "body-2").cell.content == none)
#assert(grid-test.info(resolved-structured, "footer").cell.content == none)
#assert(grid-test.info(resolved-structured, "footer").cell.style.content-sized)
#assert(
  grid-test.info(resolved-structured, "footer").cell.style.text.size
    == settings.type.small.size,
)
#let structured = mosaic.slide(grid: structured-grid)[Structured header][Left body][Right body][Structured footer]

#let colored-grid = mosaic.templates.default(
  fill: (
    header: rgb("#1f4b66"),
    body: rgb("#e8f2f8"),
    footer: rgb("#c9deea"),
  ),
  text: (
    header: (fill: white, weight: "bold"),
    body: (fill: rgb("#123456")),
    footer: (size: 18pt),
  ),
  align: (footer: right),
  inset: (footer: 8pt),
)
#let resolved-colored = resolve-template(colored-grid, settings)
#assert(grid-test.info(resolved-colored, "header").cell.style.fill == rgb("#1f4b66"))
#assert(grid-test.info(resolved-colored, "body").cell.style.fill == rgb("#e8f2f8"))
#assert(grid-test.info(resolved-colored, "footer").cell.style.fill == rgb("#c9deea"))
#assert(grid-test.info(resolved-colored, "header").cell.style.text.fill == white)
#assert(grid-test.info(resolved-colored, "header").cell.style.text.weight == "bold")
#assert(grid-test.info(resolved-colored, "body").cell.style.text.fill == rgb("#123456"))
#assert(grid-test.info(resolved-colored, "footer").cell.style.text.size == 18pt)
#assert(grid-test.info(resolved-colored, "footer").cell.style.align == right)
#assert(grid-test.info(resolved-colored, "footer").cell.style.inset == 8pt)
#let colored = mosaic.slide(grid: colored-grid)[Colored regions][Body region][Independent footer fill]

#let inverted-grid = mosaic.templates.default(
  inverted: ("header", "footer"),
)
#let resolved-inverted = resolve-template(inverted-grid, settings)
#assert(grid-test.info(resolved-inverted, "header").cell.style.fill == settings.colors.text)
#assert(grid-test.info(resolved-inverted, "header").cell.style.text.fill == settings.colors.inverse-text)
#assert(grid-test.info(resolved-inverted, "body").cell.style.fill == settings.colors.canvas)
// A plain body region declares no text delta: it inherits ambient `set text`.
#assert(grid-test.info(resolved-inverted, "body").cell.style.text == (:))
#assert(grid-test.info(resolved-inverted, "footer").cell.style.fill == settings.colors.text)
#assert(grid-test.info(resolved-inverted, "footer").cell.style.text.fill == settings.colors.inverse-text)
#let inverted = mosaic.slide(grid: inverted-grid)[
  == Inverted regions
][
  The body retains the scheme canvas and ordinary text.
][
  Header and footer inherit inverse colors.
]

#let inverted-overrides-grid = mosaic.templates.default(
  inverted: ("header", "footer"),
  fill: (header: rgb("#1f4b66")),
  text: (footer: (fill: rgb("#c9deea"))),
)
#let resolved-inverted-overrides = resolve-template(inverted-overrides-grid, settings)
#assert(grid-test.info(resolved-inverted-overrides, "header").cell.style.fill == rgb("#1f4b66"))
#assert(grid-test.info(resolved-inverted-overrides, "footer").cell.style.text.fill == rgb("#c9deea"))

#let footer-inverted-grid = mosaic.templates.default(
  inverted: ("footer",),
)
#let resolved-footer-inverted = resolve-template(footer-inverted-grid, settings)
#assert(grid-test.info(resolved-footer-inverted, "header").cell.style.fill == settings.colors.canvas)
#assert(grid-test.info(resolved-footer-inverted, "header").cell.style.text == (:))
#assert(grid-test.info(resolved-footer-inverted, "footer").cell.style.fill == settings.colors.text)
#assert(grid-test.info(resolved-footer-inverted, "footer").cell.style.text.fill == settings.colors.inverse-text)

#let imaged-grid = mosaic.templates.default(
  background: (
    header: image("/docs/assets/images/bonsai.webp"),
    body: image("/docs/assets/images/dog.webp", fit: "cover"),
    footer: image("/docs/assets/images/bonsai.webp"),
  ),
)
#let resolved-imaged = resolve-template(imaged-grid, settings)
#assert(type(grid-test.info(resolved-imaged, "header").cell.style.background) == content)
#assert(type(grid-test.info(resolved-imaged, "body").cell.style.background) == content)
#assert(type(grid-test.info(resolved-imaged, "footer").cell.style.background) == content)
#let imaged = mosaic.slide(grid: imaged-grid)[Image-backed regions][Foreground content][Every region accepts an image]

#let header-body-template = mosaic.templates.default(variant: "header-body")
#let header-body-grid = resolve-template(header-body-template, settings)
#assert(header-body-grid.tracks == (auto, 1fr))
#assert(grid-test.count(header-body-grid) == 2)
#let header-body = mosaic.slide(grid: header-body-template)[Header][Body]

#let body-footer-template = mosaic.templates.default(variant: "body-footer")
#let body-footer-grid = resolve-template(body-footer-template, settings)
#assert(body-footer-grid.tracks == (1fr, auto))
#assert(grid-test.count(body-footer-grid) == 2)
#let body-footer = mosaic.slide(grid: body-footer-template)[Body][Footer]

#show: mosaic.setup
#basic
#structured
#colored
#inverted
#imaged
#header-body
#body-footer
