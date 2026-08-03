// Documentation-only signature model for the engine-owned Light setup.
// Runtime ownership lives in Light's passive definition and theme-engine.typ;
// the Light facade binds them directly.

/// Applies Mosaic's presentation defaults and compiles headings and slide
/// commands into pages.
///
/// Use this as a document-wide show rule: `#show: mosaic.setup`.
/// Deck title information is written to Typst's standard document metadata,
/// stored in Mosaic's rendering settings, and emitted as one queryable
/// `<mosaic-deck-metadata>` record. Setup never creates a title slide; use
/// `mosaic.slide(layout: "title")` to inherit and render the configured values.
/// `colors` is a partial semantic override layered over the active facade.
///
/// -> content
#let setup(
  /// The document body captured by the show rule.
  /// -> content
  body,
  /// Slide aspect ratio. Available values are `16-9` and `4-3`.
  /// -> str
  paper: "16-9",
  /// Canonical deck title. Title layouts inherit it when their `title` is `auto`.
  /// -> content | str | none
  title: none,
  /// Canonical deck subtitle. Title layouts inherit it when their `subtitle` is `auto`.
  /// -> content | str | none
  subtitle: none,
  /// Canonical author records created with `layouts.author`.
  /// -> array
  authors: (),
  /// Canonical display date. Title layouts inherit it when their `date` is `auto`.
  /// -> content | str | none
  date: none,
  /// Partial semantic color overrides. Accepted roles are `canvas`, `surface`,
  /// `text`, `muted`, `line`, and `accent`; omitted roles retain theme defaults.
  /// -> dictionary
  colors: (:),
  /// Partial fallback content keyed by cell ID. The reserved `background` and
  /// `foreground` IDs configure the inherited slide planes. A slide's explicit
  /// content overrides these values; `none` suppresses a configured default.
  /// Other defaults targeting cells absent from a resolved grid are ignored.
  /// -> dictionary
  content: (:),
  /// Insets and gaps used throughout the presentation.
  /// -> dictionary
  spacing: (:),
  /// Cell overflow policy: `"warn"` or `"off"`.
  /// -> str
  overflow: "warn",
  /// Partial named-layout overrides. Accepted keys are `content`, `title`, and
  /// `section`; omitted names retain the active theme's layouts. Each value may
  /// be a deferred `mosaic.layouts.*` value or a low-level grid tree.
  /// `content` is the ordinary slide layout, distinct from the `content:` option
  /// above, which supplies inherited named-cell and plane content.
  /// -> dictionary
  layouts: (:),
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
) = none
