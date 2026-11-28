# Themes

A theme decides how a deck looks: its colors, its type, and the way each slide arranges what you put on it. Every Mosaic deck uses a theme, even one that never mentions the word. Import the package without naming a theme and you get the default theme. Name a different one and the whole deck changes at once, without a single edit to your slides.

> **Requires Mosaic 0.0.3.** `themes.decorate-heading` is new, and `setup(font:, base-size:)` now works under a custom theme that declares neither. Every example on this page compiles under the released version as it stands. This is the development version, which is not on Typst Universe yet: a deck that uses it imports `@local/mosaic:0.0.3` rather than the released `@preview/mosaic:0.0.1`. See [Install](../start/install.md).

## Selecting themes

Five themes ship with the Mosaic package, and each is a design voice rather than a color scheme: it chooses its own title, section, and content arrangements, its own type, and its own slide furniture.

|  |  |
| --- | --- |
| `default` | The quiet baseline. Plain sans type with the accent kept functional: blue bullets and links, an accent baseline rule on sections, and a small progress ring on numbered slides. |
| `editorial` | The magazine. Serif display over a sans body, a kicker masthead title under a strong opening rule, ghost-numeral sections, kicker rules under headings, and a folio in the corner. |
| `metropolis` | The homage to the beamer classic. Inverted header bar, and a progress bar that fills across section slides and along the bottom edge of every slide. |
| `manifesto` | The poster. One red on warm white, serif set large, uppercase tracked headings, a bordered title plate, rule sections, and a red progress ring. |
| `mono` | The terminal. Monospace throughout, dark by default, a `\$` prompt on every heading, panel code blocks, toc sections, and a statusline with a slide counter. |

There is no dark theme, because darkness is a palette rather than a design; the Colors section below flips a deck with one line. Import a theme as `m` and the whole deck follows it:

```typ
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m

#show: m.setup.with(
  title: [The Optimal Number of Naps],
  subtitle: [Findings from a subject who slept through the study],
  authors: [Ada Lovelace],
  date: [March 2026],
)

#m.slide("title")

== First slide

A theme is a one-line decision.
```

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

## Running example

The examples below all render the same short deck: a title slide with two authors, four content slides, a section slide, an image slide, and a few components along the way. Only the theme around it changes. So anything you see move, resize, or change color is the theme's doing rather than the content's.

That deck lives in one [shared file](https://github.com/vincentarelbundock/mosaic/blob/main/docs-src/examples/embedded/appearance/_tour-deck.typ), which exports a single name. `deck` takes the theme facade as its one argument, so the same body calls `m.slide`, `m.layouts`, and `m.components` whatever theme the example imported as `m`:

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

## Bundled themes

Five short wrappers each import a different theme and render the running example:

```typ
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.default as m
#import "_tour-deck.typ": deck

#show: m.setup

#deck(m)
```

Everything that differs between those five decks is what a theme owns. It is exactly four things:

- a **palette**, one flat dictionary of colors;
- a set of **rules**, ordinary Typst `set` and `show` rules that state the typography;
- a choice of **layouts**, the arrangements a title, section, or content slide is built from;
- optional **furniture**, ordinary `setup` defaults such as a `foreground` progress line or a `background` ghost number, which a deck can override like any other option.

The Customizing section below takes the first three in turn, each on a bundled theme. Open any deck to page through it:

## Customizing

A deck reaches every part of its theme through `setup`, without writing a theme of its own: `colors:` for the palette, `font:` and `base-size:` plus ordinary `set` and `show` rules for the type, and `layouts:` for the arrangements. That is as far as most decks need to go.

### Colors

A theme's palette is one flat dictionary of eight colors; the [Colors](colors.md) page describes what each entry paints. Pass `colors:` to `setup` to repaint any of them. The override is partial. Naming one color keeps the rest of the theme's palette:

```typ
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.default as m
#import "_tour-deck.typ": deck

#show: m.setup.with(
  colors: (
    canvas: rgb("#fdf6ee"),
    surface: rgb("#fffdfa"),
    text: rgb("#2b1d12"),
    muted: rgb("#8a7462"),
    line: rgb("#ead9c6"),
    accent: rgb("#b4530a"),
  ),
)

#deck(m)
```

Both decks below run the default theme. Only the one on the right passes a dictionary to the `colors` argument. That dictionary reaches components too. A callout, card, or badge names a palette entry through its `role:`. The accents and status colors on the last slide follow the same override.

#### Dark decks

Polarity is a palette, not a theme. The package bundles one dark palette, and passing it to `colors:` flips any theme to a dark deck; everything adapts on its own, as the [Colors](colors.md#bundled-palettes) page explains:

```typ
#import "@preview/mosaic:0.0.1" as m
#import "_tour-deck.typ": deck

#show: m.setup.with(colors: m.palettes.dark)

#deck(m)
```

The two decks below are the default theme's tour deck once more, identical except for that one `colors:` line:

Beyond the polarity pair, the bundled `palettes` collection composes with every theme the same way; the [Colors](colors.md#bundled-palettes) page lists it and renders the default theme under each of its palettes.

### Typography

A theme's typography starts from two options every theme has, `font` and `base-size`, which `setup` takes under any theme. The rest is ordinary `set` and `show` rules. Rules you write after `#show: m.setup` layer on top of the theme's. There is no separate typography system:

```typ
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.default as m
#import "_tour-deck.typ": deck

#show: m.setup

// Native rules, written after `setup`, layer on top of the theme's own.
#set text(font: "Libertinus Serif", size: 22pt)
#show heading: set text(weight: "regular", style: "italic")
#show label("mosaic-cell-section"): set text(weight: "regular")
#show label("mosaic-title-display"): set text(weight: "regular")

#deck(m)
```

The [styling](styling.md) page covers those rules in full. The [label reference](../api/labels.md) lists every label a slide emits. A theme writes its own rules against that same list.

Choices written that way stay in the deck that holds them. A theme carries the same ones: the font and base size become its `options`, and its `apply` is the same list of rules in a function. Moving them there leaves the result identical. It also makes them portable. Run the base theme's `apply` first to keep the rules it already carries:

```typ
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.default as m
#import "_tour-deck.typ": deck

// The same four rules, carried by a theme instead of the deck. `apply` runs the
// default theme's own rules first, then layers these on top.
#let serif = m.definition + (
  name: "Serif",
  apply: (body, colors: (:), options: (:)) => {
    show: (m.definition.apply).with(colors: colors, options: options)
    set text(font: "Libertinus Serif", size: 22pt)
    show heading: set text(weight: "regular", style: "italic")
    show label("mosaic-cell-section"): set text(weight: "regular")
    show label("mosaic-title-display"): set text(weight: "regular")
    body
  },
)

#show: mosaic.themes.setup(serif)

#deck(m)
```

### Layouts

Every theme supplies three configurable slide layouts: `content`, `title`, and `section`. To customize them, pass a `layouts:` dictionary to `setup`. A replacement is either another built-in layout or a grid of your own:

```typ
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.default as m

#import "_tour-deck.typ": deck

// A section slide of our own: a rule across the top, the title beneath it.
#let chapter = m.grids.rows(
  m.grids.track(auto, m.grids.cell("rule", content: line(length: 100%, stroke: 3pt))),
  "section",
)

#show: m.setup.with(
  layouts: (
    title: m.layouts.title(variant: "bordered"),
    section: chapter,
  ),
)

#deck(m)
```

Explicit `m.slide(...)` commands and automatic heading slides both select from that dictionary. Set it once and the whole deck follows. The [Slides](../slides/content.md) pages cover layouts in full.

The deck on the right borrows a built-in title variant that the default theme does not normally use. Its section layout exists only in that deck:

## Writing

Everything above lives in the deck that uses it. Move on when you start copying the same three changes between decks. A theme is the dictionary that names them.

### Themes are dictionaries

Bind one in the deck itself to see the whole shape at once. A theme needs only `colors`:

```typ
#import "@preview/mosaic:0.0.1" as mosaic

#let mine = (
  name: "Mine",
  colors: mosaic.palettes.light + (accent: rgb("#a23b72")),
  options: (font: "EB Garamond", base-size: 26pt),
  apply: (body, colors: (:), options: (:)) => {
    show heading: set text(
      size: options.base-size * 1.5,
      fill: colors.accent,
    )
    body
  },
)

#show: mosaic.themes.setup(mine)
```

Read `mosaic.themes.setup` carefully, because this page uses the name `setup` for two different things. `mosaic.setup` is the document show rule you apply to a deck. `mosaic.themes.setup` sets up nothing on its own. It takes a definition and **returns** a show rule of that kind. Three of its keys map exactly onto the three sections above:

|  |  |
| --- | --- |
| `colors` | The palette. The same flat dictionary `setup` takes. |
| `apply` | The rules. The same `set` and `show` rules, in a function. |
| `layouts` | The layout choice. The same dictionary `setup` takes. |

Three further keys carry the rest of a theme:

|  |  |
| --- | --- |
| `name` | The theme's display name, which its error messages quote. Defaults to `"Custom"`. |
| `defaults` | Ordinary `setup` options the theme presets, such as `spacing` or `overflow`. A deck can still override any of them. |
| `options` | The theme's own options and their defaults, covered below. |

### What `apply` owns

Mosaic's engine states the base typography and nothing else: it fills the canvas, and sets the text fill from the palette's `text` color and the font and size from the resolved `font` and `base-size` options. Every other rule a slide renders with comes from the active theme. Both values reach `apply` resolved, as `options.font` and `options.base-size`; state heading sizes as multiples of `options.base-size` rather than in `em`, because an em size multiplies with Typst's own per-level heading scale and so changes under `set heading(offset: ..)`. So a theme built from scratch states the rest of its look in `apply`, down to the labels a slide emits. The [label reference](../api/labels.md) is the checklist: a theme that styles `mosaic-cell-title` but forgets `mosaic-cell-section` renders section slides in the engine's bare defaults, and nothing warns about it.

A theme may omit `apply`. It then changes colors, defaults, and layouts only, and every slide renders in the deck's font, base size, and text color with Typst's own defaults for the rest. Every theme has the `font` and `base-size` options, whether or not its definition declares them; a theme that declares neither gets Typst's own font at 24pt. A theme derived from a bundled one inherits that theme's rules and can leave `apply` alone.

The engine keeps two rules of its own, on `<mosaic-note-heading>` and `<mosaic-note-body>`. They style the printed speaker and notes pages. That furniture must read black on white whatever the theme does, so the rules force the color and nothing else: the note text inherits the deck's base size rather than a size of its own. A theme or deck rule on the same label overrides them.

### Heading rules that rebuild the heading

One kind of rule needs a helper. On a slide with several frames, the slide's heading is a real `heading` element on one frame only; the other frames repeat its appearance, so the outline and the bookmarks see one heading per slide. Mosaic replays a theme's `set` rules on those frames by itself. A rule that **rebuilds** the heading, `show heading: it => ..`, has nothing to match there, so it is declared through `themes.decorate-heading` instead, which applies it on every frame:

```typ
apply: (body, colors: (:), options: (:)) => {
  // A short accent rule under every slide title, on every frame.
  show: mosaic.themes.decorate-heading.with(depth: 2, it => block(width: 100%)[
    #it
    #line(length: 2em, stroke: 2pt + colors.accent)
  ])
  body
},
```

`depth` is the number of `=` signs, so `depth: 2` selects the headings that title content slides. The function receives the heading on one frame and a stand-in on the others, so it places its argument rather than reading its fields. The same helper works in a deck, as an ordinary `#show:` rule after `setup`. The [theme authoring API](../api/theme.md#themes.decorate-heading) documents its arguments.

### Customize a theme

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

### Shipping it

Once a theme is worth reusing, give it a file of its own. That file re-exports the shared Mosaic API alongside the theme's `setup` and `layouts`. A deck then imports it exactly as it would a bundled theme, and never learns that it is not one:

```typ
// mytheme.typ
#import "@preview/mosaic:0.0.1": slide, note, fit, grids, steps, components, themes
#import "definition.typ": definition
#import "layouts.typ" as layouts
#let setup = themes.setup(definition)
```

Those are the names a deck expects to find: `setup` and `layouts` at least, plus whatever else it uses from `m`. `themes.setup` validates the definition on the spot: a missing or misspelled color is named, as are unknown `defaults` keys and an incomplete `layouts` dictionary. A malformed theme therefore fails on that line, rather than somewhere inside a deck that imports it.

The deck below imports a complete theme in that shape. Its three files sit beside the deck in the repository: the importable file, the definition dictionary, and the layout functions.

```typ
// A custom theme is imported exactly as a bundled one would be.
#import "/docs-src/examples/embedded/appearance/_starter-theme.typ" as m
#import "_tour-deck.typ": deck

#show: m.setup

#deck(m)
```

It is the running example once more, this time under a theme of its own:

### Theme-specific options

`options` declares choices Mosaic itself knows nothing about. The theme below declares one, `density`, and reads it in `apply`:

```typ
// A theme with one option of its own, in the importable shape a deck expects.
#import "@preview/mosaic:0.0.1": (
  slide, note, fit, grids, steps, components, themes, layouts,
)
#import "@preview/mosaic:0.0.1" as mosaic

#let base = mosaic.themes.default.definition

// `density` is the theme's own option. Mosaic knows nothing about it: the name
// simply becomes a named argument of the setup below, and its resolved value
// reaches `apply`.
#let seminar = base + (
  name: "Seminar",
  options: base.options + (density: "airy"),
  apply: (body, colors: (:), options: (:)) => {
    let size = if options.density == "airy" { 30pt } else { 22pt }
    show: (base.apply).with(colors: colors, options: options + (base-size: size))
    body
  },
)

#let setup = themes.setup(seminar)
```

Each name in `options` becomes a named argument of the setup the definition produces. A deck passes a value, or says nothing and takes the theme's default:

```typ
// `density` is the theme's option, so its setup accepts it as a named argument.
#import "_option-theme.typ" as m
#import "_tour-deck.typ": deck

#show: m.setup.with(density: "dense")

#deck(m)
```

Mosaic hands the resolved options to `layouts` as well as `apply`, so `layouts` may be a function of them rather than a fixed dictionary. That is what lets one option offer genuinely different arrangements rather than only a different type size.

An option name that collides with a built-in `setup` option raises an error where you bind the theme. `font` and `base-size` are the exception: they are theme options, and a theme declares its own values for them under `options`. Every other named argument a deck passes falls through to `setup` as usual.

The [theme authoring API](../api/theme.md) documents every definition key in full.

## Case study

In this case study, we modify the content slides of an existing theme, by creating our own custom layout.

Mosaic takes advantage of the fact that every slide is composed of a grid of cells. You control how those cells are filled, which colors are used, and so on. You assemble a mosaic by splitting rows and columns, not unlike a tree structure; the Mosaic logo highlights that core aspect.

Because every slide is a grid, Mosaic ships with a number of built-in grids. That alleviates the need to start from scratch and addresses common formatting and style preferences. Those built-in grids are the **layouts**, and there are defaults for the common elements of a presentation: a title slide, a section slide, and a content slide.

A theme, in this context, is a dictionary containing standard color tokens (`canvas` for the background, `accent` for highlighted aspects, `text`, etc.) alongside the rules and layouts described above.

In this example, we create a new "content" slide with a custom footer. The code is shown first, with commentary after.

```typ
// a slide is composed of a grid
#let footered = m.grids.rows(         
  // 1st row cell is called "header" and its height is automatic based on content (auto)
  m.grids.track(auto, "header"),      
  // 2nd row cell is called "body" and its height takes all the available space (1fr)
  m.grids.track(1fr, "body"),
  // 3rd row cell is called "footer" and its height is automatic based on content (auto)
  m.grids.track(auto, m.grids.cell(
    "footer",
    // the footer cell has default content that will appear on every slide using that layout
    content: [
      Mosaic                     // text
      #h(1fr)                    // space
      #m.components.progress()   // slide number
    ],
  )),
)
```

That defines a variant of the content layout, bound to the name `footered`. It sets up a grid of rows: first the usual `header` cell at automatic height, then the `body` cell with an instruction to fill the available space, which is what pushes the footer to the bottom edge. Naming a track with `grids.track` gives the cell a name you can later style with a `show` rule, and sets its size.

The footer row comes last, again at automatic height, and carries a cell named `footer`. Because it is declared with `grids.cell` rather than a bare name, that cell can hold default content, which then appears on every slide built from this layout without being written into a single one of them. The content opens with the text "Mosaic"; a conference abbreviation, a course name, a logo, or whatever else suits would go here. An expanding `h(1fr)` then flushes the final element right. The default display of the `progress` component is exactly what we want there: a pair `N / M` denoting the Nth slide out of M.

We then hand that layout to `setup` under the name `content`:

```typ
#show: m.setup.with(
  title: [Slides with a footer],
  subtitle: [A variant of metropolis],
  authors: [Vincent Arel-Bundock],
  layouts: (content: footered),
  // Metropolis puts a progress line in the foreground of every numbered
  // slide. The footer counter now says the same thing, so drop the line.
  foreground: none,
)
```

`title`, `subtitle`, and `authors` are the constant text the default title layout renders. The title and section layouts are unchanged, but `content` now resolves to `footered`, the variant from above.

For completeness, the whole deck:

```typ
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m

// a slide is composed of a grid
#let footered = m.grids.rows(         
  // 1st row cell is called "header" and its height is automatic based on content (auto)
  m.grids.track(auto, "header"),      
  // 2nd row cell is called "body" and its height takes all the available space (1fr)
  m.grids.track(1fr, "body"),
  // 3rd row cell is called "footer" and its height is automatic based on content (auto)
  m.grids.track(auto, m.grids.cell(
    "footer",
    // the footer cell has default content that will appear on every slide using that layout
    content: [
      #text(fill: orange, "Mosaic")	// text in orange accent color
      #h(1fr)                    	// space
      #m.components.progress()   	// slide number
    ],
  )),
)

#show: m.setup.with(
  title: [Slides with a footer],
  subtitle: [A variant of metropolis],
  authors: [Vincent Arel-Bundock],
  layouts: (content: footered),
  // Metropolis puts a progress line in the foreground of every numbered
  // slide. The footer counter now says the same thing, so drop the line.
  foreground: none,
)

#m.slide("title")

= First section

== A slide

The `==` heading fills the header and this paragraph fills the body. The footer cell fills itself.

== Another slide

- The footer content lives in the grid, so it repeats without being written anywhere else.
- The title and section slides use other layouts, so they carry no footer.

= Second section

== The last slide

Only slides built from `footered` show the footer.
```
