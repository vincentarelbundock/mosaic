#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Themes])
#metadata((title: "Themes")) <website-metadata>

#title()

Themes separate a deck's content from its visual system. Use a bundled theme when its palette and typography fit the talk; develop a theme when the design needs to become reusable.

= Using themes

Five themes ship inside the package under `m.themes`: `light`, `dark`, `metropolis`, `cream`, and `minimalist`. Import one as `m`:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m
#show: m.setup.with(
  title: [My talk],
  subtitle: [With a borrowed look],
)

#m.slide(layout: m.layouts.title())
== First slide
#m.slide(
  layout: m.layouts.section(),
  content: (section: [A new chapter]),
)
```

The imported theme provides the same `m.slide`, `m.layouts`, `m.components`, notes, pauses, and incremental commands. Use `m.setup.with(...)` for deck information, color overrides, recurring content, and presentation options.

The default import uses the bundled light theme:

```typ
// Default spelling
#import "@local/mosaic:0.0.1" as m
```

```typ
// Explicit light spelling
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as m
```

Choose the dark theme to apply dark colors to slides, layouts, code, tables, links, and muted text:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m
#show: m.setup
```

#embedded-example(
  calepin.elements.gallery,
  "appearance/dark-theme",
  frames: 3,
  title: "The bundled dark theme across title, technical content, and section slides",
)

= Developing themes

Create a custom theme when several decks should share the same colors, typography, layouts, and component styles.

A theme is a plain dictionary, so the quickest way to start is to bind one in the deck itself. Only `colors` is required, and `apply` holds every `set` and `show` rule the theme owns:

```typ
#let mine = (
  name: "Mine",
  colors: (
    canvas: white, surface: rgb("#f5f5f5"), text: rgb("#17243a"),
    muted: rgb("#52657f"), line: rgb("#aeb9c8"), accent: rgb("#a23b72"),
  ),
  apply: (body, colors: (:), options: (:)) => {
    set text(font: "EB Garamond", size: 26pt, fill: colors.text)
    show heading: set text(fill: colors.accent)
    body
  },
)

#show: m.theme.setup(mine)
```

Because the engine emits no slide typography, a theme states its whole look, including the rules that style the canonical `<mosaic-cell-*>` vocabulary. Copy Light's `definition.typ` to see that complete set in its plainest form. The engine's only rules of its own style the printed `speaker` and `notes` pages, whose furniture must read black-on-white regardless of theme; they live on the `<mosaic-note-heading>` and `<mosaic-note-body>` labels, and a theme or deck rule on the same label overrides them.

Every facade also exports the definition its `setup` is bound to, so a theme can start from a bundled one by ordinary dictionary merge:

```typ
#import mosaic.themes.dark as base
#let mine = base.definition + (
  name: "Mine",
  colors: base.definition.colors + (accent: rgb("#7cc4ff")),
)
```

The merge replaces a key outright, so to add rules to an inherited `apply` rather than discard it, run the base callback first:

```typ
apply: (body, colors: (:), options: (:)) => {
  show: (base.definition.apply).with(colors: colors, options: options)
  show heading: set text(weight: "black")
  body
}
```

The example below shows the files in a complete theme.

#embedded-example(
  calepin.elements.gallery,
  "appearance/starter-theme",
  frames: 5,
  title: "The starter theme deck",
)

Use the #link("../api/theme.html")[Theme authoring API] when turning that design into a reusable package.
