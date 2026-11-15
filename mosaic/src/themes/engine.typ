// Private engine that consumes passive theme definitions.
#import "../shared.typ": fail, validate-keys
#import "../settings.typ": resolve-colors
#import "../palettes.typ": light
#import "../setup-core.typ": setup-core, default-setup
#import "../layout/config.typ": standard-layouts, validate-layouts

#let identity(body, colors: (:), options: (:)) = body
#let default-definition = (
  name: "Custom",
  colors: none,
  defaults: (:),
  options: (:),
  layouts: standard-layouts,
  apply: identity,
)
// The theme-neutral option names are exactly what themed setup accepts:
// setup-core's own options plus `colors`, which the engine resolves against
// the theme palette before setup-core runs.
#let generic-options = default-setup.keys() + ("colors",)

#let validate-theme(theme) = {
  if type(theme) != dictionary {
    fail("theme must be a dictionary")
  }
  _ = validate-keys(theme, default-definition, "theme")
  let theme = default-definition + theme
  if type(theme.name) != str or theme.name.trim() == "" {
    fail("theme name must be a non-empty string")
  }
  if theme.colors == none {
    fail("theme requires a complete colors dictionary")
  }
  // Stated here rather than left to `resolve-colors`, whose own failure is an
  // internal-invariant message: a theme author needs the offending key named.
  if type(theme.colors) != dictionary {
    fail("theme colors must be a dictionary")
  }
  _ = validate-keys(theme.colors, light, "theme colors")
  for name in light.keys() {
    if name not in theme.colors {
      fail("theme colors requires " + repr(name))
    }
    if type(theme.colors.at(name)) != color {
      fail("theme colors " + name + " must be a color")
    }
  }
  _ = resolve-colors(theme.colors, (:))
  if type(theme.defaults) != dictionary {
    fail("theme defaults must be a dictionary")
  }
  for reserved in ("layouts", "colors") {
    if reserved in theme.defaults {
      fail(
        "theme defaults must configure " + reserved + " through theme "
          + reserved,
      )
    }
  }
  // Checked after the reserved names, so `layouts` and `colors` keep their
  // more helpful message above.
  _ = validate-keys(theme.defaults, default-setup, "theme defaults")
  if type(theme.options) != dictionary {
    fail("theme options must be a dictionary")
  }
  for key in theme.options.keys() {
    if type(key) != str or key.trim() == "" {
      fail("theme option names must be non-empty strings")
    }
    if key in generic-options {
      fail("theme option " + repr(key) + " conflicts with setup")
    }
  }
  if type(theme.layouts) not in (dictionary, function) {
    fail("theme layouts must be a dictionary or function")
  }
  // The dictionary form is complete at bind time, so it is validated here.
  // The function form depends on the options a deck passes and can only be
  // validated when the deck applies the setup (`resolve-theme-layouts`).
  if type(theme.layouts) == dictionary {
    _ = validate-layouts(theme.layouts, name: "theme layouts")
  }
  if type(theme.apply) != function {
    fail("theme apply must be a function")
  }
  // The signature of `apply` cannot be checked: Typst offers no way to
  // inspect a function's parameters, and a probe call would evaluate the
  // theme's rules, raising its font warnings in every deck that merely
  // imports the theme. A wrong signature therefore still fails natively,
  // where the deck applies the setup.
  theme
}

#let resolve-theme-layouts(theme, options) = {
  let layouts = if type(theme.layouts) == function {
    (theme.layouts)(options)
  } else {
    theme.layouts
  }
  if type(layouts) != dictionary {
    fail("theme layouts must return a dictionary")
  }
  validate-layouts(layouts, name: "theme layouts")
}

// Receives a definition already normalized by `validate-theme`; the public
// extension validates at bind time so a malformed theme fails where it is
// bound, not where the deck applies it. The definition is positional so the
// extension can close over it: a named `theme:` would be one a deck could
// override through `setup.with(theme: ..)`, bypassing validation.
#let theme-setup(theme, body, ..options) = {
  if options.pos().len() > 0 {
    fail(theme.name + " setup accepts only its document body positionally")
  }
  let named = options.named()
  let theme-options = theme.options
  for key in theme.options.keys() {
    if key in named {
      theme-options.insert(key, named.remove(key))
    }
  }
  let layout-overrides = (:)
  if "layouts" in named {
    layout-overrides = validate-layouts(named.remove("layouts"), partial: true)
  }
  // The theme side is validated complete by `resolve-theme-layouts` and the
  // overrides partially just above, so the merge needs no third pass here;
  // `configure-deck` validates the final dictionary once, where it enters the
  // deck record.
  let layouts = resolve-theme-layouts(theme, theme-options) + layout-overrides
  let color-overrides = (:)
  if "colors" in named {
    color-overrides = named.remove("colors")
  }
  let colors = resolve-colors(theme.colors, color-overrides)
  // Spacing and notes are partial records: a deck that overrides one key keeps
  // the theme's value for the others, so they merge one level deep rather than
  // replacing the theme's whole dictionary.
  let setup-options = theme.defaults
  for (key, value) in named {
    let preset = setup-options.at(key, default: none)
    if (
      key in ("spacing", "notes")
        and type(preset) == dictionary
        and type(value) == dictionary
    ) {
      setup-options.insert(key, preset + value)
    } else {
      setup-options.insert(key, value)
    }
  }
  show: setup-core.with(
    setup-options + (layouts: layouts),
    colors: colors,
  )
  // The one typographic statement the engine makes on a theme's behalf: the
  // ink follows the resolved palette, as the canvas already does. Without it
  // a theme that states only `colors` would set black type on a dark canvas.
  // It precedes `apply`, so any theme rule on the text fill overrides it.
  set text(fill: colors.text)
  show: (theme.apply).with(colors: colors, options: theme-options)
  body
}
