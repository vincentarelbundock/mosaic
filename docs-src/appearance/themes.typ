#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  example-source, slideshow, slideshow-grid,
)
#import "/_includes/site.typ": repo-file

#set document(title: [Themes])
#metadata((title: "Themes")) <website-metadata>

#title()

A theme decides how a deck looks: its colors, its type, and the way each slide arranges what you put on it. Every Mosaic deck uses a theme, even one that never mentions the word. Import the package without naming a theme and you get the default theme. Name a different one and the whole deck changes at once, without a single edit to your slides.

= Selecting themes

Five themes ship with the Mosaic package, and each is a design voice rather than a color scheme: it chooses its own title, section, and content arrangements, its own type, and its own slide furniture.

#table(
  columns: (auto, 1fr),
  [`default`], [The quiet baseline. Plain sans type with the accent kept functional: blue bullets and links, an accent baseline rule on sections, and a small progress ring on numbered slides.],
  [`editorial`], [The magazine. Serif display over a sans body, a kicker masthead title under a strong opening rule, ghost-numeral sections, kicker rules under headings, and a folio in the corner.],
  [`metropolis`], [The homage to the beamer classic. Inverted header bar, and a progress bar that fills across section slides and along the bottom edge of every slide.],
  [`manifesto`], [The poster. One red on warm white, serif set large, uppercase tracked headings, a bordered title plate, rule sections, and a red progress ring.],
  [`mono`], [The terminal. Monospace throughout, dark by default, a `\$` prompt on every heading, panel code blocks, toc sections, and a statusline with a slide counter.],
)

There is no dark theme, because darkness is a palette rather than a design; the Colors section below flips a deck with one line. Import a theme as `m` and the whole deck follows it:

#example-source("appearance/select-metropolis")

The imported theme provides the same `m.slide`, `m.layouts`, `m.components`, notes, pauses, and incremental commands. Every theme exposes an identical API. Moving a deck from one theme to another is a one-line edit at the import.

The default import is the bundled default theme. These two spellings are the same deck:

```typ
// Default spelling
#import "@preview/mosaic:0.0.1" as m
```

```typ
// Explicit spelling
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.default as m
```

The two decks below are that same file. Only the theme on line two differs:

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/select-default", 2, "The small example deck under the default theme", caption: [Default])
  #slideshow(calepin.elements.gallery, "appearance/select-metropolis", 2, "The small example deck under the metropolis theme", caption: [Metropolis])
]

= Running example

The examples below all render the same short deck: a title slide with two authors, four content slides, a section slide, an image slide, and a few components along the way. Only the theme around it changes. So anything you see move, resize, or change color is the theme's doing rather than the content's.

That deck lives in one #repo-file("docs-src/examples/embedded/appearance/_tour-deck.typ")[shared file], which exports a single name. `deck` takes the theme facade as its one argument, so the same body calls `m.slide`, `m.layouts`, and `m.components` whatever theme the example imported as `m`:

```typ
// _tour-deck.typ
#let deck(m) = {
  m.slide("title", numbered: false, title: [The Optimal Number of Naps], ..)

  m.slide(layout: m.layouts.content(variant: "header-body"))[
    == The problem
  ][
    Nobody agrees on how many naps a day is correct. We asked the only expert
    on the subject and he fell asleep during the question.
  ]

  m.slide("section", cells: (section: [The instrument]))

  // four more slides
}
```

Each example imports that one name and ends with `#deck(m)`, which keeps the listing down to the lines worth reading.

= Bundled themes

Five short wrappers each import a different theme and render the running example:

#example-source("appearance/tour-default")

Everything that differs between those five decks is what a theme owns. It is exactly four things:

- a *palette*, one flat dictionary of colors;
- a set of *rules*, ordinary Typst `set` and `show` rules that state the typography;
- a choice of *layouts*, the arrangements a title, section, or content slide is built from;
- optional *furniture*, ordinary `setup` defaults such as a `foreground` progress line or a `background` ghost number, which a deck can override like any other option.

The Customizing section below takes the first three in turn, each on a bundled theme. Open any deck to page through it:

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/tour-default", 8, "The bundled default theme", caption: [Default])
  #slideshow(calepin.elements.gallery, "appearance/tour-editorial", 8, "The bundled editorial theme", caption: [Editorial])
  #slideshow(calepin.elements.gallery, "appearance/tour-metropolis", 8, "The bundled metropolis theme", caption: [Metropolis])
  #slideshow(calepin.elements.gallery, "appearance/tour-manifesto", 8, "The bundled manifesto theme", caption: [Manifesto])
  #slideshow(calepin.elements.gallery, "appearance/tour-mono", 8, "The bundled mono theme", caption: [Mono])
]

= Customizing

A deck reaches every part of its theme through `setup`, without writing a theme of its own: `colors:` for the palette, ordinary `set` and `show` rules for the type, and `layouts:` for the arrangements. That is as far as most decks need to go.

== Colors

A theme's palette is one flat dictionary of eight colors; the #link("colors.html")[Colors] page describes what each entry paints. Pass `colors:` to `setup` to repaint any of them. The override is partial. Naming one color keeps the rest of the theme's palette:

#example-source("appearance/palette-warm")

Both decks below run the default theme. Only the one on the right passes a dictionary to the `colors` argument. That dictionary reaches components too. A callout, card, or badge names a palette entry through its `role:`. The accents and status colors on the last slide follow the same override.

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/palette-default", 8, "The default theme on its own palette", caption: [Default])
  #slideshow(calepin.elements.gallery, "appearance/palette-warm", 8, "The default theme on a warm palette", caption: [Custom palette])
]

=== Dark decks

Polarity is a palette, not a theme. The package bundles one dark palette, and passing it to `colors:` flips any theme to a dark deck; everything adapts on its own, as the #link("colors.html#bundled-palettes")[Colors] page explains:

#example-source("appearance/tour-dark")

The two decks below are the default theme's tour deck once more, identical except for that one `colors:` line:

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/tour-light", 8, "The default theme on its own light palette", caption: [Light palette])
  #slideshow(calepin.elements.gallery, "appearance/tour-dark", 8, "The default theme on the bundled dark palette", caption: [Dark palette])
]

Beyond the polarity pair, the bundled `palettes` collection composes with every theme the same way; the #link("colors.html#bundled-palettes")[Colors] page lists it and renders the default theme under each of its palettes.


== Typography

A theme's typography is ordinary `set` and `show` rules. Rules you write after `#show: m.setup` layer on top of the theme's. There is no separate typography system:

#example-source("appearance/type-custom")

The #link("styling.html")[styling] page covers those rules in full. The #link("../api/labels.html")[label reference] lists every label a slide emits. A theme writes its own rules against that same list.

Rules written that way stay in the deck that holds them. A theme's `apply` is the same list of rules in a function. Moving them there leaves the result identical. It also makes them portable. Run the base theme's `apply` first to keep the rules it already carries:

#example-source("appearance/type-apply")

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/type-default", 8, "The default theme on its own type rules", caption: [Default])
  #slideshow(calepin.elements.gallery, "appearance/type-apply", 8, "The default theme under four added type rules", caption: [Custom type])
]

== Layouts

Every theme supplies three configurable slide layouts: `content`, `title`, and `section`. To customize them, pass a `layouts:` dictionary to `setup`. A replacement is either another built-in layout or a grid of your own:

#example-source("appearance/layout-override")

Explicit `m.slide(...)` commands and automatic heading slides both select from that dictionary. Set it once and the whole deck follows. The #link("../slides/content.html")[Slides] pages cover layouts in full.

The deck on the right borrows a built-in title variant that the default theme does not normally use. Its section layout exists only in that deck:

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/layout-default", 8, "The default theme on its own layouts", caption: [Default])
  #slideshow(calepin.elements.gallery, "appearance/layout-override", 8, "The default theme on a borrowed title layout and a custom section layout", caption: [Custom layouts])
]

= Writing

Everything above lives in the deck that uses it. Move on when you start copying the same three changes between decks. A theme is the dictionary that names them.

== Themes are dictionaries

Bind one in the deck itself to see the whole shape at once. A theme needs only `colors`:

```typ
#import "@preview/mosaic:0.0.1" as mosaic

#let mine = (
  name: "Mine",
  colors: mosaic.palettes.light + (accent: rgb("#a23b72")),
  apply: (body, colors: (:), options: (:)) => {
    set text(font: "EB Garamond", size: 26pt)
    show heading: set text(fill: colors.accent)
    body
  },
)

#show: mosaic.themes.setup(mine)
```

Read `mosaic.themes.setup` carefully, because this page uses the name `setup` for two different things. `mosaic.setup` is the document show rule you apply to a deck. `mosaic.themes.setup` sets up nothing on its own. It takes a definition and *returns* a show rule of that kind. Its three keys map exactly onto the three sections above:

#table(
  columns: (auto, 1fr),
  [`colors`], [The palette. The same flat dictionary `setup` takes.],
  [`apply`], [The rules. The same `set` and `show` rules, in a function.],
  [`layouts`], [The layout choice. The same dictionary `setup` takes.],
)

Three further keys carry the rest of a theme:

#table(
  columns: (auto, 1fr),
  [`name`], [The theme's display name, which its error messages quote. Defaults to `"Custom"`.],
  [`defaults`], [Ordinary `setup` options the theme presets, such as `spacing` or `overflow`. A deck can still override any of them.],
  [`options`], [The theme's own options and their defaults, covered below.],
)

== What `apply` owns

Mosaic's engine emits no slide typography of its own. Every rule a slide renders with comes from the active theme. So a theme built from scratch states its whole look in `apply`, down to the labels a slide emits. The #link("../api/labels.html")[label reference] is the checklist: a theme that styles `mosaic-cell-title` but forgets `mosaic-cell-section` renders section slides in the engine's bare defaults, and nothing warns about it.

A theme may omit `apply`. It then changes colors and layouts only, and every slide falls back to Typst's own text defaults. A theme derived from a bundled one inherits that theme's rules and can leave `apply` alone.

The engine keeps two rules of its own, on `<mosaic-note-heading>` and `<mosaic-note-body>`. They style the printed speaker and notes pages. That furniture must read black on white whatever the theme does. A theme or deck rule on the same label overrides them.

== Customize a theme

Every bundled theme exports the `definition` behind its own `setup`. Varying a bundled look is therefore an ordinary dictionary merge:

```typ
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as base

#let mine = base.definition + (
  name: "Mine",
  colors: base.definition.colors + (accent: rgb("#0f766e")),
)

#show: mosaic.themes.setup(mine)
```

Two details decide whether that merge does what you meant.

The merge replaces a key outright. Writing `colors: (accent: ..)` would hand the engine a palette of one color rather than a recolored one. That is why the example merges into `base.definition.colors` instead. The same applies to `layouts` and `options`.

Replacing `apply` discards the base theme's entire look, since `apply` is the look. To add rules on top of an inherited one, run the base theme's own rules first, as the Typography section does.

Only the root package exports `mosaic.themes`. A bundled theme such as `mosaic.themes.metropolis` exports `setup`, `layouts`, `components`, and `definition`, but not the `themes` namespace itself. Deriving from one therefore means importing the root package as well, as above.

== Shipping it

Once a theme is worth reusing, give it a file of its own. That file re-exports the shared Mosaic API alongside the theme's `setup` and `layouts`. A deck then imports it exactly as it would a bundled theme, and never learns that it is not one:

```typ
// mytheme.typ
#import "@preview/mosaic:0.0.1": slide, note, fit, surface, grids, steps, components, themes
#import "definition.typ": definition
#import "layouts.typ" as layouts
#let setup = themes.setup(definition)
```

Those are the names a deck expects to find: `setup` and `layouts` at least, plus whatever else it uses from `m`. `themes.setup` validates the definition on the spot. A malformed theme therefore fails on that line, rather than somewhere inside a deck that imports it.

The deck below imports a complete theme in that shape. Its three files sit beside the deck in the repository: the importable file, the definition dictionary, and the layout functions.

#example-source("appearance/starter-theme")

It is the running example once more, this time under a theme of its own:

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/starter-default", 8, "The default theme on its own look", caption: [Default])
  #slideshow(calepin.elements.gallery, "appearance/starter-theme", 8, "The starter theme", caption: [Starter theme])
]

== Theme-specific options

`options` declares choices Mosaic itself knows nothing about. The theme below declares one, `density`, and reads it in `apply`:

#example-source("appearance/_option-theme")

Each name in `options` becomes a named argument of the setup the definition produces. A deck passes a value, or says nothing and takes the theme's default:

#example-source("appearance/theme-options-dense")

Mosaic hands the resolved options to `layouts` as well as `apply`, so `layouts` may be a function of them rather than a fixed dictionary. That is what lets one option offer genuinely different arrangements rather than only a different type size.

An option name that collides with a built-in `setup` option raises an error where you bind the theme. Every other named argument a deck passes falls through to `setup` as usual.

The #link("../api/theme.html")[theme authoring API] documents every definition key in full.

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/theme-options-airy", 8, "The seminar theme at its default density", caption: [Default])
  #slideshow(calepin.elements.gallery, "appearance/theme-options-dense", 8, "The seminar theme at its dense setting", caption: [density: dense])
]
