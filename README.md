# Mosaic

Mosaic is a slide package for [Typst](https://typst.app/). Write ordinary Typst headings and content for most slides, choose a named layout when you need a title or section divider, and drop down to a grid of named cells for custom composition.

![An academic title slide made with Mosaic](docs/assets/examples/structure/title-layout-1.svg)

Mosaic provides:

- automatic slides from level-one and level-two headings;
- content, title, and section layouts with visual variants;
- nested horizontal and vertical grids with stable cell names;
- native Typst styling through `show` and `set` rules;
- incremental reveals, speaker notes, handouts, and printable notes;
- five bundled themes with the same authoring API.

Mosaic 0.0.1 requires Typst 0.15 or newer. It is currently installed from source as a local Typst package.

## Install

```sh
git clone https://github.com/vincentarelbundock/mosaic.git
cd mosaic
make install
```

`make install` copies Mosaic to Typst's local package index as `@local/mosaic:0.0.1`.

## Your first deck

Save this as `talk.typ`:

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  title: [A short talk],
  subtitle: [Built with Typst and Mosaic],
  colors: (accent: rgb("#007f73")),
)

#m.slide(layout: "title")

= Why Mosaic

== Ordinary Typst

Headings create slides. Paragraphs, lists, equations, figures, and tables remain ordinary Typst content.

== One more point

- Level-one headings create section slides.
- Level-two headings create content slides.
```

Compile it with:

```sh
typst compile talk.typ
```

Mosaic creates the title slide explicitly. It does not insert one during setup.

## How authoring works

### Headings for ordinary slides

After `#show: m.setup`, a level-one heading creates an unnumbered section slide:

```typ
= Methods
```

A level-two heading creates a numbered content slide. The heading fills the layout's `header` cell and the following content fills `body`:

```typ
== Results

The estimate is positive.
```

### Named layouts for explicit slides

`layout` selects the slide design and its standard behavior:

```typ
#m.slide()                    // configured content layout
#m.slide(layout: "content")
#m.slide(layout: "title")
#m.slide(layout: "section")[Methods]
```

The standard names are `content`, `title`, and `section`. Content slides are numbered by default; title and section slides are not. An explicit `numbered:` value overrides that default.

Use a layout factory to select a variant or adjust one slide:

```typ
#m.slide(
  layout: m.layouts.content(
    variant: "header-body",
    columns: 2,
    tracks: (2fr, 1fr),
  ),
  content: (
    header: [Comparison],
    body-1: [Main result],
    body-2: [Supporting evidence],
  ),
)
```

Layout factories are deferred recipes. They resolve against the active setup and theme when the slide renders.

### Named cells for custom composition

A grid is a transparent tree of cells. `m.grid.h` splits horizontally, `m.grid.v` splits vertically, and `m.grid.t` assigns a native Typst track size:

```typ
#let comparison = m.grid.h(
  m.grid.t(2fr, "main"),
  m.grid.v("details", "notes"),
)

#m.slide(
  layout: comparison,
  content: (
    main: [Main result],
    details: [Supporting detail],
    notes: [Interpretation],
  ),
)
```

You may also fill content-bearing cells positionally in traversal order:

```typ
#m.slide(layout: comparison)[Main result][Supporting detail][Interpretation]
```

Use named `content:` for multi-cell grids when the relationship between content and cells should remain obvious after the grid changes.

### Native Typst styling

Every rendered cell has a native label named `<mosaic-cell-ID>`. Style it with ordinary Typst rules:

```typ
#show label("mosaic-cell-body"): set align(horizon)
#show label("mosaic-cell-body"): it => block(
  width: 100%,
  height: 100%,
  fill: luma(240),
  inset: 1.2em,
  it,
)
```

Typography, headings, figures, tables, and one-off local styling also use native `set` and `show` rules. Put deck-level rules after `#show: m.setup`.

Mosaic's design promise is precise: every rule a slide renders with comes from the active theme or from your own rules, never from the engine. The engine holds a single deck record, written once by `setup` and immutable afterward, containing only what you declared there: structure, geometry, and the semantic colors. The colors and roles are the one sanctioned exception to rule-based styling, because Typst offers no native channel that could carry paint values into a component call. There is no other configuration state.

## Deck setup

Declare deck metadata, semantic colors, recurring cell defaults, and full-slide planes once:

```typ
#let authors = (
  m.layouts.author("Ada Lovelace"),
)

#show: m.setup.with(
  title: [Reliable systems],
  subtitle: [One source of truth],
  authors: authors,
  date: [2026],
  colors: (accent: rgb("#007f73")),
  content: (
    footer: [Mosaic · Engineering],
    foreground: [
      #place(bottom + right, dx: -1.25em, dy: -0.35em)[
        #m.components.progress()
      ]
    ],
  ),
)
```

The semantic color keys are `canvas`, `surface`, `accent`, `text`, `muted`, and `line`. Overrides are partial, so omitted colors retain the active theme's values.

`content:` also owns recurring values for stable cell IDs. The reserved `background` and `foreground` entries fill the two full-slide planes. Set an inherited entry to `none` on a slide to suppress it.

## Incremental content and notes

Use `m.pause` for a persistent source-order reveal:

```typ
#m.slide[
  == Findings
  - The estimate is positive.
  #m.pause
  - The interval excludes zero.
]
```

Mosaic discovers the frame count. `m.steps.on`, `m.steps.reveal`, `m.steps.replace`, and `m.steps.reduce` provide explicit timing and replacement when a pause is not enough. `setup(handout: true)` emits only the final frame of each logical slide.

Attach non-rendering notes with `m.note[...]`:

```typ
#m.slide[
  #m.note[Explain the assumptions before showing the result.]
  == Main result
  The estimate is positive.
]
```

The default `output: "slides"` omits note text. Use `output: "speaker"` for slide thumbnails with notes or `output: "notes"` for notes alone.

## Themes

The root package is the light theme. To use another bundled theme, import its facade as `m`:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m

#show: m.setup
```

The bundled themes are `light`, `dark`, `cream`, `metropolis`, and `minimalist`. Each exposes the same `setup`, `slide`, `grid`, `layouts`, `steps`, and `components` API.

See [`docs/appearance/themes.typ`](docs/appearance/themes.typ) for theme customization and the copyable external-theme examples.

## Documentation and examples

- [Get started](docs/start/): the first deck, the vocabulary, and a complete named-cell walkthrough
- [Slide structure](docs/slides/): grids, tracks, built-in layouts, and content assignment
- [Content](docs/content/): images and scrims, the components library, and math
- [Appearance](docs/appearance/): native styling, typography, semantic colors, and themes
- [Slide furniture](docs/furniture/): background and foreground planes, footers, progress, and navigation
- [Incremental reveals](docs/incremental/): pauses, ranges, reveals, replacement, notes, and handouts
- [Slides and notes API](docs/api/slides.typ): explicit slides, speaker notes, and companion outputs
- [Examples](docs/examples.typ): complete decks and focused examples
- [API sources](docs/api/): public functions grouped by topic
- [Architecture](ARCHITECTURE.md): internals and extension boundaries

Build the HTML guide locally with:

```sh
make website
```

The generated site starts at `docs/index.html`.

## Agent skill

This repository includes an installable Agent Skill that teaches compatible coding agents Mosaic's authoring model and verification workflow. The current `skills` CLI requires Node 22.20 or newer.

List the skill without installing it:

```sh
npx skills add vincentarelbundock/mosaic --list
```

Install it for a detected agent:

```sh
npx skills add vincentarelbundock/mosaic --skill mosaic
```

Target Hermes Agent or Codex explicitly with `--agent hermes-agent` or `--agent codex`. The skill source is [`skills/mosaic/SKILL.md`](skills/mosaic/SKILL.md).

## Development

```sh
make doctor    # report required and optional tools
make check     # run package, diagnostics, and documentation-integrity tests
make website   # build examples, API pages, and the website
make build     # run the complete validation and documentation pipeline
```

`make check` and `make website` install the current worktree before compiling, so `@local/mosaic:0.0.1` never resolves to a stale package during repository development.

Mosaic is licensed under MIT; see [`mosaic/typst.toml`](mosaic/typst.toml).
