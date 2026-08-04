// Private engine that consumes passive theme definitions.
#import "../shared.typ": fail, reject-unknown-keys
#import "../settings.typ": resolve-colors
#import "../setup-core.typ": setup-core, setup-defaults
#import "../layout/config.typ": standard-layouts, validate-layouts

#let identity(body, colors: (:), options: (:)) = body
#let definition-defaults = (
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
#let generic-options = setup-defaults.keys() + ("colors",)

#let validate-theme(theme) = {
  if type(theme) != dictionary {
    fail("theme must be a dictionary")
  }
  reject-unknown-keys(theme, definition-defaults, "theme")
  let theme = definition-defaults + theme
  if type(theme.name) != str or theme.name.trim() == "" {
    fail("theme name must be a non-empty string")
  }
  if theme.colors == none {
    fail("theme requires a complete colors dictionary")
  }
  let _ = resolve-colors(theme.colors, (:))
  if type(theme.defaults) != dictionary {
    fail("theme defaults must be a dictionary")
  }
  if "layouts" in theme.defaults {
    fail("theme defaults must configure layouts through theme layouts")
  }
  if "colors" in theme.defaults {
    fail("theme defaults must configure colors through theme colors")
  }
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
  if type(theme.apply) != function {
    fail("theme apply must be a function")
  }
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
  validate-layouts(layouts, subject: "theme layouts")
}

// Receives a definition already normalized by `validate-theme`; the public
// extension validates at bind time so a malformed theme fails where it is
// bound, not where the deck applies it.
#let theme-setup(body, theme: none, ..options) = {
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
  let layouts = validate-layouts(
    resolve-theme-layouts(theme, theme-options) + layout-overrides,
  )
  let color-overrides = (:)
  if "colors" in named {
    color-overrides = named.remove("colors")
  }
  let colors = resolve-colors(theme.colors, color-overrides)
  show: setup-core.with(theme.defaults + named + (layouts: layouts), colors: colors)
  show: (theme.apply).with(colors: colors, options: theme-options)
  body
}
