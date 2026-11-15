// Stable extension surface for engine-consumed theme definitions.
#import "engine.typ": theme-setup as _theme-setup, validate-theme as _validate-theme
// The one rule a theme cannot state natively: a heading rule that rebuilds the
// heading has to be declared through `decorate-heading`, below, to hold on
// every frame of a slide.
#import "../incremental/heading.typ": decorate-heading as _decorate-heading

/// Turns a passive theme definition into a setup function.
///
/// Two different things are called `setup` here, and the distinction is worth
/// stating plainly. `mosaic.setup` is the document show rule you apply to a
/// deck. `mosaic.themes.setup` sets up nothing on its own: it takes a theme
/// definition and *returns* a show rule of that same kind, with the same
/// signature as `mosaic.setup` plus any options the theme declares. So the
/// usual shape is a facade that names the result once,
///
/// ```typ
/// #let setup = mosaic.themes.setup(definition)
/// ```
///
/// and decks then apply that `setup` exactly as they would a built-in theme's.
/// Applying the result inline works too, as the example below shows.
///
/// A theme is data, not code: you describe colors, defaults, and rules in a
/// plain dictionary. The definition is validated here, where the setup is
/// built, so a malformed theme fails at that line rather than somewhere inside
/// a deck. Two things cannot be checked that early: a `layouts` function,
/// whose result depends on the options a deck passes, and the values a deck
/// gives the theme's own options, which only `apply` knows how to read.
///
/// Every bundled theme facade also exports the `definition` its own `setup`
/// was built from, so `mosaic.themes.default.definition` and friends are the
/// starting points for a variation on a bundled look.
///
/// ```typ
/// #let starlight = (
///   name: "Starlight",
///   colors: (
///     canvas: rgb("#0b1020"), surface: rgb("#161d33"),
///     text: white, muted: rgb("#9aa4c0"),
///     line: rgb("#2a3350"), accent: rgb("#7cc4ff"),
///     warning: rgb("#fbbf24"), error: rgb("#f87171"),
///   ),
///   defaults: (font: "Inter", base-size: 28pt, overflow: "error"),
///   options: (density: "airy"),
///   apply: (body, colors: (:), options: (:)) => {
///     set par(leading: if options.density == "airy" { 0.9em } else { 0.6em })
///     show heading: set text(
///       size: options.base-size * 1.5, fill: colors.accent,
///     )
///     body
///   },
/// )
///
/// #show: mosaic.themes.setup(starlight).with(
///   density: "dense",
///   base-size: 24pt,
/// )
/// ```
///
/// *Definition keys*
///
/// Only `colors` is required.
///
/// - `colors`: the complete palette, one flat dictionary of colors. Six name
///   the deck's own chrome (`canvas`, `surface`, `text`, `muted`, `line`,
///   `accent`) and two name the status colors components paint with
///   (`warning`, `error`). A component's `role:` argument selects
///   one of these by name, so a theme states each color once and every
///   component follows.
/// - `name`: the theme's display name, used in its error messages. Defaults to
///   `"Custom"`.
/// - `defaults`: ordinary `setup` options the theme presets. A deck can still
///   override any of them. This is where a theme states its `font` and
///   `base-size`, which are options of `setup` under every theme. Layouts and
///   colors do not belong here; they have their own keys.
/// - `options`: the theme's own options and their defaults. See below.
/// - `layouts`: a complete dictionary of `content`, `title`, and `section`
///   layouts, or a function of the resolved options returning one. Explicit and
///   automatic slides select from the same dictionary. Defaults to the standard
///   layouts.
/// - `apply`: `(body, colors: , options: ) => body`, holding every native show
///   and set rule the theme owns: heading, list, and cell-label rules. The
///   engine has already filled the canvas and stated the base typography
///   (`set text(fill: .., size: .., font: ..)`) from the resolved colors,
///   `base-size`, and `font`, so `apply` states only what the theme changes.
///
/// *Base typography*
///
/// `font` and `base-size` are deck options, not theme options: `setup(font:
/// .., base-size: ..)` works under every theme, bundled or custom. A theme
/// supplies its own values through `defaults`; one that states neither gets
/// Typst's own font and a 24pt base size. Both reach `apply` and a `layouts`
/// function resolved, as `options.font` and `options.base-size`, next to the
/// theme's own options. State heading sizes as multiples of
/// `options.base-size` rather than in `em`: an em size multiplies with Typst's
/// native per-level heading scale, so the same heading changes size under
/// `set heading(offset: ..)`.
///
/// *Theme options*
///
/// Names declared in `options` become named arguments of the returned setup
/// function. They are consumed before ordinary setup validation and handed to
/// `layouts` and `apply` as the `options` dictionary, so a theme can offer
/// choices Mosaic itself knows nothing about. An option name that collides
/// with a built-in `setup` option, `font` and `base-size` included, is an
/// error. Every other named argument passes through as an ordinary `setup`
/// option.
///
/// -> function
#let setup(
  /// The passive theme definition dictionary described above.
  /// -> dictionary
  theme,
) = {
  let theme = _validate-theme(theme)
  (body, ..options) => _theme-setup(theme, body, ..options)
}

/// Decorates headings with a transforming show rule that survives on every
/// frame of an incremental slide.
///
/// A slide's heading is a real `heading` element on one frame only; the other
/// frames repeat its appearance without the element, so the outline, the
/// bookmarks, and `query(heading)` see one heading per logical slide. Set
/// rules (`show heading: set text(..)`) are captured and replayed
/// automatically. A rule that rebuilds the heading (`show heading: it => ..`)
/// cannot be, because nothing on a continuation frame matches it. Declare such
/// a rule through this function instead and it is applied on every frame. It
/// is used as a show rule, in a deck or in a theme's `apply`:
///
/// ```typ
/// #show: mosaic.themes.decorate-heading.with(depth: 2, it => block(width: 100%)[
///   #it
///   #line(length: 2em)
/// ])
/// ```
///
/// `decorate` receives the heading on the canonical frame and a block standing
/// in for it on the others, so it must treat its argument as opaque content to
/// place, not as an element whose fields it reads.
///
/// *Which headings*
///
/// With neither `depth` nor `level` the rule applies to every heading. `depth`
/// is the number of `=` signs the heading was written with, which is what
/// decides whether it opens a slide; `level` is the native level it resolves
/// to, which differs from the depth under `set heading(offset: ..)`. Give
/// `depth: 2` for the heading that titles a content slide. Several rules nest
/// as native show rules do, the one declared last outermost.
///
/// -> content
#let decorate-heading(
  /// The transformation, called with the heading or its stand-in.
  /// -> function
  decorate,
  /// The native heading level the rule applies to, or `none` for every level.
  /// -> none | int
  level: none,
  /// The source depth the rule applies to (`==` is depth 2), or `none` for
  /// every depth. This is what the deck compiler classifies slides by, and it
  /// differs from `level` under `set heading(offset: ..)`, so a rule meant
  /// for the heading that opens a slide selects by depth.
  /// -> none | int
  depth: none,
  /// The content the rule is in force for; supplied by `show:`.
  /// -> content
  body,
) = _decorate-heading(decorate, level: level, depth: depth, body)
