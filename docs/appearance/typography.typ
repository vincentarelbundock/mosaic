#set document(title: [Typography and color])
#metadata((title: "Typography and color")) <website-metadata>

#title()

= Typography

Place native Typst text and heading rules after `m.setup` so they apply across the deck:

```typ
#show: m.setup
#set text(font: "EB Garamond", size: 26pt)
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
#show heading.where(depth: 2): set text(size: 1.4em)
```

A semantic heading feeds outlines, bookmarks, and content slides. Use `text` directly for display type that should not appear in navigation, or exclude the heading:

```typ
#text(size: 60pt, weight: "black")[BOLD]
#heading(outlined: false, bookmarked: false)[Aside]
```

Leading, lists, and captions remain native `par`, `list`, `enum`, `terms`, and `figure.caption` styling.

A heading cannot be placed inside an incremental grid node (`m.grid.on`, `m.steps.reveal`, and related reducers); keep it structurally stable across a slide's frames.

= Color

Each theme supplies a complete color palette. Override only the deck-wide colors that need to change; omitted colors keep the theme defaults:

```typ
#show: m.setup.with(colors: (
  canvas: rgb("#f4f8f7"),
  accent: rgb("#007f73"),
))
```

The accepted roles are `canvas`, `surface`, `text`, `muted`, `line`, and `accent`. Unknown roles and non-color values are errors. The canvas, typography, components, and layouts all use the resolved values. Explicit component colors remain local overrides:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body"),
  content: (foreground: [
    #place(bottom + left)[
      #m.components.progress(
        variant: "line",
        width: 100%,
        color: rgb("#e69f00"),
      )
    ]
  ]),
)[Title][Body]
```

Native rules after `m.setup` are still the right tool for typography or a special local composition:

```typ
#[
  #show label("mosaic-cell-body"): set text(fill: white)
  #m.slide(
    content: (background: block(width: 100%, height: 100%, fill: rgb("#111827"))),
  )[Dark for this slide only]
]
```

Color collections remain ordinary Typst arrays. Define them near the chart or diagram that uses them, or import a color package. Component `role:` values remain local to components such as `frame`, `label`, and `quote`.

To recolor an entire slide at once, use the `<mosaic-slide>` label described under #link("styling.html#styling-a-whole-slide")[Styling a whole slide].
