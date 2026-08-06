// A Mosaic re-creation of the Clean theme for Touying and Quarto. preamble.typ
// holds the deck-local theme definition; the deck itself is ordinary Mosaic.
#import "preamble.typ": *
#show: setup.with(
  title: [Quarto Clean Theme],
  // The subtitle's italic accent is stated here rather than in the theme: the
  // title stack composes it inside the title cell, where no label reaches it.
  subtitle: text(style: "italic", fill: colors.accent)[A Minimalistic Theme for Typst],
  authors: (
    layouts.author(
      [Kazuharu Yanagimoto],
      affiliations: ([Kobe University],),
      email: "yanagimoto@econ.kobe-u.ac.jp",
      orcid: "0000-0002-4890-8567",
    ),
    layouts.author(
      [Coauthor Name],
      affiliations: ([Coauthor Institution],),
      email: "coauthor@example.edu",
    ),
  ),
  date: [July 17, 2026],
)

// 01. Title
#slide(layout: "title")

// 02. Section
= Section Slide as Header Level 1

// 03. Headings and lists
== Slide Title as Header Level 2

=== Subtitle as Header Level 3

You can put any content here: text, images, tables, code blocks, and so on.

- first unordered list item
  - a sub item

+ first ordered list item
  + a sub item

// 04. Emphasis and cross references
== Additional Theme Functions

=== Some extra things you can do with the clean theme

Clean ships four inline helpers. Under Mosaic each one is native Typst or a stock component, so the deck defines nothing of its own:

- `alert()` becomes #text(fill: colors.error)[a run in the second accent]
- `fg()` becomes #text(fill: rgb("#5d639e"))[an ordinary text fill]
- `bg()` becomes #highlight(radius: 2pt, extent: 0.2em)[a native highlight]
- `.button` becomes #link(<summary>)[#components.badge(role: "accent")[Summary]]

// 05. Table
== A Table

=== Native Typst, with the stroke stated once in the theme

#align(center + horizon, table(
  columns: 4,
  align: (left, right, right, right),
  inset: (x: 0.8em, y: 0.5em),
  table.header([Specification], [Estimate], [Std. error], [$N$]),
  [Pooled], [0.42], [0.11], [4 812],
  [With controls], [0.38], [0.12], [4 812],
  [Region fixed effects], [0.35], [0.14], [4 780],
))

// 06. Summary
== Summary #metadata(none) <summary>

=== Quarto Clean Typst Theme

While Clean is a Touying theme, it is designed to be used from #link("https://quarto.org")[Quarto].

- Markdown syntax, code execution, and Quarto's own layouts
- `keep-typ: true` hands you the generated Typst back

#v(0.5em)

=== Under Mosaic

- `preamble.typ` extends Mosaic's Default definition rather than restating a look
- It overrides two colors, the type, and two layouts, and adds five rules
- The deck itself defines nothing at all
