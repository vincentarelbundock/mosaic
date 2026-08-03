// Exact callable starter layout namespace.
#import "@local/mosaic:0.0.1" as _mosaic
#import "@local/mosaic:0.0.1": layouts as _base-layouts
#let author = _base-layouts.author

#let content() = _mosaic.layouts.content(variant: "header-body")
#let title(title: auto, subtitle: auto, authors: auto, date: auto) = _mosaic.layouts.title(
  title: title,
  subtitle: subtitle,
  authors: authors,
  date: date,
  variant: "left-aligned",
  accent: auto,
)
#let section(subtitle: none) = _mosaic.layouts.section(
  subtitle: subtitle,
  accent: auto,
)
