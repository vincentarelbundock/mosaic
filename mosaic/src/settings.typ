// Private presentation settings and contextual configuration.
#import "shared.typ": fail, require-dictionary, reject-unknown-keys
#import "color-defaults.typ": default-text, default-muted, default-colors
#import "author.typ": analyze-authors

#let merge-record(base, override, name) = {
  require-dictionary(override, name)
  reject-unknown-keys(override, base, name)
  base + override
}

#let default-type = (
  body: (
    font: (
      "Inter",
      "Source Sans 3",
      "Liberation Sans",
      "DejaVu Sans",
      "Libertinus Serif",
    ),
    fallback: true,
    size: 28pt,
    fill: default-text,
  ),
  title: (size: 2em, weight: "semibold"),
  subtitle: (size: 1.05em, fill: default-muted),
  heading: (size: 1.4em, weight: "semibold"),
  caption: (size: 0.72em, fill: default-muted),
  small: (size: 0.55em, fill: default-muted),
)

#let default-spacing = (
  inset: 1.25em,
  gap: 0.7em,
  compact-gap: 0.35em,
  heading-below: 0.75em,
  list-spacing: 0.8em,
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
    type: default-type + (
      body: default-type.body + (fill: colors.text,),
      subtitle: default-type.subtitle + (fill: colors.muted,),
      caption: default-type.caption + (fill: colors.muted,),
      small: default-type.small + (fill: colors.muted,),
    ),
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
    value.keys().sorted() != ("colors", "content", "deck", "overflow", "spacing", "type")
      or type(value.type) != dictionary
      or value.type.keys().sorted() != default-type.keys().sorted()
      or not value.type.values().all(item => type(item) == dictionary)
      or type(value.spacing) != dictionary
      or value.spacing.keys().sorted() != default-spacing.keys().sorted()
      or value.overflow not in overflow-modes
  ) {
    fail("invalid internal presentation settings")
  }
  value
}

#let configure-settings(value) = settings-state.update(validate-settings(value))
