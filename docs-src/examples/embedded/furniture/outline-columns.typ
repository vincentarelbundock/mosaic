#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

// `columns` fills its first column to the full height of the region before it
// starts the second, and a slide cell is full-slide height, so a list that fits
// vertically never reaches column two. Query the headings and place the chunks
// side by side instead.
#let contents(columns: 2) = context {
  let entries = query(heading.where(level: 1, outlined: true))
  let per-column = calc.ceil(entries.len() / columns)
  grid(
    columns: (1fr,) * columns,
    column-gutter: 1.5em,
    ..range(columns).map(index => {
      let start = calc.min(index * per-column, entries.len())
      let end = calc.min(start + per-column, entries.len())
      stack(
        spacing: 0.9em,
        ..entries.slice(start, end).map(entry => link(entry.location(), entry.body)),
      )
    }),
  )
}

#m.slide(numbered: false)[
  #heading(outlined: false, bookmarked: false)[Contents]
][
  #contents()
]

= Motivation

= Data

= Identification

= Results

= Robustness

= Conclusion
