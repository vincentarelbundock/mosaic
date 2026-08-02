#import "@local/mosaic:0.0.1" as mosaic
#import "_starter-tokens.typ" as tokens

#let default() = mosaic.layouts.default(variant: "header-body")
#let title(title: none, subtitle: none, authors: (), date: none) = mosaic.layouts.title(
  title: title,
  subtitle: subtitle,
  authors: authors,
  date: date,
  variant: "left-aligned",
  accent: tokens.gold,
)
#let section(subtitle: none) = mosaic.layouts.section(
  subtitle: subtitle,
  accent: tokens.navy,
)
