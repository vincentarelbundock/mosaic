// Documentation-only signature model for the engine-owned Light setup.
// Runtime ownership lives in Light's passive definition and theme-engine.typ;
// the Light facade binds them directly.

/// Applies Mosaic's presentation defaults and compiles headings and slide
/// commands into pages.
///
/// Install it as a document-wide show rule. Everything after it is presentation
/// source: level-two headings become slides, and `mosaic.slide` commands become
/// slides.
///
/// ```typ
/// #import "@local/mosaic:0.0.1" as mosaic
/// #show: mosaic.setup.with(
///   title: [Tree-based slide grids],
///   authors: (mosaic.layouts.author("Ada Lovelace"),),
///   date: [2026-08-03],
/// )
///
/// #mosaic.slide(layout: "title")
///
/// == First slide
/// Body content.
/// ```
///
/// *Deck metadata*
///
/// `title`, `subtitle`, `authors`, and `date` are the deck's canonical
/// identity. They are written to Typst's standard document metadata, stored in
/// Mosaic's rendering settings, and emitted as one queryable
/// `<mosaic-deck-metadata>` record. Setup never creates a title slide by
/// itself; `mosaic.slide(layout: "title")` inherits these values wherever the
/// title layout's own field is `auto`.
///
/// *Partial overrides*
///
/// `colors`, `cells`, `spacing`, and `layouts` are all partial: keys you omit
/// keep the active theme's value rather than reverting to a bare default. That
/// is what lets a deck adjust one accent color or one layout without restating
/// the theme.
///
/// *Themes*
///
/// This is the Light facade's setup. A themed facade such as
/// `mosaic.themes.dark` exposes the same signature with different defaults, and
/// may add its own options on top. See `theme.setup` for binding a custom
/// theme definition.
///
/// -> content
#let setup(
  /// The document body captured by the show rule.
  /// -> content
  body,
  /// Slide aspect ratio.
  ///
  /// - `"16-9"`: widescreen, the default.
  /// - `"4-3"`: traditional projector.
  /// -> str
  paper: "16-9",
  /// Canonical deck title. Title layouts inherit it when their `title` is
  /// `auto`.
  /// -> content | str | none
  title: none,
  /// Canonical deck subtitle. Title layouts inherit it when their `subtitle` is
  /// `auto`.
  /// -> content | str | none
  subtitle: none,
  /// Canonical author records, each created with `layouts.author`. Title
  /// layouts inherit the array when their own `authors` is `auto`.
  ///
  /// ```typ
  /// authors: (
  ///   mosaic.layouts.author(
  ///     "Ada Lovelace",
  ///     affiliations: ("Analytical Society",),
  ///     email: "ada@example.org",
  ///     corresponding: true,
  ///   ),
  /// )
  /// ```
  /// -> array
  authors: (),
  /// Canonical display date. Title layouts inherit it when their `date` is
  /// `auto`.
  /// -> content | str | none
  date: none,
  /// Partial semantic color overrides layered over the active theme. Omitted
  /// roles keep the theme's value.
  ///
  /// - `canvas`: the slide page behind everything else.
  /// - `surface`: raised panels, such as component frames and callouts.
  /// - `text`: ordinary body text.
  /// - `muted`: subtitles, captions, and other fine print.
  /// - `line`: rules, borders, and other drawn separators.
  /// - `accent`: the deck's one emphatic color.
  ///
  /// ```typ
  /// colors: (accent: rgb("#0072B2"))
  /// ```
  /// -> dictionary
  colors: (:),
  /// Partial fallback content keyed by cell ID, used whenever a slide leaves
  /// that cell empty. Every key names a grid cell, for example `footer` or
  /// `body`; the full-slide planes have their own options below.
  ///
  /// A slide's explicit content overrides these values, and `none` on the slide
  /// suppresses a configured default. Defaults targeting cells absent from a
  /// resolved grid are ignored, so one footer default is safe across layouts
  /// that have no footer.
  ///
  /// ```typ
  /// cells: (footer: align(right, mosaic.components.progress()))
  /// ```
  /// -> dictionary
  cells: (:),
  /// The deck's background plane, drawn behind the grid on every slide. A slide
  /// inherits it unless it passes its own `background:`, or `none` to suppress
  /// it. The plane takes no space away from the grid.
  ///
  /// ```typ
  /// background: mosaic.components.image(path("paper.webp"))
  /// ```
  /// -> content | str | none
  background: none,
  /// The deck's foreground plane, drawn over the grid on every slide. Ordinary
  /// home for a logo, a slide number, or a progress indicator.
  ///
  /// ```typ
  /// foreground: place(bottom + right, mosaic.components.progress())
  /// ```
  /// -> content | str | none
  foreground: none,
  /// Partial overrides for the grid geometry the layouts measure with.
  /// Omitted keys keep the theme's value.
  ///
  /// - `inset`: padding inside a cell, default `1.25em`.
  /// - `gap`: space between grid regions, default `0.7em`.
  /// - `compact-gap`: the tighter space inside stacked metadata, default
  ///   `0.35em`.
  ///
  /// Typographic rhythm is not here. Heading spacing and list spacing are
  /// ordinary `show` and `set` rules owned by the theme, so change them with
  /// native rules after `setup` or in your own theme's `apply`.
  /// -> dictionary
  spacing: (:),
  /// What to do when a cell's content is taller than the cell.
  ///
  /// - `"warn"`: emit queryable `<mosaic-overflow-warning>` metadata and keep
  ///   compiling. The default.
  /// - `"error"`: emit the same metadata and fail the compile, so a build stops
  ///   rather than shipping a clipped slide.
  /// - `"off"`: observe nothing.
  /// -> str
  overflow: "warn",
  /// Partial named-layout overrides. Omitted names keep the active theme's
  /// layout.
  ///
  /// - `content`: the ordinary slide layout, also used by automatic
  ///   level-two-heading slides.
  /// - `title`: used by `slide(layout: "title")`.
  /// - `section`: used by `slide(layout: "section")` and by automatic level-one
  ///   heading slides.
  ///
  /// Each value is either a deferred `mosaic.layouts.*` value or a low-level
  /// `mosaic.grids.*` tree. Note that this option is distinct from the
  /// `cells:` option above, which supplies inherited cell content rather than
  /// structure.
  ///
  /// ```typ
  /// layouts: (
  ///   content: mosaic.layouts.content(variant: "header-body", columns: 2),
  /// )
  /// ```
  /// -> dictionary
  layouts: (:),
  /// Whether to emit only the final frame of each logical slide, collapsing
  /// every incremental reveal into one page for printing.
  /// -> bool
  handout: false,
  /// Which document to render.
  ///
  /// - `"slides"`: the presentation itself.
  /// - `"speaker"`: each frame above the notes that apply to it.
  /// - `"notes"`: the notes alone, without the slide image.
  /// -> str
  output: "slides",
  /// Counters restored to their pre-slide values before each continuation
  /// frame, so content repeated across the frames of one logical slide advances
  /// them once rather than once per frame.
  ///
  /// ```typ
  /// frozen-counters: (counter(figure.where(kind: image)),)
  /// ```
  /// -> array
  frozen-counters: (),
  /// States restored to their pre-slide values before each continuation frame,
  /// the `state` counterpart of `frozen-counters`.
  /// -> array
  frozen-states: (),
) = none
