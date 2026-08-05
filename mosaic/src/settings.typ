// Constructors and validation for the settings half of the deck record.
//
// Everything here is a pure value: `setup` builds one settings dictionary,
// validates it, and stores it inside the single deck record (deck-state.typ).
// Nothing in this module holds state of its own.
//
// Two of these fields, `colors` and `roles`, are Mosaic's one sanctioned
// semantic token layer. Components are ordinary functions, and Typst's rule
// system offers no channel that could carry paint values (surface fills,
// accent rails) into a function call the way `set text` carries typography
// into text. A palette record is therefore unavoidable; keeping it to six
// deck colors plus the role palette, both declared at `setup`, is the
// containment. Everything typographic stays out of this module by design:
// every `set` and `show` rule a slide renders with belongs to the active
// theme's `apply`.
#import "shared.typ": fail, validate-dictionary, validate-keys
#import "color-defaults.typ": default-colors, default-line
#import "role-defaults.typ": validate-roles
#import "author.typ": analyze-authors

#let merge-record(base, override, name) = {
  _ = validate-dictionary(override, name)
  _ = validate-keys(override, base, name)
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

// Geometry for the printed `speaker` and `notes` outputs. Geometry only: the
// heading and note text on these pages render under the <mosaic-note-heading>
// and <mosaic-note-body> labels, and their typography is stated as `show`
// rules (neutral engine defaults in setup-core, overridable with ordinary
// rules after `setup`), not as fields here.
//
// These pages are paper, not slide canvas: the page keeps its default white
// fill and the slide appears as a painted thumbnail inside it. A deck on a
// different paper size overrides the margin and gaps.
//
// `bottom-gap` is the slack held back below the notes block so a full page does
// not butt against the bottom margin. The available note height is the region
// minus the thumbnail, the heading, and every gap named here, so these fields
// are the whole vertical budget: no unnamed allowance is folded in.
#let default-notes = (
  margin: 15mm,
  thumbnail-stroke: 0.6pt + default-line,
  note-gap: 3mm,
  thumbnail-gap: 7mm,
  heading-gap: 4mm,
  bottom-gap: 2mm,
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
  value
}

#let make-deck(
  title: none,
  subtitle: none,
  authors: (),
  date: none,
) = {
  let title = validate-optional-content(title, "title")
  let subtitle = validate-optional-content(subtitle, "subtitle")
  let date = validate-optional-content(date, "date")
  if type(authors) != array {
    fail("setup authors must be an array")
  }
  _ = analyze-authors(authors, name: "setup author")
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
  _ = validate-keys(overrides, base, "setup colors")
  for (name, value) in overrides {
    if type(value) != color {
      fail("setup colors " + name + " must be a color")
    }
  }
  base + overrides
}

#let validate-content(value) = {
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
  let content = validate-content(content)
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

// A shape check, not a re-proof: `make-settings` is the only constructor of a
// settings record and validates every field as it builds one, and the record is
// written into the deck state exactly once and never mutated. Re-validating
// field contents here would repeat work that just happened in the same call
// stack (including the author and ORCID checks inside `make-deck`), so this
// confirms only that the value is that record.
#let validate-settings(value) = {
  if (
    type(value) != dictionary
      or value.keys().sorted() != (
        "colors", "content", "deck", "notes", "overflow", "roles", "spacing",
      )
  ) {
    fail("invalid internal presentation settings")
  }
  value
}
