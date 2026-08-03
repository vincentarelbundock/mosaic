// Exact callable Greyscale layout namespace.
#import "@local/mosaic:0.0.1" as _mosaic
#import "@local/mosaic:0.0.1": layouts as _base-layouts
#import "theme-tokens.typ" as _tokens
#let author = _base-layouts.author

#let content() = _mosaic.layouts.content(variant: "header-body")

#let title(
  title: auto,
  subtitle: auto,
  authors: auto,
  date: auto,
) = _mosaic.layouts.title(
  title,
  variant: "left-aligned",
  subtitle: subtitle,
  authors: authors,
  date: date,
  accent: _tokens.gray,
)

#let section(subtitle: none) = {
  let band = if subtitle == none {
    _mosaic.grid.cell("section", inset: 28pt)
  } else {
    _mosaic.grid.v(
      _mosaic.grid.cell("section", inset: 28pt),
      _mosaic.grid.t(
        auto,
        _mosaic.grid.cell("section-subtitle", content: subtitle, inset: 28pt),
      ),
    )
  }
  _mosaic.grid.h(
    _mosaic.grid.t(0.38fr, band),
    _mosaic.grid.t(0.62fr, _mosaic.grid.cell("rest", content: [])),
  )
}
