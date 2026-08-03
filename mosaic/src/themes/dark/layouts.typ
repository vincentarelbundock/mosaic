// Exact callable Dark layout namespace.
#import "../../layout-api.typ" as _base
#import "../../author.typ": author

#let content(
  variant: "header-body-footer",
  columns: 1,
  tracks: auto,
) = _base.content(
  variant: variant,
  columns: columns,
  tracks: tracks,
)

#let title(
  title: auto,
  subtitle: auto,
  date: auto,
  image: none,
  variant: "left-aligned",
  authors: auto,
  tracks: auto,
  align: left + bottom,
  rule: auto,
  accent: auto,
  ..legacy-title,
) = _base.title(
  ..legacy-title,
  title: title,
  subtitle: subtitle,
  date: date,
  image: image,
  variant: variant,
  authors: authors,
  tracks: tracks,
  align: align,
  rule: rule,
  accent: accent,
)

#let section(
  subtitle: none,
  number: none,
  image: none,
  variant: "plain",
  accent: auto,
  tracks: auto,
) = _base.section(
  subtitle: subtitle,
  number: number,
  image: image,
  variant: variant,
  accent: accent,
  tracks: tracks,
)
