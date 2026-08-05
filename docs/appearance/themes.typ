#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example, example-source, thumbnail-gallery, thumbnail-gallery-items,
)

#set document(title: [Themes])
#metadata((title: "Themes")) <website-metadata>

#title()

Every deck on this site renders through a theme, including the ones that never mention the word. A theme is what supplies the colors, the typography, and the layouts a slide is composed from, and switching themes changes all three at once without touching a line of content.

= What a theme is

The five decks below are the same file. One shared body declares the title, the subtitle, and the date, and five four-line wrappers each import a different theme and render it.

#example-source("appearance/tour-light")

#thumbnail-gallery-items(
  calepin.elements.gallery,
  (
    ("/assets/examples/appearance/tour-light-1.svg", "The bundled light theme", [Light]),
    ("/assets/examples/appearance/tour-dark-1.svg", "The bundled dark theme", [Dark]),
    ("/assets/examples/appearance/tour-cream-1.svg", "The bundled cream theme", [Cream]),
    ("/assets/examples/appearance/tour-metropolis-1.svg", "The bundled metropolis theme", [Metropolis]),
    ("/assets/examples/appearance/tour-minimalist-1.svg", "The bundled minimalist theme", [Minimalist]),
  ),
  columns: 2,
)

Everything that differs between those five images is what a theme owns, and it is exactly three things:

- a *palette*, one flat dictionary of colors;
- a set of *rules*, ordinary Typst `set` and `show` rules that state the typography;
- a choice of *layouts*, the compositions a title, section, or content slide is built from.

The rest of this page takes those three in turn, showing how to change each one on a bundled theme. That is as far as most decks need to go. If a look turns out to be worth reusing, the #link("theme-authoring.html")[theme authoring] page shows how to bundle the same three changes into a theme of your own.

= Using a bundled theme

Five themes ship inside the package under `m.themes`: `light`, `dark`, `cream`, `metropolis`, and `minimalist`. Import one as `m`:

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
  cells: (section: [A new chapter]),
)
```

The imported theme provides the same `m.slide`, `m.layouts`, `m.components`, notes, pauses, and incremental commands. Every theme exposes an identical API, so moving a deck from one to another is a one-line edit at the import.

The default import is the bundled light theme, so these two spellings are the same deck:

```typ
// Default spelling
#import "@local/mosaic:0.0.1" as m
```

```typ
// Explicit light spelling
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as m
```

The dark theme is the one bundled look designed for a dark room, and it recolors slides, layouts, code, tables, links, and muted text together:

#embedded-example(
  calepin.elements.gallery,
  "appearance/dark-theme",
  frames: 3,
  title: "The bundled dark theme across title, technical content, and section slides",
)

= Changing the palette

A theme's palette is one flat dictionary of colors. Six name the deck's own chrome and two name the status colors components paint with:

#table(
  columns: (auto, 1fr),
  [`canvas`], [The page fill behind every slide.],
  [`surface`], [Raised panels: the fill a neutral card or badge sits on.],
  [`text`], [Body text.],
  [`muted`], [Secondary text: captions, footers, fine print.],
  [`line`], [Drawn rules, borders, and dividers.],
  [`accent`], [The deck's emphasis color.],
  [`warning`], [A remark that qualifies what is on the slide.],
  [`error`], [A remark that contradicts it.],
)

Pass `colors:` to `setup` to override any of them. The override is partial, so naming one color keeps the rest of the theme's palette:

```typ
#show: m.setup.with(
  colors: (accent: rgb("#7c3aed")),
)
```

This is the whole color surface of a deck. There is no second palette for components: a component's `role:` argument names one of these entries, so recoloring the palette recolors every card, callout, badge, and progress indicator that uses it.

#embedded-example(
  calepin.elements.gallery,
  "appearance/palette-override",
  frames: 1,
  title: "Components following two overridden palette entries",
  renderer: thumbnail-gallery,
  columns: 1,
)

A component paints its border and rails in its role's color, its text in the deck's `text`, and its panel in that color mixed lightly into `canvas`. Mixing toward the canvas rather than toward white is what lets one rule serve a light and a dark theme: the same `warning` produces a pale wash on light paper and a deep one on a dark stage, with no per-theme table of fills.

`neutral` is the one role name that is not a palette entry. It means the deck's own `surface`, outlined in `line`, which is what an unemphasized panel should be.

When a component needs a color the palette does not name, pass it directly rather than inventing a role. Every component takes flat `fill`, `accent`, `stroke`, `radius`, `inset`, `align`, and `text` overrides, each defaulting to `auto`, which means "take it from the role":

```typ
#m.components.callout(accent: rgb("#7c3aed"), title: [Takeaway])[
  Bounded work beats unbounded intent.
]
```

Reach for `role:` when the meaning is portable and should survive a theme change, and for `accent:` when the color is a one-off.

= Changing the type

A theme's typography is ordinary `set` and `show` rules, and rules you write after `#show: m.setup` layer on top of the theme's. There is no separate typography system:

```typ
#show: m.setup
#set text(font: "EB Garamond")
#show heading: set text(weight: "black")
```

Rules that target a particular part of a slide go through its label. Every cell is a block labeled `<mosaic-cell-ID>`, and the designed title and section layouts label each text tier they emit:

```typ
#show label("mosaic-cell-body"): set text(size: 0.9em)
#show label("mosaic-title-display"): set text(tracking: -0.02em)
```

The #link("styling.html")[styling] page covers those rules in full, and the #link("../reference/labels.html")[label reference] lists every label a slide emits. That list is also the checklist a theme's own rules are written against, which is why it matters here.

= Changing the layouts

Layouts are the compositions a slide is built from, and `setup` takes a `layouts:` dictionary that replaces the theme's choice for any of `content`, `title`, and `section`:

```typ
#show: m.setup.with(
  layouts: (
    content: m.layouts.content(variant: "header-body-footer"),
    title: m.layouts.title(variant: "swiss"),
  ),
)
```

Both explicit `m.slide(...)` commands and automatic heading slides select from the same dictionary, so setting it once changes the whole deck. Layouts are covered in full under #link("../slides/content.html")[Slides].

= Where to stop

The three sections above cover nearly every deck. Palette overrides, a few rules, and a layout choice at `setup` will restyle a talk completely, and all of it lives in the deck that uses it.

Move on when the same three changes start being copied between decks. That is the point at which they are worth naming, and #link("theme-authoring.html")[writing a theme] is how you name them.
