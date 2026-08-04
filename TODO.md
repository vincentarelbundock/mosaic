# Mosaic roadmap

This backlog records capabilities found in the Touying 0.7.4 and Polylux
0.4.0 feature review that Mosaic does not currently provide. It is a feature
inventory, not a commitment to reproduce either framework. New APIs should
preserve Mosaic's small, Typst-native grid model.

Sections below the feature inventory record findings from real deck-authoring
sessions rather than the framework comparison; each notes how it was observed.
Several come from one corpus in particular: twenty POL1025 lecture decks,
6,938 lines of Typst and 423 `m.slide` calls, converted from Quarto/reveal.js.
That is one author and one conversion event, so the counts quoted below are
evidence to check, not weight on their own.

The comparison does not repeat features Mosaic already has: heading-driven
and explicit slides, automatic section slides, logical slide/section and step progress,
background and foreground planes, native outlines and bookmarks, range-based
visibility, item-by-item reveals, space-preserving alternatives, math
overlays, CeTZ/Fletcher reducers, composable grids, or per-slide inherited
grid and visual-plane configuration.

## Docs

+ Add bullet point and 2-column text from metropolis to the showcase video
+ lightbox of the showcase should be a proper video player with full screen and controls

## Incremental content

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

- [ ] Many slides in the cream example deck (`docs/examples/decks/cream`) render
  their text white, which is wrong against the theme's pale ground. The example
  is the theme's shop window, so whatever resolves the text fill there is either
  picking the wrong semantic color or is being overridden by the deck itself;
  both the theme's fill resolution and `main.typ`/`preamble.typ` need checking
  before deciding which side is at fault.

- [ ] `fit: "auto"` scales its content from the top-left, so a figure sized with
  `height: 100%` loses its centring the moment fitting engages. That makes the
  fitter unusable in figure-heavy decks: across the corpus above it appears once
  in 6,938 lines, and the author recorded the reason at `00_intro.typ:9`. The
  fallback is 28 hand-written `#set text(size: ..)` calls between 0.8em and
  0.92em. If alignment survives fitting, `fit: "auto"` may become adoptable
  as-is and the hand-shrinking disappears without any new API.

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
  `m.layouts.title`. The composed title stack (`layout/title.typ`) anchors the
  subtitle and metadata tiers to `settings.base-size` so they do not compound
  with the display scale supplied by the `<mosaic-cell-title>` label rules. That correctly resists compounding, but it also means a label rule that
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

  The same gap shows up one step further in: a figure placed inside an ordinary
  content cell, rather than in a stacked image layout, has to be wrapped in
  `align(center, ..)` and given a hand-found height. The corpus uses twelve
  distinct values (30% through 88%), and the author documents at
  `04_politique_fiscale.typ:130` why the stacked layouts do not cover the case:
  four bullets plus a photograph is more than their body band holds. Worth
  deciding whether the component centres by default, whether `height: auto`
  should mean "fill the remaining cell", and whether a prose-plus-figure layout
  variant belongs beside the stacked ones.

## Tooling and diagnostics

- [ ] Make `overflow: "warn"` visible without shell plumbing. The warner emits
  queryable `<mosaic-overflow-warning>` metadata and nothing else, so the corpus
  above drives it from a Makefile loop over
  `typst eval 'query(<mosaic-overflow-warning>).map(it => it.value.logical-slide)'`.
  The queryable design is deliberate and should stay, but it is also the
  feedback loop the author runs against when tuning `tracks:` percentages, body
  text sizes, and figure heights, so tightening it reduces friction in three
  places at once. This is the least invasive item in the file and probably the
  highest leverage.

## Documentation

- [ ] Document citation workflows using native Typst footnotes and
  bibliographies.
- [ ] Document compatible presentation workflows without adding
  viewer-specific integrations to Mosaic.
- [ ] Show named cells (`content: (header:, body:)`) on a three-column slide.
  The positional form is shorter for the common cases and is what authors reach
  for, but at four consecutive unlabeled brackets it stops being readable, and
  nothing currently points that out at the moment it matters.
