// Sane presentation defaults, applied as a document-wide show rule.
#import "slide-runtime.typ": configure-deck
#import "deck-compiler.typ": compile-deck
#import "grid-model.typ": styled-cell
#import "settings.typ": make-settings, configure-settings
#import "shared.typ": fail
#import "color-defaults.typ": default-canvas

#let text-element = text
#let heading-element = heading

/// Applies Mosaic's presentation defaults and compiles headings and slide
/// commands into pages.
///
/// Use this as a document-wide show rule: `#show: mosaic.setup`.
///
/// -> content
#let setup(
  /// The document body captured by the show rule.
  /// -> content
  body,
  /// Slide aspect ratio. Available values are `16-9` and `4-3`.
  /// -> str
  paper: "16-9",
  /// Insets and gaps used throughout the presentation.
  /// -> dictionary
  spacing: (:),
  /// Optional slide furniture and presentation behavior.
  /// -> dictionary
  features: (:),
  /// Grid inherited by slides whose `grid` is `auto`.
  /// `auto` uses Mosaic's single body cell with the configured inset.
  /// -> auto | dictionary
  default-grid: auto,
  /// Grid used by level-1 (`=`) section slides.
  /// `auto` uses Mosaic's centered section cell.
  /// -> auto | dictionary
  section-grid: auto,
  /// Background inherited by following slides.
  /// -> content | none
  background: none,
  /// Foreground inherited by following slides.
  /// -> content | none
  foreground: none,
  /// Whether to emit only the final frame of each logical slide.
  /// -> bool
  handout: false,
  /// Output document. `"slides"` renders the presentation, `"speaker"`
  /// renders each frame above its applicable notes, and `"notes"` renders
  /// notes without the slide image.
  /// -> str
  output: "slides",
  /// Counters restored to their pre-slide values before each continuation
  /// frame, so repeated semantic content advances them once per logical slide.
  /// -> array
  frozen-counters: (),
  /// States restored to their pre-slide values before each continuation frame.
  /// -> array
  frozen-states: (),
  /// Constructor for level-2 (`==`) heading slides. By default each
  /// heading slide is built with `layouts.default(variant: "header-body")`, the
  /// heading in the header and the following content in the body. Pass a
  /// function to route those slides through your own layout instead, so a deck
  /// can write `== Title` markup yet get the same furniture, appearance, and
  /// grid as its explicit slides.
  ///
  /// The function receives two positional content arguments, the heading and
  /// the accumulated body, and must return a `mosaic.slide(...)` command:
  ///
  /// ```typ
  /// #let framed(title, body) = m.slide(
  ///   grid: m.layouts.default(variant: "header-body", accent: teal),
  /// )[#title][#body]
  /// #show: m.setup.with(auto-slide: framed)
  /// ```
  ///
  /// The returned slide may use any grid, not only header-body: a single body
  /// cell that merges title and content, an image layout, or a custom cell
  /// tree are all valid. The only structural rule is Mosaic's usual one: the
  /// grid must accept as many body blocks as the function passes it. Constraints
  /// are reported as `mosaic:` errors, except a parameter-count mismatch, which
  /// surfaces as Typst's generic "unexpected/missing argument" (Typst exposes no
  /// way to introspect a function's arity). `none` keeps the built-in slide.
  /// -> function | none
  auto-slide: none,
) = {
  let paper-presets = (
    "16-9": "presentation-16-9",
    "4-3": "presentation-4-3",
  )
  if type(paper) != str or paper not in paper-presets {
    fail("setup paper must be \"16-9\" or \"4-3\"")
  }
  if auto-slide != none and type(auto-slide) != function {
    fail("setup auto-slide must be a function or none")
  }
  if output not in ("slides", "speaker", "notes") {
    fail("setup output must be \"slides\", \"speaker\", or \"notes\"")
  }
  let settings = make-settings(
    spacing: spacing,
    features: features,
  )
  let page-options = if output == "slides" {
    (
      paper: paper-presets.at(paper),
      margin: 0pt,
      fill: default-canvas,
    )
  } else {
    (
      paper: "a4",
      margin: 15mm,
      fill: white,
    )
  }
  set page(..page-options)
  set text-element(..settings.type.body)
  show heading-element.where(depth: 1): set text-element(..settings.type.title)
  show heading-element.where(depth: 2): set text-element(..settings.type.heading)
  show figure.caption: set text-element(..settings.type.caption)
  show heading-element: set block(below: settings.spacing.heading-below)
  set list(spacing: settings.spacing.list-spacing)
  set enum(spacing: settings.spacing.list-spacing)
  set terms(spacing: settings.spacing.list-spacing)
  // Canonical cell typography and arrangement. Every rendered cell is one
  // block labeled <mosaic-cell-ID>, so defaults for the canonical cell
  // vocabulary are ordinary label-targeted rules. Rules defined later (in a
  // themed setup, rules after `#show: setup`, or rules scoped around one
  // slide command) sit inside these and therefore win.
  show label("mosaic-cell-section"): set align(center + horizon)
  show label("mosaic-cell-section"): set text-element(..settings.type.title)
  show label("mosaic-cell-footer"): set text-element(..settings.type.small)
  show label("mosaic-cell-title"): set text-element(
    ..(settings.type.title + (size: 2em, tracking: -0.015em)),
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-authors"): set text-element(
    size: 0.8em,
    weight: "medium",
  )
  show label("mosaic-cell-details"): set text-element(..settings.type.small)
  configure-settings(settings)
  let default-grid = if default-grid == auto {
    styled-cell(
      id: "body",
      style: (inset: settings.spacing.inset),
    )
  } else {
    default-grid
  }
  let section-grid = if section-grid == auto {
    styled-cell(id: "section", style: (
      fit: "width",
      inset: settings.spacing.inset,
    ))
  } else {
    section-grid
  }
  configure-deck(
    default-grid: default-grid,
    background: background,
    foreground: foreground,
    frozen-counters: frozen-counters,
    frozen-states: frozen-states,
    handout: handout,
    output: output,
    paper: paper,
  )
  compile-deck(
    body,
    section-grid: section-grid,
    auto-slide: auto-slide,
  )
}
