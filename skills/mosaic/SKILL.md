---
name: mosaic
description: Complete tutorial and workflow for creating slide decks with the Mosaic package for Typst. Use when creating, editing, styling, debugging, or verifying Typst presentations built with Mosaic, or when the user mentions Mosaic slides, Typst slides, slide grids, named cells, themes, incremental reveals, speaker notes, handouts, or Mosaic compilation errors.
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

- A level-one heading (`=`) creates an unnumbered *section slide* with a larger, centered title and advances the section counter.
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
```

The standard names are `content`, `title`, and `section`. Note that `layout: "content"` resolves to the *configured* content layout, whose stock value is `m.layouts.content(variant: "header-body")`, whereas the `m.layouts.content()` factory defaults to `variant: "header-body-footer"`. The two spellings are not interchangeable; a theme or a setup `layouts:` override changes the former only.

Content slides are numbered by default; title and section slides are not. Section slides advance the section counter. `numbered:` explicitly overrides the numbering default.

Use a layout factory (`m.layouts.*`) only when choosing a variant or passing arguments:

```typ
#m.slide(
  layout: m.layouts.title(
    title: [Reliable systems],
    subtitle: [One source of truth],
    variant: "accent-block",
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

- **Title**: `academic`, `left-aligned`, `centered-stack`, `accent-block`, `image-left`, `image-right`, `image-top`, `image-bottom`, `image-background`.
- **Section**: `plain` and the same five image variants.
- **Content**: `body`, `header-body`, `body-footer`, `header-body-footer`.

`m.layouts.title()` inherits `title`, `subtitle`, `authors`, and `date` from setup, so `m.slide(layout: "title")` needs no body. An explicit layout argument wins; pass `none` (or `()` for `authors`) to suppress an inherited field on one slide. For image variants, `darken:` or `lighten:` on the image quiets the photograph; pair `image-background` with a scoped text-color rule on the `<mosaic-cell-title>` or `<mosaic-cell-section>` label for contrast.

A direct `m.layouts.content/title/section(...)` value retains its semantic layout name. A raw custom grid uses ordinary content-slide semantics.

To replace a named layout deck-wide, configure it once in setup; to reuse one for selected slides, bind it with `.with`:

```typ
#show: m.setup.with(layouts: (
  section: m.layouts.section(variant: "image-background", image: "chapter.jpg"),
))

#let myslide = m.slide.with(layout: m.layouts.content(variant: "header-body"))
#myslide(content: (header: [== Slide title], body: [Slide content]))
```

## 4. Configure the deck once

Put deck identity, semantic colors, layout overrides, recurring cell defaults, and page planes in `m.setup`:

```typ
#let authors = (
  m.layouts.author(
    "Ada Lovelace",
    affiliations: ((id: "lab", name: [Systems Lab]),),
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

- `title`, `subtitle`, `authors`, `date`: deck identity. An author record is built by `m.layouts.author(name, ...)` and accepts `affiliations` (records of `id` and `name`), `corresponding`, `email`, `kind`, and `orcid`; the `academic` title variant requires at least one author. Feeds title layouts, Typst document metadata, and the queryable `<mosaic-deck-metadata>` record. Setup does not insert a title slide automatically; each `m.slide(layout: "title")` chooses where one appears.
- `colors:`: partial overrides of the semantic palette. The roles are `canvas`, `surface`, `accent`, `text`, `muted`, and `line`. Unknown roles and non-color values are errors; omitted roles keep the active theme's defaults.
- `layouts:`: a dictionary overriding only `content`, `title`, or `section`. Both explicit slides and automatic `==` slides use the configured `content` layout.
- `content:`: recurring cell defaults (such as `footer`) plus the reserved `background` and `foreground` planes. Cell defaults apply only when the resolved layout contains that cell ID; explicit slide content or `none` overrides them.
- `paper:`: `"16-9"` (default) or `"4-3"`.
- `spacing:`: for example `(inset: 1.5em)` to set the default cell inset.
- `handout: true`: emit only the final frame of each logical slide.
- `output:`: `"slides"` (default), `"speaker"`, or `"notes"`.
- `overflow: "off"`: disable overflow observation.
- `frozen-counters:` / `frozen-states:`: values that advance once per logical slide instead of once per frame.

Do not introduce a separate footer, logo, background, or foreground feature API: recurring named-cell content and the reserved `content.background` / `content.foreground` planes own those jobs.

## 5. Themes

Import one facade as `m` and keep the rest of the deck unchanged:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m

#show: m.setup
```

Bundled facades are `light`, `dark`, `cream`, `metropolis`, and `minimalist`. The root package is exactly the bundled light facade.

Every facade exports the same `slide`, `note`, `pause`, `surface`, `grid`, `steps`, `components`, and `theme`, so those parts of a deck are theme-portable. `m.layouts` is *not*: each theme exports its own callable layout namespace, and the themed versions are deliberately narrower than the base API. Metropolis's `title()` takes only `title`, `subtitle`, `authors`, and `date` (it picks the variant itself), its `content()` takes no arguments, and its `section()` takes only `subtitle`. So `m.layouts.section(variant: "plain")` compiles under the root facade and fails with `unexpected argument: variant` under Metropolis. When switching a deck to a theme, check that theme's `layouts.typ` for the arguments it accepts; when writing theme-portable code, pass layout arguments only through `m.setup`.

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
  text: (font: "Inter", size: 20pt),
)

#show: m.theme.setup(theme)
```

Only `colors` is required; `name`, `defaults`, `options`, `text`, `normalize-lists`, `layouts`, and `apply` are optional. A reusable packaged facade keeps three core files: `theme.typ` (binds and exports the public API), `definition.typ` (passive design decisions), and `layouts.typ` (the callable layout namespace), bound once with `mosaic.theme.setup(definition)`. Copy Light's files and change only design values. Theme definitions are passive data consumed by Mosaic's engine; never call setup internals from a theme or forward Mosaic's setup arguments.

## 6. Custom grids

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
- `m.grid.cell(id, ...)` creates an explicitly configured cell: `inset:` (padding, affects layout measurement) and fixed `content:` (an image or logo owned by the grid, needing no body or `content:` entry).
- Read a grid from the outside inward: largest split first, then replace children with nested splits. Keep descriptive IDs and indentation.

Cell insets provide slide margins (`setup` uses a zero page margin). Adjacent cells each contribute their own inset; a grid `gutter` separates cell surfaces and defaults to `0pt`. Use a layout factory instead of rebuilding a standard title, section, header/body, or footer structure as a raw grid.

## 7. Fill cells with content

A slide accepts cell content in two distinct forms. Do not mix them in one slide.

**Positional bodies** for short grids with obvious traversal order — matched in source order, left to right within `h`, top to bottom within `v`, recursively through nesting:

```typ
#m.slide(layout: m.grid.h("a", "b", "c"))[a][b][c]
```

**Named `content:`** for anything larger or reusable — assignment stays independent of traversal order:

```typ
#m.slide(layout: composition, content: (main: [...], notes: [...], source: [...]))
```

The cell ID connects all three layers: `m.grid.cell("body")` defines the cell, `content: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it. Every content-bearing cell must be supplied; unknown IDs are errors.

Useful content values:

- `m.components.image(path("photo.webp"), alt: "...")`: like native `image()` but defaults `width`/`height` to `100%` and `fit` to `"cover"`. Mutually exclusive `lighten:`/`darken:` add a white or black wash (ratio = wash opacity). Use Typst's `path()` so the location anchors to the calling document across the package boundary. For a full-bleed image, set the cell's `inset: 0pt`.
- `m.components.frame()` (clipped semantic frame), `callout()` (side stripe with optional title), `label()` (compact inline label), `quote()` (attribution treatment), `divider()` (horizontal rule), `progress()` (position indicator). All return ordinary content for any cell or plane. Component `role:` values (`neutral`, `accent`) resolve from the theme palette.
- Native math, `figure` with captions and references, MiTeX for LaTeX math, ctheorems for theorem environments: all work unchanged inside cells.

## 8. Style with native Typst rules

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

## 9. Furniture: footers, planes, navigation

Keep three concerns distinct:

- **Cells** (`header`, `body`, `footer`) participate in the resolved grid. A recurring footer is a setup `content:` default for the real `footer` cell, applied whenever the resolved layout contains that cell. An explicit slide value overrides it; `none` suppresses it on one slide. Title slides have no `footer` cell, so they are unaffected.
- **Planes** are the reserved `background` and `foreground` content entries. They cover the full usable slide area without changing grid measurements. A slide inherits the setup plane by default, replaces it with its own entry, or suppresses it with `none`.
- **Runtime state** supplies logical slide, section, and frame counters, read by components such as `m.components.progress()`.

A logo is ordinary setup foreground content: `place(top + right, dx: .., dy: ..)[#image(..)]` inside `m.setup(content: (foreground: ...))`. A photographic background is a slide-sized `m.components.image` (with `darken:` for contrast) in the `background` entry.

`m.components.progress()` follows the logical slide counter (all frames of one slide share a number). Its `variant:` is `"1/1"` (default), `"1"`, `"circle"`, or `"line"`. `count:` selects the `"slides"` (default) or `"sections"` counter; `current:` and `total:` override the counter explicitly. Appearance goes through `role:` (default `"accent"`), `color:`, `track:` (the inactive color), `width:` (line variant), `size:` (circle diameter), and `thickness:`.

Navigation stays native because headings stay native:

- Table of contents: `outline(depth: 2)`; every entry links to its heading.
- Breadcrumbs: contextual `query` with a selector ending at `here()` to find the active section and slide headings.
- Section links: `query(heading.where(level: 1, outlined: true))`; each result gives a label via `body` and a target via `location()`.
- Slide links: label a content slide (`== Results <results>`) and `#link(<results>)[...]`. For an explicit slide, put `#metadata(none) <id>` at the start of its content.

## 10. Incremental reveals

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

## 11. Speaker notes and outputs

Attach notes with `m.note[...]`. Notes never render in the default `output: "slides"` and never add frames. A note outside timing commands applies to every frame; a note after `m.pause` or inside a steps command follows that command's frame assignment. Multiple applicable notes accumulate in source order.

```typ
#show: m.setup.with(output: "speaker")  // A4: frame thumbnail + notes
#show: m.setup.with(output: "notes")    // A4: notes only
```

Both companion outputs write one page per emitted frame and fail with an explicit overflow diagnostic when notes do not fit. Every frame carries `<mosaic-speaker-notes>` metadata (`logical-slide`, `frame`, `notes`) queryable with Typst's `query`.

## 12. Recipes

- **Reuse a slide**: define it as a function and call it wherever it should appear; each call is a new logical slide with the same incremental sequence.
- **One-off dark slide**: scope `set text(fill: white)` and a `background` block inside `#[ ... ]` around one slide.
- **Aspect ratio**: `setup(paper: "4-3")`; default is `"16-9"`.
- **Inspect overflowing cells**: Mosaic emits non-fatal metadata when a rendered cell exceeds its allocation:

  ```sh
  typst eval 'query(<mosaic-overflow-warning>).map(it => it.value)' --in slides.typ
  ```

- **Inspect deck metadata**:

  ```sh
  typst eval 'query(<mosaic-deck-metadata>).map(it => it.value)' --in deck.typ
  ```

## 13. Diagnose before changing structure

When compilation fails:

1. Recompile the smallest affected deck and capture the exact diagnostic.
2. Check for an unknown layout name, a missing named cell, mixed positional and named content, or an invalid layout variant.
   - `unexpected argument: variant` (or another layout argument) means the active *themed* facade narrows that layout's signature. Read that theme's `layouts.typ` rather than the base layout API.
3. Confirm that dictionary-held functions are called with parentheses when needed, for example `(theme.layouts.section)()`.
4. Confirm that `layouts:` passed to setup is a dictionary and only overrides `content`, `title`, or `section`.
5. Confirm that image variants receive an image and valid tracks.
6. Change the narrowest source responsible, then recompile the original deck.

Do not add compatibility aliases for removed APIs. In particular, slides use `layout:`, not a separate semantic selector.

## 14. Verify the result

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

## 15. Reflect and improve this skill

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
