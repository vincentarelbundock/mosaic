#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  slideshow,
  thumbnail-gallery,
)

#set document(title: [Furniture])
#metadata((title: "Furniture")) <website-metadata>

#title()

Grids and cells occupy the main slide body. Two full-slide *planes* sit around
it (a background painted behind and a foreground painted over), and neither
changes the grid's row or column measurements. Together with headings, they
carry a deck's furniture: page numbers, logos, decoration, and navigation. Set a
recurring plane through the reserved `background` and `foreground` entries of
`m.setup(content:)`, or use the same entries in one `m.slide(content:)`. A slide
inherits the setup plane by default; a slide entry replaces it, and an entry set
to `none` omits it. Each rendered
plane is labeled like a cell (`<mosaic-cell-background>` and
`<mosaic-cell-foreground>`), so native `show label(...)` rules style planes
too. Recurring footer text is different: it belongs in the grid's real `footer`
cell, where it participates in layout instead of floating over the slide.

Keep three concerns distinct:

- *Cells* such as `header`, `body`, and `footer` participate in the resolved grid.
  Setup values are defaults only for real cells present in that grid.
- *Planes* are the reserved `background` and `foreground` content entries. They
  cover the page independently of grid structure.
- *Runtime state* supplies logical slide, section, and frame counters. Components
  such as `m.components.progress()` read that state but still return ordinary
  content, which you place in a cell or plane yourself.

This means there is no separate footer, logo, numbering, or progress feature.
Reusable authored visuals go through setup `content:`; slide-specific visuals go
through slide `content:`; runtime-aware components merely construct those values.

= Default footer content

Most decks repeat the same source, confidentiality notice, event name, or
organization in every ordinary slide footer. Declare that value once as partial
setup content:

```typ
#show: m.setup.with(
  content: (
    footer: [Mosaic · Engineering],
  ),
)
```

The default applies whenever the resolved layout contains a content-bearing
cell named `footer`. A title slide has no such cell, so it is unaffected. With a
default footer, positional content supplies only the remaining cells:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
)[RESULTS][Main result]
```

Named content can likewise omit `footer`. An explicit value overrides the deck
default, while `none` suppresses it on one slide:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  content: (
    header: [APPENDIX],
    body: [Supporting details],
    footer: none,
  ),
)
```

A complete positional body list remains valid and overrides every corresponding
default. Footer content has only this cell-based mechanism—there is no separate
global footer feature—so it cannot unexpectedly overlap slide numbers,
progress, or the slide body.

#embedded-example(
  calepin.elements.gallery,
  "structure/setup-content",
  frames: 3,
  title: "A default footer, a slide override, and explicit suppression",
  renderer: thumbnail-gallery,
)

= Foreground

Foreground content is painted over the slide body. Deck foregrounds float above
every inherited grid. Numbering and progress are ordinary
`m.components.progress()` values placed in that foreground. The component reads
Mosaic's logical counters, so all incremental frames from one slide share a
logical slide number.

#embedded-example(
  calepin.elements.gallery,
  "furniture/slide-numbering",
  frames: 2,
  title: "Logical and physical numbering",
)

`foreground` accepts arbitrary Typst content and covers the full usable slide
area. Add any number of native `place` calls to position images, logos, text,
shapes, labels, or counters independently of the slide grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-content",
  frames: 1,
  title: "Arbitrary foreground objects",
)

There is no special logo feature. A reusable logo is ordinary setup foreground
content: put `place(...)` inside `m.setup(content: (foreground: ...))`. The
alignment selects an anchor such as `top + left` or `bottom + right`, and
`dx`/`dy` offset it from there. Because it is the default foreground, any slide
can override it or suppress it with `content: (foreground: none)`.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-image",
  frames: 1,
  title: "Logo in the foreground",
)

= Progress

`m.components.progress()` shows the current position in a deck. Progress
follows Mosaic's logical slide counter automatically, including when a slide
has multiple incremental frames. Use `"1/1"` or `"1"` for numbers, `"circle"`
for a compact corner indicator, and `"line"` for an edge-to-edge bar. Each
variant below sits on the slide foreground, but the component is ordinary
#link("content.html")[content] and can be used in any cell or native container.

#embedded-example(
  calepin.elements.gallery,
  "blocks/progress-numbers",
  frames: 3,
  title: "Foreground numbering with components.progress()",
)

#slideshow(
  calepin.elements.gallery,
  "blocks/progress-line",
  3,
  "Foreground line with components.progress()",
)

Add a progress indicator to any layout, or to a custom grid, through the
reserved `foreground` entry of `content:`. Here `slide-progress()` builds a
two-column slide with a foreground bar:

#embedded-example(
  calepin.elements.gallery,
  "blocks/progress-custom-layout",
  frames: 3,
  title: "A reusable custom-grid slide function with foreground progress",
)

= Background

Background content is painted behind the slide body over the full usable area.
Declare a recurring background with `m.setup(content: (background: ...))`, then
override or suppress it with the same key in one slide's `content:` dictionary.

== Placed content

Native `place` positions images, shapes, and other Typst content independently
of the grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/background-content",
  frames: 1,
  title: "Placed background content",
)

== Photographic backgrounds

Pass a slide-sized image through the reserved `background` entry. The optional
`lighten` and `darken` washes of `m.components.image()` quiet the photograph
and improve contrast with the text in front of it.

#embedded-example(
  calepin.elements.gallery,
  "blocks/background-image",
  frames: 1,
  title: "Full-slide background image",
)

= Navigation

Because Mosaic keeps Typst headings native, the same headings that create
slides can drive tables of contents, breadcrumbs, and links between sections.

== Table of contents

Use Typst's `outline` to create a table of contents. Set `depth: 2` to include
sections and slides, or a smaller depth for a shorter overview. Every entry
links to its heading.

#embedded-example(
  calepin.elements.gallery,
  "furniture/outline",
  frames: 5,
  title: "A linked table of contents",
)

== Breadcrumbs

Use native contextual `query` with a selector ending at `here()` to find the
active section and slide headings. Their `body` fields provide the labels, and
`location()` provides a link target.

#embedded-example(
  calepin.elements.gallery,
  "furniture/breadcrumbs",
  frames: 3,
  title: "Section and slide breadcrumbs",
)

== Section links

Use `query(heading.where(level: 1, outlined: true))` to collect every outlined
section heading. Each result provides a label through `body` and a destination
through `location()`. Compare it with the last matching heading before `here()`
to style the active section differently.

#embedded-example(
  calepin.elements.gallery,
  "furniture/section-links",
  frames: 3,
  title: "Clickable section navigation",
)
