// Private presentation settings and contextual configuration.
#import "shared.typ": fail, require-dictionary, reject-unknown-keys
#import "color-defaults.typ": default-colors
#import "author.typ": analyze-authors

#let merge-record(base, override, name) = {
  require-dictionary(override, name)
  reject-unknown-keys(override, base, name)
  base + override
}

// Geometry the layout modules measure with. Typography is not here: every
// `set` and `show` rule belongs to a theme's `apply`, so the engine holds no
// type scale of its own. Layouts that need the deck's resolved text size read
// it from `settings.base-size`, which `render-slide` captures from the live
// context rather than from any stored default.
#let default-spacing = (
  inset: 1.25em,
  gap: 0.7em,
  compact-gap: 0.35em,
)

// Overflow observation policy. "warn" emits queryable
// <mosaic-overflow-warning> metadata and keeps compiling; "error" emits it and
// fails the compile, so a build stops instead of shipping a clipped slide.
#let overflow-modes = ("off", "warn", "error")

#let default-content = (:)

#let default-deck = (
  title: none,
  subtitle: none,
  authors: (),
  date: none,
)

#let validate-optional-content(value, name) = {
  if value != none and type(value) not in (content, str) {
    fail("setup " + name + " must be content, a string, or none")
  }
}

#let make-deck(
  title: none,
  subtitle: none,
  authors: (),
  date: none,
) = {
  validate-optional-content(title, "title")
  validate-optional-content(subtitle, "subtitle")
  validate-optional-content(date, "date")
  if type(authors) != array {
    fail("setup authors must be an array")
  }
  let _ = analyze-authors(authors, subject: "setup author")
  (title: title, subtitle: subtitle, authors: authors, date: date)
}

#let validate-colors(colors) = {
  if (
    type(colors) != dictionary
      or colors.keys().sorted() != default-colors.keys().sorted()
      or not colors.values().all(value => type(value) == color)
  ) {
    fail("invalid internal presentation colors")
  }
  colors
}

#let resolve-colors(base, overrides) = {
  let base = validate-colors(base)
  if type(overrides) != dictionary {
    fail("setup colors must be a dictionary")
  }
  reject-unknown-keys(overrides, base, "setup colors")
  for (name, value) in overrides {
    if type(value) != color {
      fail("setup colors " + name + " must be a color")
    }
  }
  base + overrides
}

#let make-content-defaults(value) = {
  if type(value) != dictionary {
    fail("setup content must be a dictionary")
  }
  let result = (:)
  for (id, item) in value {
    if id == "" {
      fail("setup content cell id must be non-empty")
    }
    if item != none and type(item) not in (content, str) {
      fail(
        "setup content for " + repr(id)
          + " must be content, a string, or none",
      )
    }
    result.insert(id, if type(item) == str { [#item] } else { item })
  }
  result
}

#let settings-state = state("mosaic:settings", none)

#let make-settings(
  colors: default-colors,
  content: default-content,
  deck: default-deck,
  spacing: (:),
  overflow: "warn",
) = {
  let colors = validate-colors(colors)
  let content = make-content-defaults(content)
  let deck = make-deck(..deck)
  let spacing = merge-record(default-spacing, spacing, "spacing")
  if overflow not in overflow-modes {
    fail("setup overflow must be \"off\", \"warn\", or \"error\"")
  }
  (
    colors: colors,
    content: content,
    deck: deck,
    spacing: spacing,
    overflow: overflow,
  )
}

#let validate-settings(value) = {
  if type(value) != dictionary {
    fail("invalid internal presentation settings")
  }
  let _ = validate-colors(value.at("colors", default: none))
  let content = value.at("content", default: none)
  if type(content) != dictionary {
    fail("invalid internal presentation settings")
  }
  let _ = make-content-defaults(content)
  let deck = value.at("deck", default: none)
  if type(deck) != dictionary or deck.keys().sorted() != default-deck.keys().sorted() {
    fail("invalid internal presentation settings")
  }
  let _ = make-deck(..deck)
  if (
    value.keys().sorted() != ("colors", "content", "deck", "overflow", "spacing")
      or type(value.spacing) != dictionary
      or value.spacing.keys().sorted() != default-spacing.keys().sorted()
      or value.overflow not in overflow-modes
  ) {
    fail("invalid internal presentation settings")
  }
  value
}

#let configure-settings(value) = settings-state.update(validate-settings(value))
