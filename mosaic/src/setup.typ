// Sane presentation defaults, applied as a document-wide show rule.
#import "slide-runtime.typ": configure-deck
#import "deck-compiler.typ": compile-deck
#import "grid-model.typ": styled-cell
#import "settings.typ": make-settings, configure-settings
#import "shared.typ": fail

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
  /// Presentation color roles used by Mosaic layouts and furniture. Pass
  /// `mosaic.color.scheme(name)` for a complete named scheme, or a dictionary
  /// to override selected roles.
  /// -> dictionary
  colors: (:),
  /// Insets and gaps used throughout the presentation.
  /// -> dictionary
  spacing: (:),
  /// Optional slide furniture and presentation behavior.
  /// -> dictionary
  features: (:),
  /// Whether to emit only the final frame of each logical slide.
  /// -> bool
  handout: false,
  /// Counters restored to their pre-slide values before each continuation
  /// frame, so repeated semantic content advances them once per logical slide.
  /// -> array
  frozen-counters: (),
  /// States restored to their pre-slide values before each continuation frame.
  /// -> array
  frozen-states: (),
  /// Constructor for automatic level-2 (`==`) heading slides. By default each
  /// `==` slide is built with `layouts.default(variant: "header-body")`, the
  /// heading in the header and the following content in the body. Pass a
  /// function to route those slides through your own layout instead, so a deck
  /// can write `== Title` markup yet get the same furniture, colors, and grid
  /// as its explicit slides.
  ///
  /// The function receives two positional content arguments — the heading and
  /// the accumulated body — and must return a `mosaic.slide(...)` command:
  ///
  /// ```typ
  /// #let framed(title, body) = m.slide(
  ///   grid: m.layouts.default(variant: "header-body", inverted: ("header",)),
  /// )[#title][#body]
  /// #show: m.setup.with(auto-slide: framed)
  /// ```
  ///
  /// The returned slide may use any grid, not only header-body: a single body
  /// cell that merges title and content, an image layout, or a custom cell
  /// tree are all valid. The only structural rule is Mosaic's usual one — the
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
  let settings = make-settings(
    colors: colors,
    spacing: spacing,
    features: features,
  )
  set page(
    paper: paper-presets.at(paper),
    margin: 0pt,
    fill: settings.colors.canvas,
  )
  set text-element(..settings.type.body)
  show heading-element.where(depth: 1): set text-element(..settings.type.title)
  show heading-element.where(depth: 2): set text-element(..settings.type.heading)
  show figure.caption: set text-element(..settings.type.caption)
  show heading-element: set block(below: settings.spacing.heading-below)
  set list(spacing: settings.spacing.list-spacing)
  set enum(spacing: settings.spacing.list-spacing)
  set terms(spacing: settings.spacing.list-spacing)
  configure-settings(settings)
  configure-deck(
    default-grid: styled-cell(
      id: "body",
      style: (inset: settings.spacing.inset),
    ),
    frozen-counters: frozen-counters,
    frozen-states: frozen-states,
    handout: handout,
  )
  compile-deck(
    body,
    section-grid: styled-cell(id: "section", style: (
      inset: settings.spacing.inset,
      align: center + horizon,
      text: settings.type.title,
    )),
    auto-slide: auto-slide,
  )
}
