# Clean example deck

A complete 6-frame deck. Assets, Makefile, and the compiled PDF are in the [repository](https://github.com/vincentarelbundock/mosaic/tree/main/docs-src/examples/decks/quarto-clean).

## `main.typ`

```typ
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
  table.header([Specification], [Estimate], [Std. error], [#math.equation(alt: "N", $N$)]),
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
```

## `preamble.typ`

```typ
// Everything main.typ imports: the shared Mosaic API and a deck-local Mosaic
// theme.
//
// The theme re-creates the look of the Clean theme for
// Touying and Quarto (https://github.com/kazuyanagimoto/quarto-clean-typst,
// MIT): light Roboto throughout, a teal accent that shows up only in the
// subtitle, the list markers, and the section titles, and no chrome beyond a
// position indicator in the corner.
//
// Clean is quiet, and so is Mosaic's own Default theme, so this file states
// the difference between them rather than a whole look. It starts from
// Default's exported definition and overrides four things: the two accents,
// the type, two layouts, and the handful of rules Clean owns.
#import "@preview/mosaic:0.0.2" as mosaic
#import mosaic: slide, note, fit, grids, layouts, steps, components

#let base = mosaic.themes.default.definition

// Clean names three colors: jet, an accent, and a second accent for alerts.
// Everything else stays on Mosaic's light palette.
#let colors = base.colors + (
  canvas: rgb("#ffffff"),
  text: rgb("#131516"),
  accent: rgb("#107895"),
  warning: rgb("#9a2515"),
  error: rgb("#9a2515"),
)

#let apply(body, colors: (:), options: (:)) = {
  // Default's rules first. Clean's follow and win, because a rule declared
  // later takes precedence and everything below is inside the body Default
  // styles: links, tables, captions, and the section cell's alignment all come
  // from there unchanged.
  show: (base.apply).with(colors: colors, options: options)

  set text(weight: "light")
  show heading: set text(weight: "light")
  show heading.where(depth: 1): set text(weight: "bold", fill: colors.accent)
  // Clean's third tier is a standfirst under the slide title, not a heading in
  // the ordinary sense.
  show heading.where(depth: 3): set text(size: 1.1em, fill: colors.accent, style: "italic")

  // The accent lives in the markers, never in the body copy.
  set list(indent: 1em, marker: (
    text(fill: colors.accent)[▸],
    text(fill: colors.accent)[→],
  ))
  set enum(indent: 1em, numbering: n => text(fill: colors.accent)[#n.])

  show label("mosaic-title-display"): set text(size: 1.4em, weight: "light")
  show label("mosaic-cell-section"): set text(weight: "bold", fill: colors.accent)

  body
}

#let definition = base + (
  name: "Clean",
  colors: colors,
  // Clean holds its content well inside the page and spaces the title stack
  // generously. The cell inset is the slide margin; the gap is the title
  // stack's vertical rhythm. Default's corner progress ring is inherited.
  defaults: base.defaults + (spacing: (inset: 1.6em, gap: 1.2em)),
  options: base.options + (
    font: ("Roboto", "Source Sans 3", "Liberation Sans", "DejaVu Sans"),
    base-size: 20pt,
  ),
  layouts: base.layouts + (
    // Clean's title page is the `ruled` arrangement with the rule taken away:
    // a flush-left heading stack at the vertical center over the author block.
    title: mosaic.layouts.title(variant: "ruled", rule: false),
    section: mosaic.layouts.section(variant: "plain"),
  ),
  apply: apply,
)

#let setup = mosaic.themes.setup(definition)
```
