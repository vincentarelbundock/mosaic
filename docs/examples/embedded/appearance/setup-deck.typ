#import "@local/mosaic:0.0.1" as m

#let authors = (m.layouts.author(
  "Ada Lovelace",
  affiliations: ((id: "systems", name: [Systems Research]),),
),)

#let number = [
  #place(bottom + right, dx: -1.25em, dy: -0.35em)[
    #m.components.progress(variant: "1")
  ]
]
#let line = [
  #place(bottom + left)[
    #m.components.progress(variant: "line", width: 100%, thickness: 3pt)
  ]
]

#show: m.setup.with(
  title: [RELIABLE SYSTEMS],
  subtitle: [One source for deck identity],
  authors: authors,
  date: [2026],
  colors: (
    canvas: rgb("#f4f8f7"),
    accent: rgb("#007f73"),
  ),
  content: (
    footer: [Mosaic · Systems Research],
    foreground: number,
  ),
)

#m.slide(
  layout: "title",
  content: (foreground: none),
)

#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  content: (
    header: [SEMANTIC COLOR ROLES],
    body: [
      `canvas` and `accent` were overridden once in `m.setup`.

      Title, subtitle, authors, and date remain presentation metadata. The title
      layout inherits them without repeating those values. The footer is likewise
      supplied by the setup-level cell-content defaults.
    ],
    foreground: [#number #line],
  ),
)
