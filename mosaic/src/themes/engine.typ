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
  text: (:),
  normalize-lists: true,
  layouts: standard-layouts,
  apply: identity,
)
// The theme-neutral option names are exactly what `setup` accepts, so they are
// derived rather than restated: a new setup option cannot go missing here.
#let generic-options = setup-defaults.keys()

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
  if type(theme.text) not in (dictionary, function) {
    fail("theme text must be a dictionary or function")
  }
  if type(theme.normalize-lists) != bool {
    fail("theme normalize-lists must be a boolean")
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

#let normalize-lists(body) = {
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  body
}

#let apply-theme(body, theme: (:), colors: (:), options: (:)) = {
  if theme.normalize-lists {
    show: normalize-lists
  }
  let text-style = if type(theme.text) == function {
    (theme.text)(options)
  } else {
    theme.text
  }
  if type(text-style) != dictionary {
    fail("theme text must return a dictionary")
  }
  set page(fill: colors.canvas)
  set text(..(text-style + (fill: colors.text)))
  show: (theme.apply).with(colors: colors, options: options)
  body
}

#let theme-setup(body, theme: none, ..options) = {
  let theme = validate-theme(theme)
  if options.pos().len() > 0 {
    fail(theme.name + " setup accepts only its document body positionally")
  }
  let named = options.named()
  let theme-options = theme.options
  for key in theme.options.keys() {
    if key in named {
      theme-options.insert(key, named.at(key))
      let _ = named.remove(key)
    }
  }
  let layout-overrides = named.at("layouts", default: (:))
  if "layouts" in named {
    let _ = named.remove("layouts")
  }
  let _ = validate-layouts(layout-overrides, partial: true)
  let layouts = validate-layouts(
    resolve-theme-layouts(theme, theme-options) + layout-overrides,
  )
  let configured = theme.defaults + named + (layouts: layouts)
  let colors = resolve-colors(
    theme.colors,
    configured.at("colors", default: (:)),
  )
  if "colors" in configured {
    let _ = configured.remove("colors")
  }
  show: setup-core.with(configured, colors: colors)
  show: apply-theme.with(
    theme: theme,
    colors: colors,
    options: theme-options,
  )
  body
}
