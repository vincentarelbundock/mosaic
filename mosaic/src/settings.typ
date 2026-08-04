// Private presentation settings and contextual configuration.
#import "shared.typ": fail, require-dictionary, reject-unknown-keys
#import "color-defaults.typ": default-colors, default-line
#import "role-defaults.typ": validate-roles
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

// Geometry and paint for the printed `speaker` and `notes` outputs.
//
// These pages are paper, not slide canvas: the page keeps its default white
// fill and the slide appears as a painted thumbnail inside it. The defaults are
// therefore chosen to read against paper rather than against the deck's own
// palette, which is why the text paints black even for a dark theme. A deck
// printing on tinted stock overrides the fills; a deck on a different paper
// size overrides the margin and gaps.
//
// `padding` is the slack held back below the notes block so a full page does
// not butt against the bottom margin. The available note height is the region
// minus the thumbnail, the heading, and every gap named here, so these fields
// are the whole vertical budget: no unnamed allowance is folded in.
#let default-notes = (
  margin: 15mm,
  text-size: 10pt,
  text-fill: black,
  heading-size: 12pt,
  heading-weight: "bold",
  heading-fill: black,
  thumbnail-stroke: 0.6pt + default-line,
  note-gap: 3mm,
  thumbnail-gap: 7mm,
  heading-gap: 4mm,
  padding: 2mm,
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
  notes: (:),
  roles: auto,
  overflow: "warn",
) = {
  let colors = validate-colors(colors)
  let roles = validate-roles(roles)
  let content = make-content-defaults(content)
  let deck = make-deck(..deck)
  let spacing = merge-record(default-spacing, spacing, "spacing")
  let notes = merge-record(default-notes, notes, "notes")
  if overflow not in overflow-modes {
    fail("setup overflow must be \"off\", \"warn\", or \"error\"")
  }
  (
    colors: colors,
    content: content,
    deck: deck,
    spacing: spacing,
    notes: notes,
    roles: roles,
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
    value.keys().sorted() != (
      "colors", "content", "deck", "notes", "overflow", "roles", "spacing",
    )
      or type(value.spacing) != dictionary
      or value.spacing.keys().sorted() != default-spacing.keys().sorted()
      or type(value.notes) != dictionary
      or value.notes.keys().sorted() != default-notes.keys().sorted()
      or validate-roles(value.roles) != value.roles
      or value.overflow not in overflow-modes
  ) {
    fail("invalid internal presentation settings")
  }
  value
}

#let configure-settings(value) = settings-state.update(validate-settings(value))
