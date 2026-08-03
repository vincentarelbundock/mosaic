// Exact callable Metropolis layout namespace.
#import "../../layout-api.typ" as _layouts
#import "../../author.typ": author

#let content() = _layouts.content(variant: "header-body")

#let title(
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
  _layouts.title(
    title: title,
    variant: if type(authors) == array and authors.len() > 0 { "academic" } else { "left-aligned" },
    subtitle: subtitle,
    authors: authors,
    date: date,
    accent: auto,
  )
}

#let section(subtitle: none) = _layouts.section(
  subtitle: subtitle,
  accent: auto,
)
