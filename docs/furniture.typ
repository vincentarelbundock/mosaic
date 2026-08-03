#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  slideshow,
  thumbnail-gallery,
)

#set document(title: [Furniture])
#metadata((title: "Furniture")) <website-metadata>

#title()

Cells occupy the main slide body. The background plane sits behind them and the foreground plane sits above them. Both cover the slide without changing the grid. Put recurring plane content in `m.setup(content:)`, or set it for one slide with `m.slide(content:)`. Use `none` on a slide to hide inherited content. Footer text belongs in a grid cell because it takes part in the layout.

= Default footer content

Most decks repeat the same source, confidentiality notice, event name, or organization in every ordinary slide footer. Declare that value once as partial setup content:

```typ
#show: m.setup.with(
  content: (
    footer: [Mosaic · Engineering],
  ),
)
```

The default applies whenever the resolved layout contains a content-bearing cell named `footer`. A title slide has no such cell, so it is unaffected. With a default footer, positional content supplies only the remaining cells:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
)[RESULTS][Main result]
```

Named content can likewise omit `footer`. An explicit value overrides the deck default, while `none` suppresses it on one slide:

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

A complete positional body list remains valid and overrides every corresponding default. Footer content has only this cell-based mechanism. There is no separate global footer feature, so it cannot unexpectedly overlap slide numbers, progress, or the slide body.

#embedded-example(
  calepin.elements.gallery,
  "structure/setup-content",
  frames: 3,
  title: "A default footer, a slide override, and explicit suppression",
  renderer: thumbnail-gallery,
)

= Background

Background content is painted behind the slide body over the full usable area.

== Placed content

Native `place` positions images, shapes, and other Typst content independently of the grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/background-content",
  frames: 1,
  title: "Placed background content",
)

== Photographic backgrounds

Pass a slide-sized image through the reserved `background` entry. The optional `lighten` and `darken` washes of `m.components.image()` quiet the photograph and improve contrast with the text in front of it.

#embedded-example(
  calepin.elements.gallery,
  "blocks/background-image",
  frames: 1,
  title: "Full-slide background image",
)

= Foreground

Foreground content is painted over the slide body. Use native `place` calls to position images, logos, text, shapes, labels, or counters independently of the grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-content",
  frames: 1,
  title: "Arbitrary foreground objects",
)

Put a recurring logo in `m.setup(content: (foreground: ...))`. Any slide can replace it or hide it with `content: (foreground: none)`.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-image",
  frames: 1,
  title: "Logo in the foreground",
)

= Progress

`m.components.progress()` shows the current position in a deck. All frames from one incremental slide share the same slide number. Use `"1/1"` or `"1"` for numbers, `"circle"` for a compact indicator, and `"line"` for a full-width bar.

#embedded-example(
  calepin.elements.gallery,
  "furniture/slide-numbering",
  frames: 2,
  title: "Logical and physical numbering",
)

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

The component can sit in a foreground, a cell, or another Typst container. This example adds a foreground bar to a custom grid:

#embedded-example(
  calepin.elements.gallery,
  "blocks/progress-custom-layout",
  frames: 3,
  title: "A reusable custom-grid slide function with foreground progress",
)

= Navigation

Because Mosaic keeps Typst headings native, the same headings that create slides can drive tables of contents, breadcrumbs, and links between sections.

== Table of contents

Use Typst's `outline` to create a table of contents. Set `depth: 2` to include sections and slides, or a smaller depth for a shorter overview. Every entry links to its heading.

#embedded-example(
  calepin.elements.gallery,
  "furniture/outline",
  frames: 5,
  title: "A linked table of contents",
)

== Breadcrumbs

Use native contextual `query` with a selector ending at `here()` to find the active section and slide headings. Their `body` fields provide the labels, and `location()` provides a link target.

#embedded-example(
  calepin.elements.gallery,
  "furniture/breadcrumbs",
  frames: 3,
  title: "Section and slide breadcrumbs",
)

== Section links

Use `query(heading.where(level: 1, outlined: true))` to collect every outlined section heading. Each result provides a label through `body` and a destination through `location()`. Compare it with the last matching heading before `here()` to style the active section differently.

#embedded-example(
  calepin.elements.gallery,
  "furniture/section-links",
  frames: 3,
  title: "Clickable section navigation",
)
