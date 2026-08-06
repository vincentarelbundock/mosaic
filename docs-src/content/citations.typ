#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Citations])
#metadata((title: "Citations")) <website-metadata>

#title()

Mosaic adds no citation machinery. A deck is an ordinary Typst document, so `#cite`, `@key` references, and `#bibliography` behave exactly as they do in a paper. Footnotes are the one exception worth knowing about, because a slide is a fixed-height frame rather than a flowing page.

= Citation keys and a reference slide

Load a BibTeX or Hayagriva file with `#bibliography` on a closing slide. Set the style once with `#set bibliography(style: ...)` so the in-text citations and the reference list agree, and pass `title: none` so the slide's own heading names the list instead of the generated one.

#embedded-example(
  calepin.elements.gallery,
  "blocks/citations",
  frames: 2,
  title: "Cite sources and close with a reference slide",
)

The usual Typst citation forms all apply. `@key` produces a normal citation, `#cite(<key>, form: "prose")` reads as the sentence subject, `#cite(<key>, form: "year")` gives the year alone, and a supplement narrows the reference: `@tufte1990[p. 42]`.

`#bibliography` renders one block that cannot be split across slides, so a long reference list overflows its cell. Shrink it with `#set text(size: ...)` in that cell, or split the sources across several `.bib` files and give each reference slide its own `#bibliography` call. Each entry is printed by the first call that owns it, and numbering continues across the slides, so two or three uncrowded reference slides read better than one full one.

= Footnotes

Typst moves a footnote entry to the bottom of the page region that holds its marker. A Mosaic slide is a fixed-size frame, so there is no room below the content for the entry, and Typst pushes it onto a page of its own: the marker appears on the slide, the note text on the next frame. Native `#footnote` is therefore not usable inside a slide body.

Put the notes in a cell instead. An `auto`-height row at the bottom of the grid holds them, sized down and dimmed, and they stay on the slide that references them:

#embedded-example(
  calepin.elements.gallery,
  "blocks/slide-sources",
  frames: 1,
  title: "Source notes in a dedicated grid row",
)

Because the markers are written by hand, numbering is per slide by construction, which is what a deck wants: an audience reading footnote 14 on a single slide has no way to count back to it. Define `marker` and `source` once in a shared file and every slide in the deck can use them.

The same row works for a source line under a figure or a table. Give it a fixed height rather than `auto` when several slides in a row carry notes, so the body area does not shift between them.
