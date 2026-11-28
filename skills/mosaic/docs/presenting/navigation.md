# Navigation

Because Mosaic keeps Typst headings native, the same headings that create slides can drive tables of contents, breadcrumbs, and links between sections.

## Table of contents

Mosaic keeps headings native, so a table of contents is Typst's own [`outline`](https://typst.app/docs/reference/model/outline/). Three of its defaults behave differently on a slide than in a document.

### Depth

`depth: 1` lists sections. `depth: 2` adds every slide, which on most decks is the whole slide list.

### Entries

A default entry ends in dotted leaders and the page its heading falls on. On slides that page is the physical frame, so on a deck using `#m.steps.pause` it differs from the logical slide number in the footer.

A `show outline.entry` rule replaces the entry. `it.body()` is the title, `it.element.location()` is the link target, and `it.prefix()` is the heading number when headings are numbered.

### The contents slide itself

Its own heading is outlined like any other, so it appears in its own outline unless it carries `#heading(outlined: false)` or a narrower `target:` excludes it.

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

// A contents slide is a slide like any other, so its own heading would be the
// first entry in its own outline. `outlined: false` keeps it out.
#m.slide(numbered: false)[
  #heading(outlined: false, bookmarked: false)[Contents]
][
  // A default entry ends in dotted leaders and a page number. On slides that
  // number counts physical frames, not the logical slides the footer shows, so
  // this rule keeps the linked title alone.
  #show outline.entry: it => block(
    below: 0.9em,
    link(it.element.location(), it.body()),
  )

  #outline(title: none, depth: 1)
]

= Methods

== Data

Describe the data and measurements.

= Results

== Estimates

Present the main estimates.
```

### Columns

`#columns(2, outline(..))` does not spread entries across a slide. Typst fills the first column to the full height of its container before starting the second, and a slide cell is full-slide height, so a list that fits vertically stays in column one. A surrounding `block` does not change that.

`query(heading.where(level: 1, outlined: true))` returns the section headings in document order, each with a `body` to print and a `location()` to link to. Slice them and place the chunks in a native `grid`.

```typ
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
```

### Lists longer than the slide

An overflowing cell is drawn past the bottom edge rather than clipped. [`m.fit`](../api/slides.md) scales a block into the space available:

```typ
#m.fit(outline(title: none, depth: 1))
```

Fitting scales the type with the layout, so the contents slide no longer matches the deck's type scale.

### The current section

The [section layout](../slides/section.md#variants)'s `toc` variant lists every section with the current one marked, reading the deck's section records rather than an outline:

```typ
#m.slide(layout: "section", variant: "toc")[Results]
```

It takes no `outline` and no query, and fits itself to the slide.

## Breadcrumbs

Use native contextual `query` with a selector ending at `here()` to find the active section and slide headings. Their `body` fields provide the labels, and `location()` provides a link target.

```typ
#import "@preview/mosaic:0.0.1" as m

#let active-heading(level) = {
  let headings = query(
    heading.where(level: level, outlined: true).before(here()),
  )
  if headings.len() > 0 { headings.last() }
}

#let breadcrumb() = context {
  let section = active-heading(1)
  let slide = active-heading(2)
  if section != none {
    let parts = (link(section.location(), section.body),)
    if slide != none {
      parts.push(slide.body)
    }
    parts.join([ › ])
  }
}

#show: m.setup.with(
  foreground: [
    #place(top + right)[
      #pad(top: 0.9em, right: 1.35em)[
        #text(size: 0.65em, fill: luma(35%))[#breadcrumb()]
      ]
    ]
  ],
)
#set text(size: 22pt)

= Methods

== Data

Describe the observations.

== Model

Explain the model.
```

## Section links

Use `query(heading.where(level: 1, outlined: true))` to collect every outlined section heading. Each result provides a label through `body` and a destination through `location()`. Compare it with the last matching heading before `here()` to style the active section differently.

```typ
#import "@preview/mosaic:0.0.1" as m

#let section-links() = context {
  let sections = query(heading.where(level: 1, outlined: true))
  let preceding = query(
    heading.where(level: 1, outlined: true).before(here()),
  )
  let current = if preceding.len() > 0 { preceding.last() }
  sections.map(section => {
    let active = (
      current != none
        and current.location() == section.location()
    )
    link(
      section.location(),
      box(
        inset: (x: 0.7em, y: 0.3em),
        radius: 0.3em,
        fill: if active { blue.lighten(85%) } else { luma(94%) },
        text(
          weight: if active { "bold" } else { "regular" },
          section.body,
        ),
      ),
    )
  }).join(h(0.35em))
}

#show: m.setup.with(
  foreground: [
    #place(bottom + center)[
      #pad(bottom: 0.7em)[#section-links()]
    ]
  ],
)
#set text(size: 22pt)

= Methods

= Results

= Discussion
```
