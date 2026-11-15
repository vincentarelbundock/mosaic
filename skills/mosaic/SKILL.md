---
name: mosaic
description: Complete tutorial and workflow for creating slide decks with the Mosaic package for Typst. Use when creating, editing, styling, debugging, or verifying Typst presentations built with Mosaic, or when the user mentions Mosaic slides, Typst slides, slide grids, named cells, themes, incremental reveals, speaker notes, handouts, or Mosaic compilation errors. Also covers common slide types: title, section divider, bulleted content, two-column, figure, image-beside-text, full-bleed photograph, big-number, and table slides.
---

# Mosaic for Typst

Mosaic builds slide decks as ordinary Typst documents. A deck is a sequence of slides; each slide is a grid of named cells sandwiched between a full-slide background plane and a full-slide foreground plane. Every cell and plane is a native Typst layer carrying a label (`<mosaic-cell-ID>`, `<mosaic-background>`, `<mosaic-foreground>`), so styling is ordinary `set` and `show` rules, not a framework DSL.

Prefer the smallest authoring surface that fits the request: headings for ordinary slides, named layouts for title and section slides, and low-level grids only for genuinely custom composition.

## 1. Establish the environment

1. Inspect the existing deck and preserve its import spelling and theme. Do not replace a themed facade with the root facade unless asked.
2. Check that Typst is available with `typst --version`.
3. The released package, `#import "@preview/mosaic:0.0.1"`, downloads from Typst Universe on first compile and needs no installation step. The development version, `#import "@local/mosaic:0.0.3"`, must be installed before it resolves — either as a snapshot of the repository via the one-liner below, or with `make install` from a clone to use the working tree:

   ```sh
   curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh
   ```

4. Compile from the project root when the deck uses repository-relative assets:

   ```sh
   typst compile --root . path/to/deck.typ
   ```

Do not claim success until Typst has compiled the edited deck.

## 2. Tutorial: a first deck

Import Mosaic and apply its setup rule. After `#show: m.setup`, headings create slides automatically:

```typ
#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(title: [A short title])

#m.slide(layout: "title")

= First section

== Main result

Write ordinary Typst content.

== Evidence

- First point
- Second point
```

- A level-one heading (`=`) creates an unnumbered *section slide* with a larger, centered title and advances the section counter. Content written between `=` and the next `==` becomes that slide's subtitle, so a section tagline costs no explicit slide and the heading keeps its outline entry.
- A level-two heading (`==`) creates a numbered *content slide*: the heading fills the `header` cell and the following content fills the `body` cell, until the next `=` or `==`.
- Slide bodies are ordinary Typst: lists, math, figures, native `grid()`, packages, everything works.
- Slides open on heading *depth*, the number of `=` signs, so `set heading(offset: 1)` changes the levels a PDF outline sees without changing which headings open slides, and theme heading styles follow the depth too.

Use explicit `m.slide` only when a heading slide is insufficient. Import Mosaic under a short alias (`as m`) so its constructors stay namespaced and native Typst `columns()` remains available.

Vocabulary used throughout: *slide* (one unit), *deck* (sequence of slides), *cell* (named area holding content), *grid* (cells arranged with splits), *split* (horizontal or vertical division), *track* (the size of one child of a split), *inset* (space between a cell's edge and its content), *background*/*foreground* (full-slide planes behind/over the grid), *layout* (ready-made slide arrangement), *theme* (coordinated colors, text styles, and layouts).

## 3. Layouts

`layout` selects both a configured design and its slide semantics:

```typ
#m.slide()                    // configured content layout (the default)
#m.slide(layout: "content")
#m.slide(layout: "title")
#m.slide(layout: "section")
#m.slide(layout: "image", image: path("fig/chart.png"))
```

The layout selection is also accepted as the leading positional argument, so `#m.slide("content", variant: "body")[...]` is the same slide as `#m.slide(layout: "content", variant: "body")[...]`.

The selectable names are `content`, `title`, `section`, and `image`. The first three are also *configurable*: they have defaults, headings create them automatically, and `setup(layouts:)` or a theme can replace them. `image` is selectable but not configurable, since nothing creates an image slide automatically; supply its fields at the call site. Note that `layout: "content"` resolves to the *configured* content layout, which a setup `layouts:` override changes, whereas `m.layouts.content()` builds the active theme's own default from scratch. Under every bundled facade the two start out equal: the root and default facades give `header-body` for `m.layouts.content()` and `baseline` for `m.layouts.section()`, exactly what heading slides use.

Content slides are numbered by default; title and section slides are not. Section slides advance the section counter. `numbered:` explicitly overrides the numbering default.

Any named argument `slide` does not recognize is a field of the selected layout, overlaid on the *configured* layout so the theme's other fields survive:

```typ
#m.slide(layout: "title", variant: "academic")
#m.slide(layout: "section", number: [03])[Methods]
#m.slide(columns: 2)[== Comparison][Left column][Right column]
```

Field names are validated against the selected layout, so a name that layout does not have is a compile error. Fields require a layout selected by name (or `auto`); they cannot accompany an explicit `m.layouts.*` value, which replaces rather than refines the configured layout. Pass the fields to that constructor instead.

Use a layout factory (`m.layouts.*`) when building a layout from scratch rather than refining the configured one:

```typ
#m.slide(
  layout: m.layouts.title(
    title: [Reliable systems],
    subtitle: [One source of truth],
    variant: "kicker",
  ),
)

#m.slide(
  layout: m.layouts.content(variant: "header-body", columns: 2),
  cells: (
    header: [Comparison],
    body-1: [First column],
    body-2: [Second column],
  ),
)

#m.slide(
  layout: m.layouts.section(subtitle: [What changes]),
)[Methods]
```

Variants:

- **Title**: `ruled` (the default: heading stack over a full-width accent rule with details beneath, flush left at the vertical center, the beamer-metropolis title page), `centered` (mass at slide center, metadata at the bottom edge), `bordered` (centered stack inside one thin border), `kicker` (magazine masthead: strong opening rule, subtitle as a tracked-caps eyebrow in the accent color, details at the bottom edge), `panel` (a vertical ink panel carries the details knocked out in canvas under a short accent rule; the title takes the main field), `academic` (conference-poster arrangement with superscript affiliations), and `image` (a compact stack with a picture, placed by `position:`; see *Pictures* below). Every variant renders every author field: names with ORCID icons and the corresponding asterisk, affiliations, contact addresses, and the date. Structural marks default to the text color (the bordered border, the kicker opening rule) or the semantic accent (the ruled rule); an explicit `accent:` recolors them. A title too long for its allocation shrinks to fit rather than overprinting the details, and `rule: true` adds a short accent rule under the `centered` heading. There is no plate variant: invert any slide with `m.slide(invert: true)`, which also flips code highlighting to match the inverted ground.
- **Section**: `plain`, the designed text variants `rule` (heavy full-width rule over a flush-left title), `numeral` (giant ghost number bleeding off the top-right), `baseline` (title and number sharing one baseline over a full-width hairline), `toc` (all sections listed, the current one alive), and `image` (the `plain` composition with a picture, placed by `position:`). The designed text variants read the automatic section counter when `number:` is omitted. Section numbers never take the accent color by default: the `accent:` field defaults to the muted color, and an explicit color recolors the number, and the `baseline` hairline with it. A `subtitle:` is caption-sized under the title in every variant. The themed facades restyle the section cell, so under editorial, manifesto, or metropolis these variants render at that theme's own scale.
- **Content**: `body`, `header-body`, `body-footer`, `header-body-footer`.
- **Image**: no variants. The image layout has no text design of its own; `position:` is its only arrangement.

**Pictures.** The title, section, and image layouts take a picture the same way, through two arguments. `image:` is the picture: a `path(..)` when the file is all there is to say, or content, typically `m.components.image(path(..), fit: .., scrim: .., alt: ..)`, when it needs a fit, a scrim, or a description. There is no dictionary form. `position:` is where it goes, in one vocabulary: `"left"`, `"right"`, `"top"`, `"bottom"` (a full-bleed picture on that side, sized by `tracks:`, where one size such as `40%` is the picture's share on whichever side) or `"background"` (the picture behind the text). The image layout adds `"body"`, its default: a contained picture under a header. `variant:` never places a picture; it names the text design only. In the title and section layouts a picture needs `variant: "image"`, written together with `image:`; `position:` and `tracks:` apply only to that variant.

```typ
#m.slide(layout: "image", position: "right", image: path("fig/book.jpg"))[== Readings]
#m.slide(layout: "section", variant: "image", position: "top", image: path("fig/chapter.jpg"))[Methods]
#m.slide(
  layout: "title",
  variant: "image",
  position: "background",
  image: m.components.image(path("cover.webp"), scrim: black.transparentize(55%)),
)
```

`m.layouts.title()` inherits `title`, `subtitle`, `authors`, and `date` from setup, so `m.slide(layout: "title")` needs no body. An explicit layout argument wins; pass `none` to suppress any inherited field on one slide (`title`, `subtitle`, `date`, or `authors`). A title over a full-slide photograph is the `image` variant at `position: "background"`. For a cover no variant draws, give the slide a `background:` plane (`background: m.components.image(path("cover.webp"), scrim: ..)`) and compose the type yourself with `m.info()`, a contextual reader returning the `title`, `subtitle`, resolved `authors` records, and `date` declared on setup, plus two position records: `slide` (`number`, `total`, `numbered`; `number` is `none` on an unnumbered slide) and `section` (`number`, `total`, `title`), which are what hand-built footlines and headlines are made of and what `m.components.progress()` itself reads. Pair a photographic background with a scoped text-color rule on the `<mosaic-cell-title>` or `<mosaic-cell-section>` label for contrast. One such rule recolors the whole stack: the subtitle and details are muted only while the cell carries the deck's ordinary text color, and follow any override, so light-on-dark titles need no hand-built grid. A size rule on the same label works the same way, scaling the stack as a unit (`show label("mosaic-cell-title"): set text(size: 0.45em)` for quiet type in a corner), because the display line carries its own `<mosaic-title-display>` label where the theme states the display size. There is no `scale:` argument, and a hand-built grid is never the way to resize a title.

Mosaic has no automatic shrink-to-fit for body content, by design: a deck whose type size is decided slide by slide loses the typographic scale that holds it together. An overflow means cut a bullet, split the slide, or pick a layout with more room. When one indivisible block is oversized (a wide table, a chart, a generated list), scale that block alone with `m.fit(my-table)`, which measures it against its region and scales geometrically. `m.fit(grow: true)[42%]` goes the other way, filling a cell with display type. A fitted block never overflows and so stops appearing in the overflow records, which is why it is for indivisible blocks rather than crowded slides. It also cannot contain `m.steps.pause`, `m.steps`, or `m.note`: measuring hides the body from the runtime's walk, so those would be lost. `m.fit` raises an error rather than dropping them; keep them outside the fitted block. Prose too tall for its cell is offered a wider measure before it is scaled, so fitted text fills the cell's width.

A direct `m.layouts.content/title/section(...)` value retains its semantic layout name. A raw custom grid uses ordinary content-slide semantics.

To replace a named layout deck-wide, configure it once in setup; to reuse one for selected slides, bind it with `.with`:

```typ
#show: m.setup.with(layouts: (
  section: m.layouts.section(
    variant: "image",
    position: "background",
    image: path("chapter.jpg"),
  ),
))

#let myslide = m.slide.with(layout: m.layouts.content(variant: "header-body"))
#myslide(cells: (header: [== Slide title], body: [Slide content]))
```

## 4. Common slide types

Most decks are built from a handful of recurring shapes. Reach for the named form below before composing a grid by hand; each one is one line and stays correct when the deck's font size, paper, or theme changes.

**Title slide.** `#m.slide(layout: "title")` with nothing else: it inherits `title`, `subtitle`, `authors`, and `date` from setup. Choose a stock variant when the preset suits the deck. When the deck wants type much quieter or more idiosyncratic than any preset, use the image layout at `position: "background"` as the escape hatch and write the title yourself. Write it as a level-one heading rather than plain text (`#heading(level: 1, outlined: false)[..]` keeps it out of the bookmarks): the image layout at that position has no header cell, so the heading renders in place in the body, it takes the theme's level-one heading size (a scoped `show heading: set text(size: ..)` in the body adjusts it), and it gives an accessible export the H1 that the built-in title layout supplies on its own:

```typ
#m.slide(layout: "image", position: "background", image: path("fig/cover.jpg"))[
  #set text(fill: white)
  #heading(level: 1, outlined: false)[Économie et Politique]

  POL1025

  Vincent Arel-Bundock
]
```

**Section divider.** A bare `= Section name` is enough. Text written between the `=` and the next heading becomes the section slide's subtitle, so a tagline costs no extra slide. Use `setup(layouts: (section: ...))` when every divider should share one designed variant (for example `m.layouts.section(variant: "baseline")`) or carry the same photograph. A tagline takes steps and notes like any body. A one-off design is a field overlay: `#m.slide(layout: "section", variant: "toc")[Methods]`.

**Bulleted content slide.** A bare `== Slide title` followed by a list. Do not write `m.slide` for this.

**Two-column slide.** `columns: 2` on the content layout: the opening heading is the header, then one block per column.

```typ
#m.slide(layout: "content", columns: 2)[== Comparison][
  Left column
][
  Right column
]
```

Use it for side-by-side figures too, wrapping each in `m.components.figure(..)`, which contains the picture and sizes it to its cell. Add `tracks: (2fr, 1fr)` for an uneven split. Under a theme whose content layout is `header-body-footer` (Metropolis), a third block fills the footer cell unless the deck gave the footer a default, in which case positional bodies pass over it.

**Figure slide.** The image layout's default position, `"body"`: a header above a contained picture, with an optional caption beneath.

```typ
#m.slide(layout: "image", image: path("fig/gdp.png"))[== Growth since 1950]
#m.slide(layout: "image", image: path("fig/pie.png"), caption: [Teaching, research, admin])[== My job]
```

A picture at `"body"` defaults to `fit: "contain"`, which is what a chart needs: never crop data. `caption:` composes a native Typst `figure`, so it takes the deck's own `show figure.caption` rules and figure numbering; switch numbering off with `set figure(numbering: none)`. `caption:` is rejected at every other position. This slide has header, image, and caption cells but no body, so a single standing line of commentary belongs in `caption:`.

**Picture beside text.** The positions `left`, `right`, `top`, and `bottom` pair a full-bleed picture with a header and body region. The opening heading is the header and the next block the body:

```typ
#m.slide(layout: "image", position: "right", image: path("fig/book.jpg"))[== Readings][
  - Almost every week
  - PDFs on the course site
]
```

Stop after the heading when the picture needs a title but no body. `tracks:` sizes the picture region and is side-independent, so `tracks: 40%` means the same thing under `left` and `right` and the two stay mirror images. A picture given as a path defaults to `fit: "cover"` at these positions; pass `fit: "contain"` for a chart, a screenshot, or any picture whose edges carry meaning.

**Full-bleed photograph with text over it.** Position `"background"` puts the picture behind a single body cell:

```typ
#m.slide(
  layout: "image",
  position: "background",
  image: m.components.image(
    path("fig/auditorium.png"),
    scrim: black.transparentize(55%),
  ),
)[
  #set text(fill: white)
  == Who are you?
]
```

The body inherits the deck's ordinary text color, so it needs both halves of the contrast pair: a `scrim:` on the picture to quiet the photograph, and a text fill override in the body. Omit the body entirely for a bare picture slide with no text at all. Prefer this over a title or section layout with a background picture when the composition is free-form rather than a titled preset.

**One big number or phrase.** Scope a centering rule around a single content slide, and let `m.fit(grow: true)` size the type to the cell instead of picking an em value that breaks when the number gains a digit:

```typ
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide(cells: (body: m.fit(grow: true, strong[15 000 000])))
]
```

**Table slide.** Native Typst `table` inside an ordinary `==` slide, wrapped in `align(center + horizon)`. Mosaic adds nothing here; use `stroke: (x, y) => ...` for booktabs-style rules.

**Continuation slide.** Repeating a title verbatim collides in the outline and in link targets. Repeat the heading and give it a distinct label: `== Appeals #metadata(none) <appeals-2>`.

One recurring choice worth making once per deck:

- **`path()`, not a bare string.** Image paths inside layout and component arguments cross the package boundary, so a bare `"fig/x.png"` names a file inside the installed Mosaic package rather than your project, and the compile fails. Wrap every asset path in Typst's `path()`.

## 5. Configure the deck once

Put deck identity, semantic colors, layout overrides, recurring cell defaults, and page planes in `m.setup`:

```typ
#show: m.setup.with(
  title: [Reliable systems],
  subtitle: [One source of truth],
  authors: ([Ada Lovelace], [Grace Hopper]),
  date: [2026],
  colors: (accent: rgb("#007f73")),
  cells: (
    footer: [Mosaic · Engineering],
  ),
  foreground: [#place(bottom + right)[#m.components.progress()]],
)

#m.slide(layout: "title")
```

Key setup arguments:

- `title`, `subtitle`, `authors`, `date`: deck identity. `authors` takes a bare name the way `title` does, an array of names for several, or records mixed in among them. An author record is built by `m.layouts.author(name, ...)` and accepts `affiliations` (an array of institutions, as content or strings, deduplicated by value so authors sharing one institution share its legend number), `corresponding`, `email`, and `orcid`; the `academic` title variant requires at least one author. Feeds title layouts, Typst document metadata, and the queryable `<mosaic-deck-metadata>` record. Setup does not insert a title slide automatically; each `m.slide(layout: "title")` chooses where one appears.
- `colors:`: partial overrides of the semantic palette. It is one flat dictionary: `canvas`, `surface`, `accent`, `text`, `muted`, and `line` are the deck's own chrome, and `warning` and `error` are the status colors components paint with. Unknown names and non-color values are errors; omitted names keep the active theme's defaults.
- `layouts:`: a dictionary overriding only `content`, `title`, or `section`. Both explicit slides and automatic `==` slides use the configured `content` layout.
- `headings:`: which heading levels open slides. An array indexed by level whose entries are `"section"`, `"slide"`, or `none` for a level that opens nothing; the default is `("section", "slide")`. `("section", "section", "slide")` makes `===` the content slide. Levels past the end are ordinary content inside the current slide.
- `font:` / `base-size:`: the deck's typeface (a family or a list of families) and base text size, under every theme, custom ones included. A theme's headings and tiers are multiples of the base size, so the deck scales with it; a `set text(size: ..)` after setup changes body text alone.
- `cells:`: recurring cell defaults (such as `footer`). They apply only when the resolved layout contains that cell ID. Positional bodies pass over a cell with a default; a slide replaces or suppresses it by name, through its own `cells: (footer: ..)` or `cells: (footer: none)`.
- `background:` / `foreground:`: the deck's full-slide planes. Every slide inherits them unless it passes its own value, or `none` to suppress one.
- `paper:`: `"16-9"` (default), `"4-3"`, or a `(width:, height:)` dictionary of positive absolute lengths (no `em`).
- `spacing:`: for example `(inset: 1.5em)` to set the default cell inset.
- `handout: true`: emit only the final frame of each logical slide.
- `output:`: `"slides"` (default), `"speaker"`, `"notes"`, or `"split"`.
- `overflow:`: `"off"` (default) observes nothing, because measuring every cell on every frame roughly doubles the layout work a deck does. `"error"` fails the compile at the end of the deck and names every offending cell with its slide and frame, which is the mode to run once before presenting. `"record"` emits queryable `<mosaic-overflow-warning>` metadata for any cell whose content exceeds its allocation and keeps compiling; it prints nothing, since Typst gives a package no warning channel.
- `frozen-counters:` / `frozen-states:`: values that advance once per logical slide instead of once per frame.

Do not introduce a separate footer, logo, background, or foreground feature API: recurring named-cell content (`cells:`) and the `background:` / `foreground:` planes own those jobs.

## 6. Themes

Import one facade as `m` and keep the rest of the deck unchanged:

```typ
#import "@local/mosaic:0.0.3" as mosaic
#import mosaic.themes.metropolis as m

#show: m.setup
```

Bundled facades are `default`, `editorial`, `metropolis`, `manifesto`, and `mono`. The root package is exactly the bundled default facade. There is no dark theme: flip any theme to dark by passing the bundled dark palette through `colors:`, as in `#show: m.setup.with(colors: mosaic.palettes.dark)`. Every theme adapts on its own, syntax highlighting included.

Every facade exports the same `slide`, `info`, `note`, `fit`, `grids`, `steps`, `components`, and `palettes`, so those parts of a deck are theme-portable (`pause` lives on `steps.pause`, not as a top-level export). Each facade also exports its own `definition`, the dictionary its `setup` is bound to. Each theme also exports `m.layouts`: the base layout constructors, rebound with that theme's defaults (for example, Editorial's `content` defaults to `variant: "header-body"`). Every base argument remains available under every theme; for example, Metropolis binds `title` to `variant: "ruled"` and an explicit variant overrides it.

To develop a theme, start locally: define the complete semantic palette, all eight colors, and bind the dictionary directly:

```typ
#let theme = (
  colors: (
    canvas: white,
    surface: rgb("#f5f5f5"),
    text: rgb("#17243a"),
    muted: rgb("#52657f"),
    line: rgb("#aeb9c8"),
    accent: rgb("#a23b72"),
    warning: rgb("#96793d"),
    error: rgb("#8a4a3a"),
  ),
  defaults: (font: "Inter", base-size: 20pt),
  apply: (body, colors: (:), options: (:)) => {
    show list.where(tight: true): it => list(tight: false, ..it.children)
    body
  },
)

#show: m.themes.setup(theme)
```

Only `colors` is required; `name`, `defaults`, `options`, `layouts`, and `apply` are optional. A theme states its typeface and base size through `defaults: (font: .., base-size: ..)`, because they are deck options every theme accepts, never through `options`. Mosaic's engine fills the canvas and states the base typography before `apply` runs (text fill from `colors.text`, font and size from the deck's `font` and `base-size`) and emits no other `set` or `show` rule, so `apply` states the rest of the theme's look: headings, captions, list rhythm, and the canonical `<mosaic-cell-*>` rules the layouts compose against. `apply` reads the resolved values as `options.font` and `options.base-size`; state heading sizes as multiples of `options.base-size`, not in `em`, so they hold under `set heading(offset: ..)`. A heading rule that rebuilds the heading (`show heading: it => ..`) is declared through `show: mosaic.themes.decorate-heading.with(depth: 2, it => ..)` so that it holds on every frame of an incremental slide. The definition is validated where it is bound: a missing or misspelled color is named, as are unknown `defaults` keys and an incomplete `layouts` dictionary. The bound `setup` takes no `theme:` argument. Copy the default theme's `mosaic/src/themes/default/definition.typ` for the complete set in its plainest form. Themes that want compact markup lists to read at presentation distance loosen them with a plain show rule (`show list.where(tight: true): it => list(tight: false, ..it.children)`, and the same for `enum`). To start from an existing theme, merge its exported definition: `base.definition + (name: .., colors: base.definition.colors + (accent: ..))`. The merge replaces `apply` outright, so to extend inherited rules rather than drop them, run the base callback first with `show: (base.definition.apply).with(colors: colors, options: options)`. A reusable packaged facade keeps three core files: `theme.typ` (binds and exports the public API), `definition.typ` (passive design decisions), and `layouts.typ` (the callable layout namespace), bound once with `mosaic.themes.setup(definition)`. Copy the default theme's files and change only design values. Theme definitions are passive data consumed by Mosaic's engine; never call setup internals from a theme or forward Mosaic's setup arguments.

## 7. Custom grids

Build custom structure only when headings and layout factories are insufficient. A Mosaic grid is a transparent tree of named cells:

```typ
#let composition = m.grids.columns(
  tracks: (2fr, 1fr),
  "main",
  m.grids.rows(tracks: (2fr, 1fr), "notes", "source"),
)

#m.slide(
  layout: composition,
  cells: (
    main: [The main argument],
    notes: [Two parts notes],
    source: [One part source],
  ),
)
```

- `m.grids.columns(...)` places children side by side; `m.grids.rows(...)` stacks them. Each string is a cell ID. Children may be nested grids. Both accept `gutter:` (a native track size between adjacent children, default `0pt`) and `stroke:` (a stroke drawn along each interior boundary, centered in the gutter, default `none`).
- Every direct child gets a `1fr` track by default. Pass `tracks:` for other sizes: an array with exactly one size per child, in order, as in `m.grids.rows(tracks: (auto, 1fr), "header", "body")`. A size is `auto`, a fixed length, a percentage, or an `fr` value. It is the same `tracks:` the content layout takes. There is no per-child wrapper.
- `m.grids.cell(id, ...)` creates an explicitly configured cell: `inset:` (padding, affects layout measurement), fixed `content:` (an image or logo owned by the grid, needing no body or `cells:` entry). Cells do not fit or scale their content: they are structural only.
- Read a grid from the outside inward: largest split first, then replace children with nested splits. Keep descriptive IDs and indentation.

Cell insets provide slide margins (`setup` uses a zero page margin). Adjacent cells each contribute their own inset; a grid `gutter` separates cell surfaces and defaults to `0pt`. A compact cell, one directly in an `auto` row (a header, a footer, a one-line strip), keeps `inset` left and right but takes `spacing.compact-inset` above and below, exactly like the built-in headers; raise `setup(spacing: (compact-inset: ..))` for a deeper painted header on every slide. Use a layout factory instead of rebuilding a standard title, section, header/body, or footer structure as a raw grid.

## 8. Fill cells with content

A slide accepts cell content in two distinct forms. Do not mix them in one slide.

**Positional bodies** follow one rule: *a slide's opening heading is its header, and everything else fills the cells in order.* In a layout with a `header` cell, the heading that opens the slide fills it, whether it sits in a block of its own or opens the first one, exactly as `== Title` does on a heading slide. The bodies then fill the other cells in source order: left to right within `columns`, top to bottom within `rows`, recursively through nesting. A grid with no `header` cell lifts nothing.

```typ
#m.slide(layout: m.grids.columns("a", "b", "c"))[a][b][c]
#m.slide[== Title][Body]            // header, then body
#m.slide(columns: 2)[== Title][Left][Right]
```

Two kinds of cell are out of positional reach, and are addressed by name: a header that is not a heading (`#m.slide[Plain][Body]` is an error on a header layout), and a cell with a deck default from `setup(cells:)`. More bodies than cells to fill is an error listing the cells positional bodies reach.

**Named `cells:`** for anything larger or reusable — assignment stays independent of traversal order:

```typ
#m.slide(layout: composition, cells: (main: [...], notes: [...], source: [...]))
```

The cell ID connects all three layers: `m.grids.cell("body")` defines the cell, `cells: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it. Content-bearing cells are optional and render empty when omitted; unknown IDs are errors, except `id: none`, which means "suppress" and is a no-op when the layout has no such cell. That makes `cells: (body: [...], footer: none)` safe to write across slides whose layouts do not all carry a footer.

Useful content values:

- `m.components.image(path("photo.webp"), alt: "...")`: like native `image()` but defaults `width`/`height` to `100%` and `fit` to `"cover"`. `scrim:` paints a layer over the picture and takes any Typst paint, so `scrim: black.transparentize(55%)` darkens the whole picture and a `gradient.linear(..)` darkens only the band the text occupies. The result is content, which is what a layout's `image:` takes when a picture needs a scrim, a fit, or an `alt`. Use Typst's `path()` so the location anchors to the calling document across the package boundary. For a full-bleed image, set the cell's `inset: 0pt`.
- `m.components.figure(path("chart.png"), caption: [..])`: the in-cell figure. Defaults `fit` to `"contain"` so nothing is cropped, centres the picture, and with the default `height: auto` hands it the cell's height less whatever the caption consumes. Two of them in adjacent cells caption on one baseline whatever their aspect ratios, so no matching height has to be found by hand. `auto` reads the cell, not the space left inside it, so a figure that follows prose in the same cell needs an explicit `height:` and then captions directly beneath itself. Use `m.components.image` instead for a background plane or a deliberately cropped cell.
  The body can be content rather than a source: `m.components.figure(my-table, caption: [..], kind: table)` captions a table or a code-drawn diagram, keeps its natural size, and scales it as a whole only when it is too large for the cell (never magnifies it). State `kind: table` because scaling costs the automatic detection; further named arguments go to the native `figure` for a content body and to the native `image` for a picture source. `fit:` and `scrim:` are picture-only and are rejected for content.
- `m.components.card()` (clipped semantic panel), `callout()` (side stripe with optional title), `badge()` (compact inline badge), `quote()` (attribution treatment), `divider()` (horizontal rule), `progress()` (position indicator). All return ordinary content for any cell or plane. A component's `role:` names one color in the theme palette: `accent`, `warning`, or `error`, plus `neutral` for the deck's own surface. The component paints its border and rails in that color and its panel in that color tinted into the deck canvas. The panel components (`card`, `callout`, `quote`) also take flat `fill:`, `accent:`, `stroke:`, `radius:`, `inset:`, and `align:` overrides, each defaulting to `auto` (take it from the role), plus a `text:` dictionary of native `text` arguments, so a one-off color is `callout(accent: rgb("#7c3aed"))` rather than a new role. `badge` takes the same set without `align:`, `divider` takes only `title:` and `stroke:`, and `progress` takes `fill:` and `accent:` beside its own arguments. Components are transparent to Mosaic's own commands: a pause, a step, or a note inside one works as in the cell around it, and a dimmed component mutes its paint. `quote` is a superset of the native `quote` (`block:`, `quotes:`, a label as `attribution:`).
- Native math, `figure` with captions and references, MiTeX for LaTeX math, ctheorems for theorem environments: all work unchanged inside cells.

## 9. Style with native Typst rules

Two kinds of rules cover a cell, split by what they touch:

- **Content rules** (text, alignment, paragraphs, lists) pass through the label as ordinary `set` rules.
- **Block rules** (the cell's own fill, stroke, corner radius) are `set block` rules on the same label. Mosaic confines them to the cell's own block, so blocks inside the content keep their own paint:

```typ
#show label("mosaic-cell-copy"): set align(left + horizon)
#show label("mosaic-cell-copy"): set text(fill: black, size: 1.1em)
#show label("mosaic-cell-copy"): set block(fill: white)
```

There is no height to manage: the engine sizes the cell's block to its track, so a `1fr` or fixed-track cell paints edge to edge and an `auto`-track cell paints as tall as its content. The planes carry `<mosaic-background>` and `<mosaic-foreground>` and take the same rules. Because these are `set` rules, a rule scoped inside a block overrides a deck-wide one for exactly the slides in that block.

One boundary is native Typst, not Mosaic: properties an element pins on itself (heading weight and size, `raw` font, `figure.caption` color) resist label rules, because the element's own rule sits closer to the glyphs. A label rule's unpinned properties (a text fill, say) still flow in — only the pinned ones are overridden, which is why half a rule can work. Restyle pinned properties with an element rule after setup:

```typ
#show heading.where(depth: 2): set text(weight: "extrabold")
```

Rules after `#show: m.setup` apply deck-wide. Scope a rule and slide inside a block to change only that slide:

```typ
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide[Centered for this slide only]
]
```

Bundle repeated rules in a transformer and apply it once with `#show:`:

```typ
#let styled(body) = {
  show label("mosaic-cell-banner"): set text(size: 1.4em, weight: "bold")
  body
}
#show: styled
```

The typeface and base size are `setup` options; the rest of the typography is native rules after setup:

```typ
#show: m.setup.with(font: "EB Garamond", base-size: 26pt)
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
```

A semantic heading feeds outlines and bookmarks; use `text(...)` directly for display type that should not appear in navigation, or `heading(outlined: false, bookmarked: false)[...]`. Do not invent a separate Mosaic styling API or put decorative styling into the grid tree. Use `m.components` when their documented semantic treatments fit; otherwise use native Typst.

## 10. Furniture: footers, planes, navigation

Keep three concerns distinct:

- **Cells** (`header`, `body`, `footer`) participate in the resolved grid. A recurring footer is a setup `cells:` default for the real `footer` cell, applied whenever the resolved layout contains that cell. A slide overrides or suppresses it by name, `cells: (footer: ..)` or `cells: (footer: none)`; positional bodies pass over it. Title slides have no `footer` cell, so they are unaffected.
- **Planes** are the `background:` and `foreground:` arguments of `setup` and `slide`, never entries in `cells:`. They cover the full usable slide area without changing grid measurements. A slide inherits the setup plane by default, replaces it with its own value, or suppresses it with `none`.
- **Runtime state** supplies logical slide, section, and frame counters, read by components such as `m.components.progress()`.

A logo is ordinary setup foreground content: `place(top + right, dx: .., dy: ..)[#image(..)]` inside `m.setup(foreground: ...)`. A photographic background is a slide-sized `m.components.image` (with `scrim:` for contrast) passed to `background:`.

`m.components.progress()` follows the logical slide counter (all frames of one slide share a number). Its `variant:` is `"1/1"` (default), `"1"`, `"circle"`, or `"line"`. `count:` selects the `"slides"` (default) or `"sections"` counter. The indicator quiets itself on pages where its counter has no meaningful reading — the slides count on unnumbered slides (titles and sections), the sections count before the first section slide — so a bare `progress()` in a deck foreground is already correct page-number chrome, with no guard to write. `quiet:` overrides the rule: `false` always displays, `true` silences every unnumbered page even for the sections count. Hand-built footlines that read `m.info()` directly still guard with `slide.numbered` themselves. Appearance goes through `role:` (default `"accent"`), `accent:` (the completed portion), `fill:` (the inactive remainder), `width:` (line length or circle diameter), and `thickness:`.

Navigation stays native because headings stay native:

- Table of contents: `outline(depth: 2)`; every entry links to its heading.
- Breadcrumbs: contextual `query` with a selector ending at `here()` to find the active section and slide headings.
- Section links: `query(heading.where(level: 1, outlined: true))`; each result gives a label via `body` and a target via `location()`.
- Slide links: label a content slide (`== Results <results>`) and `#link(<results>)[...]`. For an explicit slide, put `#metadata(none) <id>` at the start of its content.

## 11. Incremental reveals

Write one logical slide; Mosaic adds frames until the last timed command has run and discovers the frame count. Hidden content keeps its space by default so the slide stays still; use `before: "removed"` when surrounding content should expand into that space. Choose the smallest command:

- `m.steps.pause`: advances subsequent source-order content to the next frame. Scoped to its containing content stream, so it also works inside blocks, fixed cells, and planes. Empty leading, trailing, or consecutive pauses never create blank frames. A pause at the very end of a list item is an error; put it on its own line between items.
- `m.steps.on(range)[content]`: shows content over an exact step range. Ranges are integers, open (`"3-"`), closed (`"2-4"`), or up to a step (`"-2"`). `before:` and `after:` control the surrounding steps and each take `"visible"`, `"hidden"` (the default, keeps the space), `"dimmed"`, or `"removed"` (releases the space).
- `m.steps.reveal[...]`: accumulates a list or sequence one item at a time.
- `m.steps.replace[first][second]`: swaps alternatives in one stable slot sized by the largest alternative.
- `m.steps.drawing`: connects the same timing model to custom structures (CeTZ canvases, Fletcher diagrams); preserve hidden bounds so later additions do not shift the drawing. A command wrapped in `on` is only valid inside `steps.drawing`; text outside it is written as content, `on(2)[text]`.

```typ
#m.slide[
  == Findings
  - The estimate is positive.
  #m.steps.pause
  - The interval excludes zero.
]
```

Constraints and options:

- A heading cannot be placed inside an incremental grid node (`m.steps.reveal`, `m.steps.replace`, and related step commands); keep headings structurally stable across frames.
- Steps, pauses, and notes work wherever Mosaic can see them: cell bodies and planes; lists, tables, term lists, shapes, transforms, `columns`, and math; Mosaic's own components (`card`, `callout`, `quote`, `badge`, `divider`, `figure`); and layout content fields such as a section tagline or a title slide's title and subtitle. Three places stay opaque and fail the compile rather than dropping content: your own `context` block, a `layout` callback, and show-rule output. A note tied to a step the slide never reaches is shown on the last frame.
- A list timed with `pause`, `on`, or `reveal` is drawn by Mosaic rather than by the native list, using the deck's `list.marker`, `enum.numbering`, spacing, and indents; a hidden item hides its marker too.
- `m.slide` cannot be nested inside another slide or a container, needs `#show: m.setup` before it, and takes content bodies (or `none` for an empty cell). `#footnote` on a slide is an error: put the note in a footer cell. `m.fit(width:)` and `height:` take a length or a ratio, not a fraction.
- `setup(handout: true)` emits only the final frame of each logical slide, including timed planes.
- Native counters and states advance once per physical frame by default. List them in `setup(frozen-counters: (...), frozen-states: (...))` to advance once per logical slide instead.
- Reveal one part of an equation at a time by replacing plain terms with colored underbraces via steps commands; the layout stays fixed.

## 12. Speaker notes and outputs

Attach notes with `m.note[...]`. Notes never render in the default `output: "slides"` and never add frames. A note outside timing commands applies to every frame; a note after `m.steps.pause` or inside a steps command follows that command's frame assignment. Multiple applicable notes accumulate in source order.

```typ
#show: m.setup.with(output: "speaker")  // A4: frame thumbnail + notes
#show: m.setup.with(output: "notes")    // A4: notes only
#show: m.setup.with(output: "split")    // double-width: slide | notes
```

Every companion output writes one page per emitted frame and fails with an explicit overflow diagnostic when notes do not fit. Every frame carries `<mosaic-speaker-notes>` metadata (`logical-slide`, `frame`, `notes`) queryable with Typst's `query`.

`"split"` is the presenter-console build: each page is exactly twice the slide wide with no page margin, the slide unscaled on the left half and its notes on the right, which is the layout pympress splits automatically and pdfpc splits with `--notes=right`. The notes half stays black on white whatever polarity the deck carries.

Independently of `output:`, a deck that holds any note also embeds those notes in the PDF as `speaker-notes.pdfpc`, the pdfpc interchange format, keyed to the physical page each note is visible on. This needs no argument: an ordinary `output: "slides"` deck looks unchanged and carries its notes as data for any console that reads them. Notes reach the attachment as text, so words survive and layout does not; a note whose shape matters belongs in the `split` build. Recover the conventional sidecar with `pdfdetach -savefile speaker-notes.pdfpc -o talk.pdfpc talk.pdf`.

## 13. Recipes

- **Reuse a slide**: define it as a function and call it wherever it should appear; each call is a new logical slide with the same incremental sequence.
- **One-off dark slide**: `m.slide(invert: true)[...]` swaps canvas and text for that slide within the deck's palette.
- **Aspect ratio**: `setup(paper: "4-3")`; default is `"16-9"`.
- **Inspect overflowing cells**: set `overflow: "record"` on `setup` first, since observation is off by default. Mosaic then emits non-fatal metadata when a rendered cell exceeds its allocation:

  ```sh
  typst eval 'query(<mosaic-overflow-warning>).map(it => it.value)' --in slides.typ
  ```

  The reported `logical-slide` is not the page number once the deck uses `m.steps.pause` or `m.steps`. Ask for both when hunting a specific slide down, then render just those pages to look at them:

  ```sh
  typst eval 'query(<mosaic-overflow-warning>).map(it => (it.value.logical-slide, it.location().page(), it.value.cell))' --in slides.typ
  typst compile --root . slides.typ /tmp/p-{n}.png --pages 20,23 --ppi 55
  ```

  Overflow is nearly always a *body* cell holding more prose than its band. On a stacked image position (`top`/`bottom`) the usual fix is a smaller `tracks:` so the text band grows; when the body is a full bullet list plus a picture, abandon the image layout and use an ordinary content slide with `m.components.figure(.., height: N%)`, which is predictable.

- **Convert a whole deck set**: when porting many sibling decks, keep an identical `m.setup` block in each so they stay a series, and drive the build from one pattern rule. Watch for output collisions before running that rule: `quarto render` + `pagedown::chrome_print` print `<deck>.pdf` from the same basename a Typst deck compiles to, so a first `make` can overwrite an existing set of PDFs. Whether that is wanted (the Typst decks are replacing them) or not (both sets must survive, so Typst output belongs in its own directory) is the author's call — ask rather than assume, and check whether the directory is under version control before finding out the hard way.

- **Inspect deck metadata**:

  ```sh
  typst eval 'query(<mosaic-deck-metadata>).map(it => it.value)' --in deck.typ
  ```

## 14. Diagnose before changing structure

When compilation fails:

1. Recompile the smallest affected deck and capture the exact diagnostic.
2. Check for an unknown layout name, a missing named cell, mixed positional and named content, or an invalid layout variant.
   - `mosaic: content appears before the first heading handled by setup` means something after `#show: m.setup` emits content before the first `=`/`==` or `m.slide` — often a tool-setup call (e.g. `calepin.setup(..)`) that looks inert but produces content. Move it inside the first slide's body.
   - `mosaic: content appears after an explicit slide and belongs to no slide` means text or a call follows an `m.slide(..)` at the top level. Open a new slide with a heading, or move the content into the slide.
   - A `was removed; write ..` diagnostic names the current spelling of a renamed argument (`variant: "image-left"`, the image layout's `variant:`, a picture dictionary, `grids.track`, a `headings:` dictionary). Apply it as written.
   - `failed to decode image (Format error decoding Jpeg ...)` or `unknown image format` means the file's extension lies about its bytes. Typst chooses its decoder from the extension, so a PNG or WebP named `.jpg` fails. Check with `file -b`, and prefer adding a correctly-named *copy* over renaming when other documents reference the original name. Typst has no AVIF decoder at all — convert those.
3. Confirm that dictionary-held functions are called with parentheses when needed, for example `(theme.layouts.section)()`.
4. Confirm that `layouts:` passed to setup is a dictionary and only overrides `content`, `title`, or `section`.
5. Confirm that a picture is a `path(..)` or content placed by `position:`, and that `tracks:` has one size per child.
6. Change the narrowest source responsible, then recompile the original deck.

Do not add compatibility aliases for removed APIs. In particular, slides use `layout:`, not a separate semantic selector.

## 15. Verify the result

For a deck change:

```sh
typst compile --root . path/to/deck.typ /tmp/deck.pdf
pdfinfo /tmp/deck.pdf
```

Inspect representative rendered pages when structure, spacing, themes, images, or incremental frames changed. Check title, section, ordinary content, and any custom grid separately.

For changes inside the Mosaic repository:

```sh
make install
make check
make website
```

Completion requires:

- every edited deck compiles from current sources;
- page count and incremental frames are plausible;
- no content is clipped, overlapped, or assigned to the wrong cell;
- automatic and explicit slides use the intended layout;
- documentation examples use the same public API as the package;
- removed APIs were not reintroduced as aliases.

## 16. Reflect and improve this skill

After completing the task, reflect on the session and update *this* SKILL.md if something generalizable was learned.

1. **Reflect**:
   - Did any instruction here mislead, confuse, or get ignored during the task?
   - Did the user correct an approach, state a preference, or surface a Mosaic edge case not yet covered?
   - Did a compilation failure reveal a missing diagnostic step, or did the Mosaic API drift from what this file documents?
2. **Decide**:
   - Generalizable lesson about how this skill should work → update this SKILL.md with the Edit tool.
   - One-off or user-specific lesson → do not update; consider auto memory instead.
   - Nothing notable → say so explicitly and skip the edit.
3. **Edit**: make small, surgical changes — refine a sentence, add a bullet or example. Do not rewrite sections wholesale. Never remove this reflection step itself.
4. **Report**: tell the user in one or two sentences what changed (or that nothing changed) and why.
