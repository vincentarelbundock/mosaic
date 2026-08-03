# Mosaic roadmap

This backlog records capabilities found in the Touying 0.7.4 and Polylux
0.4.0 feature review that Mosaic does not currently provide. It is a feature
inventory, not a commitment to reproduce either framework. New APIs should
preserve Mosaic's small, Typst-native grid model.

Sections below the feature inventory record findings from real deck-authoring
sessions rather than the framework comparison; each notes how it was observed.

The comparison does not repeat features Mosaic already has: heading-driven
and explicit slides, automatic section slides, logical slide/section and step progress,
background and foreground planes, native outlines and bookmarks, range-based
visibility, item-by-item reveals, space-preserving alternatives, math
overlays, CeTZ/Fletcher reducers, composable grids, or per-slide inherited
grid and visual-plane configuration.

## Incremental content

- [ ] Add concise sequential and parallel advancement primitives comparable
  to `pause`, `meanwhile`, `jump`, or independent reveal strands.
- [ ] Add progressive raw-code display with optional line numbers,
  configurable reveal and highlight ranges, and styling for past, current,
  and future lines.

## Speaker notes and presenting

- [ ] Attach speaker notes to a logical slide or selected frames; accumulate
  multiple note blocks rather than silently replacing earlier notes.
- [ ] Support progressive note content and automatic frame assignment based
  on where a note occurs in the reveal sequence.
- [ ] Provide presenter grids such as notes on a second screen, a slide
  thumbnail beside notes, and a notes-only document.

## Structure, navigation, and configuration

- [ ] Make the heading depth that creates slides configurable and support
  subsection/subsubsection structure plus optional automatic divider slides.
- [ ] Add structural controls for hidden, skipped-divider, unnumbered,
  unoutlined, and unbookmarked headings/slides.
- [ ] Add appendix mode with an appendix-aware main-slide count and
  denominator.
- [ ] Support short heading/title variants for navigation furniture without
  changing the visible or semantic heading.
- [ ] Expose a progress ratio for custom navigation furniture.
- [ ] Add adaptive and progressive outline helpers, including multi-column
  outlines.
- [ ] Add clickable previous/next controls and distinguish navigation by
  logical slide, physical frame, or both.
- [ ] Add a next-slide configuration scope with predictable inheritance and
  reset behavior.

## Academic content

- [ ] Allow footnote numbering to reset per logical slide.

## Defects

- [x] `setup(overflow: "error")` always names slide 0 in its diagnostic, so the
  mode cannot tell an author where the clip is. The `"warn"` path resolves the
  same counter correctly, which suggests the error path reads the logical-slide
  state outside the context where it is available.

  Fixed. The diagnosis was right: `observe-overflow` runs inside `layout`,
  before introspection converges, so the slide counter still held its pre-layout
  value when the assertion fired. The failure now comes from `overflow-report`,
  which `setup` places after the deck and which queries the same
  `<mosaic-overflow-warning>` records the `"warn"` path exposes. Both modes
  therefore report identical numbers by construction, and `"error"` names every
  offending cell rather than only the first. Covered by
  `tests/invalid/overflow-error.typ`, whose expected diagnostic pins the slide
  number.

## Layout and styling

- [ ] Let the title stack scale as a unit, for example a `scale:` argument on
  `m.layouts.title`. `title-typography` (`layout-title.typ`) anchors the
  subtitle and metadata tiers to `settings.type.body.size` in pt so they do not
  compound with the display scale supplied by the `<mosaic-cell-title>` label
  rules. That correctly resists compounding, but it also means a label rule that
  resizes the title moves only the title: at `show label("mosaic-cell-title"):
  set text(size: 0.3em)` the subtitle renders *larger* than the title, which no
  author wants. There is currently no supported way to ask for a proportionally
  smaller title stack.

  Encountered while porting a course deck whose title slide sits over a
  photograph and wanted quiet, small type in the corner. The related fill bug is
  fixed — the stack now inherits the cell's text fill, so the light-on-dark case
  no longer needs a custom grid for *color* — but the deck still hand-builds its
  title cell out of `m.grid.h(m.grid.cell("title", inset: 2em))` purely to
  control the relative sizes of three lines. That is the last reason a routine
  title slide has to drop to the raw grid API.

- [ ] Consider a cell-level `align:` on `m.grid.cell` and the content layout.
  Content does not stretch to its cell, so `align(center + horizon)` alone does
  not centre vertically; the working spelling is `block(height: 100%, align(..))`.
  `m.grid.cell` already takes `inset:` and `fit:`, so `align:` would sit
  naturally beside them and remove a wrapper that is easy not to know about.

- [ ] Consider a captioned-image component, for example
  `m.components.figure(src, caption: ..)` defaulting to `fit: "contain"`.
  `m.components.image` defaults to `fit: "cover"`, which is right for background
  planes and wrong for a chart that must not be cropped, and no component pairs
  an image with a caption. In a 58-slide lecture deck ported from Quarto, nearly
  every slide was one centred, contained figure; the deck defines a local `fig()`
  helper and calls it about forty times. This is the most repeated helper in an
  image-heavy academic deck.

## Documentation

- [ ] Document citation workflows using native Typst footnotes and
  bibliographies.
- [ ] Document compatible presentation workflows without adding
  viewer-specific integrations to Mosaic.
