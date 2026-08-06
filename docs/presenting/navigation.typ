#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Navigation])
#metadata((title: "Navigation")) <website-metadata>

#title()

Because Mosaic keeps Typst headings native, the same headings that create slides can drive tables of contents, breadcrumbs, and links between sections.

= Table of contents

Mosaic keeps headings native, so a table of contents is Typst's own #link("https://typst.app/docs/reference/model/outline/")[`outline`]. Three of its defaults behave differently on a slide than in a document.

== Depth

`depth: 1` lists sections. `depth: 2` adds every slide, which on most decks is the whole slide list.

== Entries

A default entry ends in dotted leaders and the page its heading falls on. On slides that page is the physical frame, so on a deck using `#m.pause` it differs from the logical slide number in the footer.

A `show outline.entry` rule replaces the entry. `it.body()` is the title, `it.element.location()` is the link target, and `it.prefix()` is the heading number when headings are numbered.

== The contents slide itself

Its own heading is outlined like any other, so it appears in its own outline unless it carries `#heading(outlined: false)` or a narrower `target:` excludes it.

#embedded-example(
  calepin.elements.gallery,
  "furniture/outline",
  frames: 5,
  title: "A linked table of contents",
)

== Columns

`#columns(2, outline(..))` does not spread entries across a slide. Typst fills the first column to the full height of its container before starting the second, and a slide cell is full-slide height, so a list that fits vertically stays in column one. A surrounding `block` does not change that.

`query(heading.where(level: 1, outlined: true))` returns the section headings in document order, each with a `body` to print and a `location()` to link to. Slice them and place the chunks in a native `grid`.

#embedded-example(
  calepin.elements.gallery,
  "furniture/outline-columns",
  frames: 7,
  title: "Contents in two columns",
)

== Lists longer than the slide

An overflowing cell is drawn past the bottom edge rather than clipped. #link("../api/slides.html")[`m.fit`] scales a block into the space available:

```typ
#m.fit(outline(title: none, depth: 1))
```

Fitting scales the type with the layout, so the contents slide no longer matches the deck's type scale.

== The current section

The #link("../slides/section.html#variants")[section layout]'s `toc` variant lists every section with the current one marked, reading the deck's section records rather than an outline:

```typ
#m.slide(layout: "section", variant: "toc")[Results]
```

It takes no `outline` and no query, and fits itself to the slide.

= Breadcrumbs

Use native contextual `query` with a selector ending at `here()` to find the active section and slide headings. Their `body` fields provide the labels, and `location()` provides a link target.

#embedded-example(
  calepin.elements.gallery,
  "furniture/breadcrumbs",
  frames: 3,
  title: "Section and slide breadcrumbs",
)

= Section links

Use `query(heading.where(level: 1, outlined: true))` to collect every outlined section heading. Each result provides a label through `body` and a destination through `location()`. Compare it with the last matching heading before `here()` to style the active section differently.

#embedded-example(
  calepin.elements.gallery,
  "furniture/section-links",
  frames: 3,
  title: "Clickable section navigation",
)
