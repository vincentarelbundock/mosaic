// Construction and validation of deferred slide commands.
#import "../shared.typ": tag, fail
#import "../grid/model.typ": plane-ids
#import "../layout/config.typ": selectable-layout-names, validate-layout-value
#import "../layout/core.typ": layout-field-keys

#let slide-command-field-keys = (
  "bodies",
  "content",
  "fields",
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
    if value not in selectable-layout-names {
      fail("slide layout name must be one of " + repr(selectable-layout-names))
    }
    return value
  }
  validate-layout-value(value, "slide layout")
}

// Named arguments on `slide` are layout fields. They only make sense when the
// layout is selected by name, because that is the case where the author has no
// constructor call to put them in: the layout comes from `setup(layouts:)`.
// Passing an explicit layout value means the constructor is right there, and
// routing fields around it would silently skip its normalization.
#let validate-layout-fields(fields, selection) = {
  if fields.len() == 0 {
    return fields
  }
  let name = fields.keys().sorted().first()
  if selection != auto and type(selection) != str {
    fail(
      "slide cannot combine layout fields with an explicit layout value; pass "
        + repr(name) + " to the layout constructor instead",
    )
  }
  let layout-name = if selection == auto { "content" } else { selection }
  let allowed = layout-field-keys.at(layout-name)
  for key in fields.keys() {
    if key not in allowed {
      fail(
        "slide layout " + repr(layout-name) + " has no field " + repr(key)
          + "; expected one of " + repr(allowed),
      )
    }
  }
  fields
}

// `fields` overlays layout fields onto whichever layout the selection
// resolves to, refining the configured layout rather than replacing it. The
// deck compiler uses it for the automatic section tagline; the public `slide`
// fills it from named arguments when the layout is chosen by name.
#let slide-command(
  bodies,
  layout: auto,
  numbered: auto,
  content: (:),
  fields: (:),
) = (
  mosaic: tag,
  kind: "slide",
  layout: layout,
  numbered: numbered,
  content: content,
  fields: fields,
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
/// Any other named argument is a field of the selected layout, so
/// `slide(layout: "title", variant: "academic")` refines the configured title
/// layout instead of replacing it: fields the theme set survive. Layout fields
/// require `layout: auto` or a layout name; with an explicit `m.layouts.*`
/// value, pass them to that constructor instead.
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
  /// Positional cell bodies in depth-first layout order, plus named fields
  /// forwarded to the selected layout.
  /// -> arguments
  ..bodies
) = {
  let named = bodies.named()
  let bodies = bodies.pos()
  // The selection is validated first so an unknown layout name reports itself
  // rather than failing the field lookup that follows.
  let layout = validate-layout-selection(layout)
  let fields = validate-layout-fields(named, layout)
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
    fields: fields,
  ))
}
