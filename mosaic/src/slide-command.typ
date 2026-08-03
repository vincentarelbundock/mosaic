// Construction and validation of deferred slide commands.
#import "shared.typ": tag, fail
#import "grid-model.typ": plane-ids
#import "layout-config.typ": layout-names, validate-layout-value

#let slide-command-field-keys = (
  "bodies",
  "content",
  "kind",
  "layout",
  "mosaic",
  "numbered",
)

#let is-slide-command(value) = {
  if (
    type(value) != content
      or value.func() != metadata
      or type(value.value) != dictionary
      or value.value.at("mosaic", default: none) != tag
      or value.value.at("kind", default: none) != "slide"
  ) {
    return false
  }
  if value.value.keys().sorted() != slide-command-field-keys {
    fail("invalid slide command record")
  }
  true
}

#let validate-plane(value, name) = {
  if value != none and type(value) != content {
    fail(name + " must be content or none")
  }
}

#let validate-layout-selection(value) = {
  if value == auto {
    return value
  }
  if type(value) == str {
    if value not in layout-names {
      fail("slide layout name must be \"content\", \"title\", or \"section\"")
    }
    return value
  }
  validate-layout-value(value, "slide layout")
}

#let slide-command(
  bodies,
  layout: auto,
  numbered: auto,
  content: (:),
) = (
  mosaic: tag,
  kind: "slide",
  layout: layout,
  numbered: numbered,
  content: content,
  bodies: bodies,
)

/// Creates one logical slide command.
///
/// `layout: auto` selects the configured `content` layout. The strings
/// `"content"`, `"title"`, and `"section"` select the corresponding entry in
/// `setup(layouts:)` and determine numbering and section lifecycle. A direct
/// `m.layouts.*` value carries its own semantic layout name; a raw `m.grid.*`
/// tree is treated as a content layout.
///
/// Content may be supplied either as positional bodies or as one `content:`
/// dictionary keyed by cell id. Do not mix the two forms. The reserved
/// `background` and `foreground` keys control the full-slide planes: absent
/// inherits setup content, `none` suppresses it, and content overrides it.
///
/// The default `numbered: auto` numbers content layouts and leaves title and
/// section layouts unnumbered. An explicit boolean always wins.
///
/// -> content
#let slide(
  /// Configured layout name, semantic layout, raw grid, or `auto` for content.
  /// -> auto | str | dictionary
  layout: auto,
  /// Whether the slide contributes to logical slide numbering.
  /// -> auto | bool
  numbered: auto,
  /// Named cell and plane content.
  /// -> dictionary
  content: (:),
  /// Positional cell bodies in depth-first layout order.
  /// -> arguments
  ..bodies
) = {
  if bodies.named().len() > 0 {
    let name = bodies.named().keys().sorted().first()
    fail("slide does not accept named argument " + repr(name))
  }
  let bodies = bodies.pos()
  let layout = validate-layout-selection(layout)
  if numbered != auto and type(numbered) != bool {
    fail("slide numbered must be auto or a boolean")
  }
  if type(content) != dictionary {
    fail("slide content must be a dictionary")
  }
  for name in plane-ids {
    if name in content {
      validate-plane(content.at(name), name)
    }
  }
  let cell-keys = content.keys().filter(key => key not in plane-ids)
  if bodies.len() > 0 and cell-keys.len() > 0 {
    fail("slide cannot combine named and positional cell content")
  }
  metadata(slide-command(
    bodies,
    layout: layout,
    numbered: numbered,
    content: content,
  ))
}
