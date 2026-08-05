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
    _mosaic.grids.cell("section", inset: 28pt)
  } else {
    _mosaic.grids.v(
      _mosaic.grids.cell("section", inset: 28pt),
      _mosaic.grids.t(
        auto,
        _mosaic.grids.cell("section-subtitle", content: subtitle, inset: 28pt),
      ),
    )
  }
  _mosaic.grids.h(
    _mosaic.grids.t(0.38fr, band),
    _mosaic.grids.t(0.62fr, _mosaic.grids.cell("rest", content: [])),
  )
}
