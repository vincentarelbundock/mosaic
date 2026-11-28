# Citations

Mosaic adds no citation machinery. A deck is an ordinary Typst document, so `#cite`, `@key` references, and `#bibliography` behave exactly as they do in a paper. Footnotes are the one exception worth knowing about, because a slide is a fixed-height frame rather than a flowing page.

## Citation keys and a reference slide

Load a BibTeX or Hayagriva file with `#bibliography` on a closing slide. Set the style once with `#set bibliography(style: ...)` so the in-text citations and the reference list agree, and pass `title: none` so the slide's own heading names the list instead of the generated one.

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup.with(layouts: (content: m.layouts.content(variant: "body")))
#set text(size: 18pt)

// One style governs both the in-text citations and the reference list.
#set bibliography(style: "chicago-author-date")

#m.slide[
  == Citing sources on a slide

  Small multiples repeat one design across panels @tufte1990.

  #cite(<cleveland1993>, form: "prose") measured how accurately readers
  decode position, length, and area.
]

#m.slide[
  == References

  // `title: none` drops the generated heading, so the slide's own heading
  // names the list.
  #bibliography("references.bib", title: none)
]
```

The usual Typst citation forms all apply. `@key` produces a normal citation, `#cite(<key>, form: "prose")` reads as the sentence subject, `#cite(<key>, form: "year")` gives the year alone, and a supplement narrows the reference: `@tufte1990[p. 42]`.

`#bibliography` renders one block that cannot be split across slides, so a long reference list overflows its cell. Shrink it with `#set text(size: ...)` in that cell, or split the sources across several `.bib` files and give each reference slide its own `#bibliography` call. Each entry is printed by the first call that owns it, and numbering continues across the slides, so two or three uncrowded reference slides read better than one full one.

## Footnotes

Typst moves a footnote entry to the bottom of the page region that holds its marker. A Mosaic slide is a fixed-size frame, so there is no room below the content for the entry, and Typst would push it onto a page of its own. Mosaic therefore rejects a native `#footnote` on a slide with a compile error rather than let the note text land on an extra frame.

> **Requires Mosaic 0.0.3.** Rejecting `#footnote` with an error is new; the released version lets the entry spill onto an extra frame. This is the development version, which is not on Typst Universe yet: a deck that uses it imports `@local/mosaic:0.0.3` rather than the released `@preview/mosaic:0.0.1`. See [Install](../start/install.md).

Put the notes in a cell instead. An `auto`-height row at the bottom of the grid holds them, sized down and dimmed, and they stay on the slide that references them:

```typ
#import "@preview/mosaic:0.0.1" as m

// A body cell over an auto-height strip that holds the notes for this slide.
#let cited = m.grids.rows(
  m.grids.cell("body", inset: (x: 1.5em, top: 1.5em, bottom: 0.5em)),
  m.grids.track(auto, m.grids.cell("sources", inset: (x: 1.5em, bottom: 1em))),
)

#show: m.setup
#set text(size: 18pt)

// Numbered like footnote markers, but laid out by the grid, so the entries
// stay on the slide that references them.
#let marker(number) = super(str(number))
#let source(number, body) = block(below: 0.4em)[#marker(number) #body]

#m.slide(layout: cited)[
  == Sources stay on the slide

  Position judgments are more accurate than area judgments.#marker(1)

  Panels that share one scale invite comparison.#marker(2)
][
  #set text(size: 0.6em, fill: luma(35%))
  #source(1)[Cleveland, _Visualizing Data_, 1993.]
  #source(2)[Tufte, _Envisioning Information_, 1990.]
]
```

Because the markers are written by hand, numbering is per slide by construction, which is what a deck wants: an audience reading footnote 14 on a single slide has no way to count back to it. Define `marker` and `source` once in a shared file and every slide in the deck can use them.

The same row works for a source line under a figure or a table. Give it a fixed height rather than `auto` when several slides in a row carry notes, so the body area does not shift between them.
