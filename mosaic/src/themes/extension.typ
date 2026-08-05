// Stable extension surface for engine-consumed theme definitions.
#import "engine.typ": theme-setup as _theme-setup, validate-theme as _validate-theme
#import "../color-defaults.typ": light-palette
#import "../role-defaults.typ": default-roles as light-roles

/// Binds a passive theme definition to Mosaic's setup engine.
///
/// A theme is data, not code: you describe colors, defaults, and rules in a
/// plain dictionary, and this turns that dictionary into a setup function with
/// the same signature as `mosaic.setup`. The definition is validated here, at
/// binding time, so a malformed theme fails where it is bound.
///
/// ```typ
/// #let starlight = (
///   name: "Starlight",
///   colors: (
///     canvas: rgb("#0b1020"), surface: rgb("#161d33"),
///     text: white, muted: rgb("#9aa4c0"),
///     line: rgb("#2a3350"), accent: rgb("#7cc4ff"),
///   ),
///   defaults: (overflow: "error"),
///   options: (density: "airy"),
///   apply: (body, colors: (:), options: (:)) => {
///     set text(
///       font: "Inter",
///       size: if options.density == "airy" { 30pt } else { 26pt },
///     )
///     show heading: set text(fill: colors.accent)
///     body
///   },
/// )
///
/// #show: mosaic.themes.setup(starlight).with(density: "dense")
/// ```
///
/// *Definition keys*
///
/// Only `colors` is required.
///
/// - `colors`: the complete six-role dictionary, with `canvas`, `surface`,
///   `text`, `muted`, `line`, and `accent`.
/// - `name`: the theme's display name, used in its error messages. Defaults to
///   `"Custom"`.
/// - `defaults`: ordinary `setup` options the theme presets. A deck can still
///   override any of them. Layouts and colors do not belong here; they have
///   their own keys.
/// - `options`: the theme's own options and their defaults. See below.
/// - `layouts`: a complete dictionary of `content`, `title`, and `section`
///   layouts, or a function of the resolved options returning one. Explicit and
///   automatic slides select from the same dictionary. Defaults to the standard
///   layouts.
/// - `apply`: `(body, colors: , options: ) => body`, holding every native show
///   and set rule the theme owns: base typography (`set text(font: ..)`),
///   heading, list, and cell-label rules. The engine has already filled the
///   canvas and set the text fill from the resolved colors, so `apply` states
///   only what the theme changes.
///
/// *Theme options*
///
/// Names declared in `options` become named arguments of the returned setup
/// function. They are consumed before ordinary setup validation and handed to
/// `layouts` and `apply` as the `options` dictionary, so a theme can offer
/// choices Mosaic itself knows nothing about. An option name that collides
/// with a built-in `setup` option is an error. Every other named argument
/// passes through as an ordinary `setup` option.
///
/// -> function
#let setup(
  /// The passive theme definition dictionary described above.
  /// -> dictionary
  theme,
) = _theme-setup.with(theme: _validate-theme(theme))
