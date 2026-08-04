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
3. When Mosaic is not installed, clone and install the package locally:

   ```sh
   git clone https://github.com/vincentarelbundock/mosaic.git
   cd mosaic
   make install
   ```

4. Compile from the project root when the deck uses repository-relative assets:

   ```sh
   typst compile --root . path/to/deck.typ
   ```

Do not claim success until Typst has compiled the edited deck.

## 2. Tutorial: a first deck

Import Mosaic and apply its setup rule. After `#show: m.setup`, headings create slides automatically:

```typ
#import "@local/mosaic:0.0.1" as m

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

Use explicit `m.slide` only when a heading slide is insufficient. Import Mosaic under a short alias (`as m`) so native Typst `h()` and `v()` remain available.

Vocabulary used throughout: *slide* (one unit), *deck* (sequence of slides), *cell* (named area holding content), *grid* (cells arranged with splits), *split* (horizontal or vertical division), *inset* (space between a cell's edge and its content), *background*/*foreground* (full-slide planes behind/over the grid), *layout* (ready-made slide arrangement), *theme* (coordinated colors, text styles, and layouts).

## 3. Layouts

`layout` selects both a configured design and its slide semantics:

```typ
#m.slide()                    // configured content layout (the default)
#m.slide(layout: "content")
#m.slide(layout: "title")
#m.slide(layout: "section")
#m.slide(layout: "image", image: path("fig/chart.png"))
```

The selectable names are `content`, `title`, `section`, and `image`. The first three are also *configurable*: they have defaults, headings create them automatically, and `setup(layouts:)` or a theme can replace them. `image` is selectable but not configurable, since nothing creates an image slide automatically; supply its fields at the call site. Note that `layout: "content"` resolves to the *configured* content layout, whose stock value is `m.layouts.content(variant: "header-body")`, whereas the `m.layouts.content()` factory defaults to `variant: "header-body-footer"`. The two spellings are not interchangeable; a theme or a setup `layouts:` override changes the former only.

Content slides are numbered by default; title and section slides are not. Section slides advance the section counter. `numbered:` explicitly overrides the numbering default.

Any named argument `slide` does not recognize is a field of the selected layout, overlaid on the *configured* layout so the theme's other fields survive:

```typ
#m.slide(layout: "title", variant: "academic")
#m.slide(layout: "section", number: [03])[Methods]
#m.slide(columns: 2)[Left column][Right column]
```

Field names are validated against the selected layout, so a name that layout does not have is a compile error. Fields require a layout selected by name (or `auto`); they cannot accompany an explicit `m.layouts.*` value, which replaces rather than refines the configured layout. Pass the fields to that constructor instead.

Use a layout factory (`m.layouts.*`) when building a layout from scratch rather than refining the configured one:

```typ
#m.slide(
  layout: m.layouts.title(
    title: [Reliable systems],
    subtitle: [One source of truth],
    variant: "plate",
  ),
)

#m.slide(
  layout: m.layouts.content(variant: "header-body", columns: 2),
  content: (
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

- **Title**: `swiss` (the default: title mass on a full-width baseline rule, metadata in aligned columns beneath), `centered` (mass at slide center, metadata at the bottom edge), `plate` (whole slide in the deck's text color, type knocked out in canvas), `frame` (centered stack inside one thin border), `academic` (conference-poster arrangement with superscript affiliations), `image-left`, `image-right`, `image-top`, `image-bottom`, `image-background`. Every text variant composes 1..N authors: bylines join names with commas, and swiss gives authors/affiliations/date one column each. Structural marks (the swiss rule and frame border) default to the text color; an explicit `accent:` recolors them.
- **Section**: `plain`, the designed text variants `rule` (heavy full-width rule over a flush-left title), `numeral` (giant ghost number bleeding off the top-right), `baseline` (title and number sharing one baseline over a full-width hairline), `toc` (all sections listed, the current one alive), and the same five image variants. The designed text variants read the automatic section counter when `number:` is omitted. Section numbers never take the accent color: the `accent:` field defaults to the muted color and an explicit color is an override. The themed facades restyle the section cell, so under cream, minimalist, or Metropolis these variants render at that theme's quieter scale.
- **Content**: `body`, `header-body`, `body-footer`, `header-body-footer`.
- **Image**: `figure` (the default), `full`, `left`, `right`, `top`, `bottom`.

`m.layouts.title()` inherits `title`, `subtitle`, `authors`, and `date` from setup, so `m.slide(layout: "title")` needs no body. An explicit layout argument wins; pass `none` (or `()` for `authors`) to suppress an inherited field on one slide. For image variants, `scrim:` on the image spec quiets the photograph, as in `image: (path: "cover.webp", scrim: black.transparentize(55%))`; pair `image-background` with a scoped text-color rule on the `<mosaic-cell-title>` or `<mosaic-cell-section>` label for contrast. One such rule recolors the whole stack: the subtitle and metadata are muted only while the cell carries the deck's ordinary text color, and follow any override, so light-on-dark titles need no hand-built grid.

`m.layouts.content(fit: ...)` shrinks body content that would otherwise overflow its column: `"contain"` scales it to the body height, `"auto"` scales and reflows at the smaller size (the best default for prose), and `"width"` scales to the column width. It applies to body columns only; header and footer size to their own content. Prefer `fit:` over hand-tuning per-slide text sizes, which stops working as soon as the deck's global size changes.

A direct `m.layouts.content/title/section(...)` value retains its semantic layout name. A raw custom grid uses ordinary content-slide semantics.

To replace a named layout deck-wide, configure it once in setup; to reuse one for selected slides, bind it with `.with`:

```typ
#show: m.setup.with(layouts: (
  section: m.layouts.section(variant: "image-background", image: "chapter.jpg"),
))

#let myslide = m.slide.with(layout: m.layouts.content(variant: "header-body"))
#myslide(content: (header: [== Slide title], body: [Slide content]))
```

## 4. Common slide types

Most decks are built from a handful of recurring shapes. Reach for the named form below before composing a grid by hand; each one is one line and stays correct when the deck's font size, paper, or theme changes.

**Title slide.** `#m.slide(layout: "title")` with nothing else: it inherits `title`, `subtitle`, `authors`, and `date` from setup. Choose a stock variant when the preset suits the deck. When the deck wants type much quieter or more idiosyncratic than any preset, use the image layout's `full` variant as the escape hatch and write the title as ordinary text:

```typ
#m.slide(layout: "image", variant: "full", image: path("fig/cover.jpg"))[
  #set text(fill: white)
  #text(size: 1.5em)[Économie et Politique]

  POL1025

  Vincent Arel-Bundock
]
```

**Section divider.** A bare `= Section name` is enough. Text written between the `=` and the next heading becomes the section slide's subtitle, so a tagline costs no extra slide. Use `setup(layouts: (section: ...))` when every divider should share one designed variant (for example `m.layouts.section(variant: "baseline")`) or carry the same photograph. A one-off design is a field overlay: `#m.slide(layout: "section", variant: "toc")[Methods]`.

**Bulleted content slide.** A bare `== Slide title` followed by a list. Do not write `m.slide` for this.

**Two-column slide.** `columns: 2` on the content layout, then three positional blocks: header, left, right.

```typ
#m.slide(layout: "content", columns: 2)[== Comparison][
  Left column
][
  Right column
]
```

Use it for side-by-side figures too, wrapping each in `m.components.image(..., fit: "contain")` so neither is cropped. Add `tracks: (2fr, 1fr)` for an uneven split.

**Figure slide.** The image layout's default variant: a header above a contained picture, with an optional caption beneath.

```typ
#m.slide(layout: "image", image: path("fig/gdp.png"))[== Growth since 1950]
#m.slide(layout: "image", image: path("fig/pie.png"), caption: [Teaching, research, admin])[== My job]
```

`figure` defaults to `fit: "contain"`, which is what a chart needs: never crop data. `caption:` composes a native Typst `figure`, so it takes the deck's own `show figure.caption` rules and figure numbering; switch numbering off with `set figure(numbering: none)`. `caption:` is rejected by every other variant. The `figure` variant has header, image, and caption cells but no body, so a single standing line of commentary belongs in `caption:`.

**Picture beside text.** The directional variants `left`, `right`, `top`, and `bottom` pair a full-bleed picture with a header and body region, filled by two positional blocks:

```typ
#m.slide(layout: "image", variant: "right", image: path("fig/book.jpg"))[== Readings][
  - Almost every week
  - PDFs on the course site
]
```

Pass `[]` as the second block when the picture needs a title but no body. `tracks:` sizes the picture region and is side-independent, so `tracks: 40%` means the same thing under `left` and `right` and the two stay mirror images. These variants default to `fit: "cover"`; pass `fit: "contain"` for a chart, a screenshot, or any picture whose edges carry meaning.

**Full-bleed photograph with text over it.** The `full` variant puts the picture behind a single body cell:

```typ
#m.slide(
  layout: "image",
  variant: "full",
  image: (path: path("fig/auditorium.png"), scrim: black.transparentize(55%)),
)[
  #set text(fill: white)
  == Who are you?
]
```

`full` inherits the deck's ordinary text color, so it needs both halves of the contrast pair: a `scrim:` on the image spec to quiet the photograph, and a text fill override in the body. Omit the body entirely (`#m.slide(layout: "image", variant: "full", image: ...)`) for a bare picture slide with no text at all. Prefer `full` over `image-background` on a title or section layout when the composition is free-form rather than a titled preset.

**One big number or phrase.** Scope a centering rule around a single content slide:

```typ
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide(content: (body: text(size: 6em, weight: "bold")[15 000 000]))
]
```

**Table slide.** Native Typst `table` inside an ordinary `==` slide, wrapped in `align(center + horizon)`. Mosaic adds nothing here; use `stroke: (x, y) => ...` for booktabs-style rules.

**Continuation slide.** Repeating a title verbatim collides in the outline and in link targets. Repeat the heading and give it a distinct label: `== Appeals #metadata(none) <appeals-2>`.

Two recurring choices worth making once per deck:

- **`path()`, not a bare string.** Image paths inside layout and component arguments cross the package boundary, so a bare `"fig/x.png"` is searched for inside the installed Mosaic package and fails with `file not found (searched at .../packages/local/mosaic/...)`. Wrap every asset path in Typst's `path()`.
- **`fit:` on the content layout is for prose.** `layouts: (content: m.layouts.content(variant: "header-body", fit: "auto"))` is the right default for a text-heavy deck. Leave it off for an image-heavy deck: the fitter scales from the top-left, so fitting a figure sized with `height: 100%` drops its centering.

## 5. Configure the deck once

Put deck identity, semantic colors, layout overrides, recurring cell defaults, and page planes in `m.setup`:

```typ
#let authors = (
  m.layouts.author(
    "Ada Lovelace",
    affiliations: ([Systems Lab],),
  ),
)

#show: m.setup.with(
  title: [Reliable systems],
  subtitle: [One source of truth],
  authors: authors,
  date: [2026],
  colors: (accent: rgb("#007f73")),
  content: (
    footer: [Mosaic · Engineering],
    foreground: [#place(bottom + right)[#m.components.progress()]],
  ),
)

#m.slide(layout: "title")
```

Key setup arguments:

- `title`, `subtitle`, `authors`, `date`: deck identity. An author record is built by `m.layouts.author(name, ...)` and accepts `affiliations` (an array of institutions, as content or strings, deduplicated by value so authors sharing one institution share its legend number), `corresponding`, `email`, `kind`, and `orcid`; the `academic` title variant requires at least one author. Feeds title layouts, Typst document metadata, and the queryable `<mosaic-deck-metadata>` record. Setup does not insert a title slide automatically; each `m.slide(layout: "title")` chooses where one appears.
- `colors:`: partial overrides of the semantic palette. The roles are `canvas`, `surface`, `accent`, `text`, `muted`, and `line`. Unknown roles and non-color values are errors; omitted roles keep the active theme's defaults.
- `layouts:`: a dictionary overriding only `content`, `title`, or `section`. Both explicit slides and automatic `==` slides use the configured `content` layout.
- `content:`: recurring cell defaults (such as `footer`) plus the reserved `background` and `foreground` planes. Cell defaults apply only when the resolved layout contains that cell ID; explicit slide content or `none` overrides them.
- `paper:`: `"16-9"` (default) or `"4-3"`.
- `spacing:`: for example `(inset: 1.5em)` to set the default cell inset.
- `handout: true`: emit only the final frame of each logical slide.
- `output:`: `"slides"` (default), `"speaker"`, or `"notes"`.
- `overflow:`: `"warn"` (default) emits queryable `<mosaic-overflow-warning>` metadata for any cell whose content exceeds its allocation, `"error"` fails the compile at the end of the deck and names every offending cell with its slide and frame, and `"off"` disables observation. Fitted cells (see `fit:` below) are never observed: they cannot overflow.
- `frozen-counters:` / `frozen-states:`: values that advance once per logical slide instead of once per frame.

Do not introduce a separate footer, logo, background, or foreground feature API: recurring named-cell content and the reserved `content.background` / `content.foreground` planes own those jobs.

## 6. Themes

Import one facade as `m` and keep the rest of the deck unchanged:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m

#show: m.setup
```

Bundled facades are `light`, `dark`, `cream`, `metropolis`, and `minimalist`. The root package is exactly the bundled light facade.

Every facade exports the same `slide`, `note`, `pause`, `surface`, `grid`, `steps`, `components`, and `theme`, so those parts of a deck are theme-portable. Each facade also exports its own `definition`, the dictionary its `setup` is bound to. Each theme also exports `m.layouts`: the base layout constructors, rebound with that theme's defaults (for example, Cream's `content` defaults to `variant: "header-body"`). Every base argument remains available under every theme, with one exception: Metropolis's `title()` takes only `title`, `subtitle`, `authors`, and `date`, because it computes the variant from the authors itself.

To develop a theme, start locally: define the complete semantic palette and bind the dictionary directly:

```typ
#let theme = (
  colors: (
    canvas: white,
    surface: rgb("#f5f5f5"),
    text: rgb("#17243a"),
    muted: rgb("#52657f"),
    line: rgb("#aeb9c8"),
    accent: rgb("#a23b72"),
  ),
  apply: (body, colors: (:), options: (:)) => {
    set text(font: "Inter", size: 20pt)
    show: m.theme.normalize-lists
    body
  },
)

#show: m.theme.setup(theme)
```

Only `colors` is required; `name`, `defaults`, `options`, `layouts`, and `apply` are optional. Mosaic's engine emits no `set` or `show` rules of its own, so `apply` states the theme's whole look: base typography, headings, captions, list rhythm, and the canonical `<mosaic-cell-*>` rules the layouts compose against. Copy `light/definition.typ` for the complete set in its plainest form. `m.theme.normalize-lists` is an optional show-rule helper that loosens tight lists for presentation distance. To start from an existing theme, merge its exported definition: `base.definition + (name: .., colors: base.definition.colors + (accent: ..))`. The merge replaces `apply` outright, so to extend inherited rules rather than drop them, run the base callback first with `show: (base.definition.apply).with(colors: colors, options: options)`. A reusable packaged facade keeps three core files: `theme.typ` (binds and exports the public API), `definition.typ` (passive design decisions), and `layouts.typ` (the callable layout namespace), bound once with `mosaic.theme.setup(definition)`. Copy Light's files and change only design values. Theme definitions are passive data consumed by Mosaic's engine; never call setup internals from a theme or forward Mosaic's setup arguments.

## 7. Custom grids

Build custom structure only when headings and layout factories are insufficient. A Mosaic grid is a transparent tree of named cells:

```typ
#let composition = m.grid.h(
  m.grid.t(2fr, "main"),
  m.grid.t(1fr, m.grid.v(
    m.grid.t(2fr, "notes"),
    m.grid.t(1fr, "source"),
  )),
)

#m.slide(
  layout: composition,
  content: (
    main: [The main argument],
    notes: [Two parts notes],
    source: [One part source],
  ),
)
```

- `m.grid.h(...)` places children side by side; `m.grid.v(...)` stacks them. Each string is a cell ID. Children may be nested grids. Both accept `gutter:` (a native track size between adjacent children, default `0pt`) and `rule:` (a stroke drawn along each interior boundary, centered in the gutter, default `none`).
- Every direct child gets a `1fr` track by default. Wrap a child in `m.grid.t(size, child)` for another size; tracks accept `auto`, fixed lengths, percentages, and `fr` values.
- `m.grid.cell(id, ...)` creates an explicitly configured cell: `inset:` (padding, affects layout measurement), fixed `content:` (an image or logo owned by the grid, needing no body or `content:` entry), and `fit:` (`"width"`, `"contain"`, or `"auto"`) to scale content that would otherwise overflow the cell.
- Read a grid from the outside inward: largest split first, then replace children with nested splits. Keep descriptive IDs and indentation.

Cell insets provide slide margins (`setup` uses a zero page margin). Adjacent cells each contribute their own inset; a grid `gutter` separates cell surfaces and defaults to `0pt`. Use a layout factory instead of rebuilding a standard title, section, header/body, or footer structure as a raw grid.

## 8. Fill cells with content

A slide accepts cell content in two distinct forms. Do not mix them in one slide.

**Positional bodies** for short grids with obvious traversal order — matched in source order, left to right within `h`, top to bottom within `v`, recursively through nesting:

```typ
#m.slide(layout: m.grid.h("a", "b", "c"))[a][b][c]
```

**Named `content:`** for anything larger or reusable — assignment stays independent of traversal order:

```typ
#m.slide(layout: composition, content: (main: [...], notes: [...], source: [...]))
```

The cell ID connects all three layers: `m.grid.cell("body")` defines the cell, `content: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it. Every content-bearing cell must be supplied; unknown IDs are errors, except `id: none`, which means "suppress" and is a no-op when the layout has no such cell. That makes `content: (body: [...], footer: none)` safe to write across slides whose layouts do not all carry a footer.

Useful content values:

- `m.components.image(path("photo.webp"), alt: "...")`: like native `image()` but defaults `width`/`height` to `100%` and `fit` to `"cover"`. `scrim:` paints a layer over the picture and takes any Typst paint, so `scrim: black.transparentize(55%)` darkens the whole frame and a `gradient.linear(..)` darkens only the band the text occupies. The same key is accepted in the image dictionaries the `title`, `section`, and `image` layouts take. Use Typst's `path()` so the location anchors to the calling document across the package boundary. For a full-bleed image, set the cell's `inset: 0pt`.
- `m.components.frame()` (clipped semantic frame), `callout()` (side stripe with optional title), `label()` (compact inline label), `quote()` (attribution treatment), `divider()` (horizontal rule), `progress()` (position indicator). All return ordinary content for any cell or plane. Component `role:` values (`neutral`, `accent`) resolve from the theme palette.
- Native math, `figure` with captions and references, MiTeX for LaTeX math, ctheorems for theorem environments: all work unchanged inside cells.

## 9. Style with native Typst rules

Two kinds of rules cover a cell, split by what they touch:

- **Content rules** (text, alignment, paragraphs, lists) pass through the label as ordinary `set` rules.
- **Surface rules** (the cell's own fill, stroke, corner radius) need a wrapper block, because the cell block is constructed before rules apply. `m.surface(..)` builds exactly that wrapper:

```typ
#show label("mosaic-cell-copy"): set align(left + horizon)
#show label("mosaic-cell-copy"): set text(fill: black, size: 1.1em)
#show label("mosaic-cell-copy"): m.surface(fill: white)
// m.surface(fill: white) is the same rule as:
// it => block(width: 100%, height: 100%, fill: white, it)
```

For a content-sized cell (an `auto` track), pass `height: auto` to `m.surface` so the fill hugs the content. The planes carry `<mosaic-background>` and `<mosaic-foreground>` and take the same rules.

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

Typography is native rules after setup:

```typ
#set text(font: "EB Garamond", size: 26pt)
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
```

A semantic heading feeds outlines and bookmarks; use `text(...)` directly for display type that should not appear in navigation, or `heading(outlined: false, bookmarked: false)[...]`. Do not invent a separate Mosaic styling API or put decorative styling into the grid tree. Use `m.surface` and `m.components` when their documented semantic treatments fit; otherwise use native Typst.

## 10. Furniture: footers, planes, navigation

Keep three concerns distinct:

- **Cells** (`header`, `body`, `footer`) participate in the resolved grid. A recurring footer is a setup `content:` default for the real `footer` cell, applied whenever the resolved layout contains that cell. An explicit slide value overrides it; `none` suppresses it on one slide. Title slides have no `footer` cell, so they are unaffected.
- **Planes** are the reserved `background` and `foreground` content entries. They cover the full usable slide area without changing grid measurements. A slide inherits the setup plane by default, replaces it with its own entry, or suppresses it with `none`.
- **Runtime state** supplies logical slide, section, and frame counters, read by components such as `m.components.progress()`.

A logo is ordinary setup foreground content: `place(top + right, dx: .., dy: ..)[#image(..)]` inside `m.setup(content: (foreground: ...))`. A photographic background is a slide-sized `m.components.image` (with `scrim:` for contrast) in the `background` entry.

`m.components.progress()` follows the logical slide counter (all frames of one slide share a number). Its `variant:` is `"1/1"` (default), `"1"`, `"circle"`, or `"line"`. `count:` selects the `"slides"` (default) or `"sections"` counter; `current:` and `total:` override the counter explicitly. Appearance goes through `role:` (default `"accent"`), `color:`, `track:` (the inactive color), `width:` (line variant), `size:` (circle diameter), and `thickness:`.

Navigation stays native because headings stay native:

- Table of contents: `outline(depth: 2)`; every entry links to its heading.
- Breadcrumbs: contextual `query` with a selector ending at `here()` to find the active section and slide headings.
- Section links: `query(heading.where(level: 1, outlined: true))`; each result gives a label via `body` and a target via `location()`.
- Slide links: label a content slide (`== Results <results>`) and `#link(<results>)[...]`. For an explicit slide, put `#metadata(none) <id>` at the start of its content.

## 11. Incremental reveals

Write one logical slide; Mosaic adds frames until the last timed command has run and discovers the frame count. Hidden content keeps its space by default so the slide stays still; use `before: "removed"` when surrounding content should expand into that space. Choose the smallest command:

- `m.pause`: advances subsequent source-order content to the next frame. Scoped to its containing content stream, so it also works inside blocks, fixed cells, and planes. Empty leading, trailing, or consecutive pauses never create blank frames.
- `m.steps.on(range)[content]`: shows content over an exact step range. Ranges are integers, open (`"3-"`), or closed (`"2-4"`). `before:` and `after:` control the surrounding steps and each take `"visible"`, `"hidden"` (the default, keeps the space), `"dimmed"`, or `"removed"` (releases the space).
- `m.steps.reveal[...]`: accumulates a list or sequence one item at a time.
- `m.steps.replace[first][second]`: swaps alternatives in one stable slot sized by the largest alternative.
- `m.steps.reduce`: connects the same timing model to custom structures (CeTZ canvases, Fletcher diagrams); preserve hidden bounds so later additions do not shift the drawing.

```typ
#m.slide[
  == Findings
  - The estimate is positive.
  #m.pause
  - The interval excludes zero.
]
```

Constraints and options:

- A heading cannot be placed inside an incremental grid node (`m.steps.reveal`, `m.steps.replace`, and related reducers); keep headings structurally stable across frames.
- `setup(handout: true)` emits only the final frame of each logical slide, including timed planes.
- Native counters and states advance once per physical frame by default. List them in `setup(frozen-counters: (...), frozen-states: (...))` to advance once per logical slide instead.
- Reveal one part of an equation at a time by replacing plain terms with colored underbraces via steps commands; the layout stays fixed.

## 12. Speaker notes and outputs

Attach notes with `m.note[...]`. Notes never render in the default `output: "slides"` and never add frames. A note outside timing commands applies to every frame; a note after `m.pause` or inside a steps command follows that command's frame assignment. Multiple applicable notes accumulate in source order.

```typ
#show: m.setup.with(output: "speaker")  // A4: frame thumbnail + notes
#show: m.setup.with(output: "notes")    // A4: notes only
```

Both companion outputs write one page per emitted frame and fail with an explicit overflow diagnostic when notes do not fit. Every frame carries `<mosaic-speaker-notes>` metadata (`logical-slide`, `frame`, `notes`) queryable with Typst's `query`.

## 13. Recipes

- **Reuse a slide**: define it as a function and call it wherever it should appear; each call is a new logical slide with the same incremental sequence.
- **One-off dark slide**: scope `set text(fill: white)` and a `background` block inside `#[ ... ]` around one slide.
- **Aspect ratio**: `setup(paper: "4-3")`; default is `"16-9"`.
- **Inspect overflowing cells**: Mosaic emits non-fatal metadata when a rendered cell exceeds its allocation:

  ```sh
  typst eval 'query(<mosaic-overflow-warning>).map(it => it.value)' --in slides.typ
  ```

  The reported `logical-slide` is not the page number once the deck uses `m.pause` or `m.steps`. Ask for both when hunting a specific slide down, then render just those pages to look at them:

  ```sh
  typst eval 'query(<mosaic-overflow-warning>).map(it => (it.value.logical-slide, it.location().page(), it.value.cell))' --in slides.typ
  typst compile --root . slides.typ /tmp/p-{n}.png --pages 20,23 --ppi 55
  ```

  Overflow is nearly always a *body* cell holding more prose than its band. On a stacked image variant (`top`/`bottom`) the usual fix is a smaller `tracks:` so the text band grows; when the body is a full bullet list plus a picture, abandon the image layout and use an ordinary content slide with `m.components.image(.., fit: "contain", height: N%)`, which is predictable.

- **Convert a whole deck set**: when porting many sibling decks, keep an identical `m.setup` block in each so they stay a series, and drive the build from one pattern rule. Watch for output collisions before running that rule: `quarto render` + `pagedown::chrome_print` print `<deck>.pdf` from the same basename a Typst deck compiles to, so a first `make` can overwrite an existing set of PDFs. Whether that is wanted (the Typst decks are replacing them) or not (both sets must survive, so Typst output belongs in its own directory) is the author's call — ask rather than assume, and check whether the directory is under version control before finding out the hard way.

- **Inspect deck metadata**:

  ```sh
  typst eval 'query(<mosaic-deck-metadata>).map(it => it.value)' --in deck.typ
  ```

## 14. Diagnose before changing structure

When compilation fails:

1. Recompile the smallest affected deck and capture the exact diagnostic.
2. Check for an unknown layout name, a missing named cell, mixed positional and named content, or an invalid layout variant.
   - `unexpected argument: variant` on `m.layouts.title(..)` under Metropolis means that theme's `title()` computes the variant itself and takes only `title`, `subtitle`, `authors`, and `date`.
   - `unexpected argument: number` at `src/incremental/transform.typ` means an enum item carries an explicit `number` field, which Mosaic's incremental transform cannot rebuild. Two sources, and the second is easy to miss: literal `3.` / `4.` markers used to continue a numbered list (write `#enum(start: 3)[..][..]` instead), and any *wrapped prose line that happens to begin with a number and a period* — a line starting `1942.` is parsed by Typst as an enum item numbered 1942. Grep the deck with `grep -nE '^\s*[0-9]+\.'` and reword so no line begins that way.
   - `failed to decode image (Format error decoding Jpeg ...)` or `unknown image format` means the file's extension lies about its bytes. Typst chooses its decoder from the extension, so a PNG or WebP named `.jpg` fails. Check with `file -b`, and prefer adding a correctly-named *copy* over renaming when other documents reference the original name. Typst has no AVIF decoder at all — convert those.
3. Confirm that dictionary-held functions are called with parentheses when needed, for example `(theme.layouts.section)()`.
4. Confirm that `layouts:` passed to setup is a dictionary and only overrides `content`, `title`, or `section`.
5. Confirm that image variants receive an image and valid tracks.
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
