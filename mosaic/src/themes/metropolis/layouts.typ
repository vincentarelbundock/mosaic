// Callable Metropolis layout namespace: base layouts with Metropolis defaults.
#import "../../layout/api.typ" as _base
#import "../../author.typ": author

#let content = _base.content.with(variant: "header-body")

// Academic when the call site provides authors, swiss otherwise. Every other
// base parameter passes through untouched, so the themed layout keeps the
// full base signature.
#let title(
  title: auto,
  subtitle: auto,
  authors: auto,
  date: auto,
  variant: auto,
  ..rest,
) = _base.title(
  title: title,
  subtitle: subtitle,
  authors: authors,
  date: date,
  variant: if variant == auto {
    if type(authors) == array and authors.len() > 0 { "academic" } else { "swiss" }
  } else {
    variant
  },
  ..rest,
)

#let section = _base.section
#let image = _base.image
