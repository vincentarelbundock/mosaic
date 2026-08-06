#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  slideshow,
  thumbnail-gallery,
)

#set document(title: [Footer and progress])
#metadata((title: "Footer and progress")) <website-metadata>

#title()

= Default footer content

Most decks repeat the same source, event name, or organization in every ordinary slide footer. Declare that value once in setup:

```typ
#show: m.setup.with(
  content: (
    footer: [Mosaic · Engineering],
  ),
)
```

The default applies whenever the slide's layout contains a cell named `footer`. A title slide has no such cell, so it is unaffected. With a default footer, positional content supplies only the remaining cells:

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

A complete positional body list remains valid and overrides every corresponding default. The footer is an ordinary cell, and there is no separate global footer feature, so footers cannot overlap slide numbers, progress indicators, or the slide body.

#embedded-example(
  calepin.elements.gallery,
  "structure/setup-content",
  frames: 3,
  title: "A default footer, a slide override, and explicit suppression",
  renderer: thumbnail-gallery,
)

= Progress

`m.components.progress()` shows the current position in a deck. All frames from one incremental slide share the same slide number. Use `"1/1"` or `"1"` for numbers, `"circle"` for a compact indicator, and `"line"` for a full-width bar.

A recurring progress line along the bottom edge is one foreground entry in setup. The foreground plane is already a full-slide block, so `align` alone places the bar, and because the plane takes no space from the grid, the line does not shrink the slide body:

```typ
#show: m.setup.with(
  content: (
    foreground: align(bottom, m.components.progress(variant: "line")),
  ),
)
```

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
