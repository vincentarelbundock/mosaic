// Private shared adapters for themes whose recipes differ only by accent token.
#import "../layout-api.typ" as layouts

#let default() = layouts.default(variant: "header-body")

#let title(
  accent,
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  ..legacy-title,
) = {
  let positional = legacy-title.pos()
  if positional.len() == 1 and title == none {
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
