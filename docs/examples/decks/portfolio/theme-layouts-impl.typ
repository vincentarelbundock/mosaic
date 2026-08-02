#import "@local/mosaic:0.0.1" as mosaic
#import "theme-tokens.typ" as tokens

#let default() = mosaic.layouts.default(variant: "header-body")

#let title(
  title,
  subtitle: none,
  authors: (),
  date: none,
) = mosaic.layouts.title(
  title,
  variant: "left-aligned",
  subtitle: subtitle,
  authors: authors,
  date: date,
  accent: tokens.gray,
)

#let section(subtitle: none) = {
  let band = if subtitle == none {
    mosaic.grid.cell("section", inset: 28pt)
  } else {
    mosaic.grid.v(
      mosaic.grid.cell("section", inset: 28pt),
      mosaic.grid.t(
        auto,
        mosaic.grid.cell("section-subtitle", content: subtitle, inset: 28pt),
      ),
    )
  }
  mosaic.grid.h(
    mosaic.grid.t(0.38fr, band),
    mosaic.grid.t(0.62fr, mosaic.grid.cell("rest", content: [])),
  )
}
