// Callable Greyscale layout namespace: base layouts with Greyscale defaults,
// plus a fully custom section grid.
#import "@local/mosaic:0.0.1" as _mosaic
#import "@local/mosaic:0.0.1": layouts as _base
#import "theme-tokens.typ" as _tokens

#let author = _base.author
#let content = _base.content.with(variant: "header-body")
#let title = _base.title.with(accent: _tokens.gray)
#let image = _base.image

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
