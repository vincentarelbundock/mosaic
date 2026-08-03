// Private shared adapters for themes whose recipes differ only by accent token.
#import "../layout-api.typ" as layouts

#let content() = layouts.content(variant: "header-body")

#let title(
  accent,
  title: auto,
  subtitle: auto,
  authors: auto,
  date: auto,
  ..legacy-title,
) = {
  let positional = legacy-title.pos()
  if positional.len() == 1 and title == auto {
    title = positional.first()
  }
  layouts.title(
    title: title,
    subtitle: subtitle,
    authors: authors,
    date: date,
    variant: "left-aligned",
    accent: accent,
  )
}

#let section(accent, subtitle: none) = layouts.section(
  subtitle: subtitle,
  accent: accent,
)
