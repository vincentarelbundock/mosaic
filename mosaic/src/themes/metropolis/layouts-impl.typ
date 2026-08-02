#import "../../layout-api.typ" as layouts
#import "tokens.typ" as tokens

// Two consuming cells. Automatic headings assign header/body through m.slide.
#let default() = layouts.default(
  variant: "header-body",
  progress: "1",
  accent: tokens.dot,
)

// Metropolis keeps the academic composition when author metadata is present,
// but a plain no-author title remains a valid portable theme call.
#let title(
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
    variant: if authors.len() > 0 { "academic" } else { "left-aligned" },
    subtitle: subtitle,
    authors: authors,
    date: date,
    accent: tokens.orange,
  )
}

#let section(subtitle: none) = layouts.section(
  subtitle: subtitle,
  accent: tokens.orange,
)
