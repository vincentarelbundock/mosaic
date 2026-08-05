// Construction and validation of deferred slide commands.
#import "../shared.typ": tag, fail, is-record
#import "../grid/model.typ": plane-ids
#import "../layout/config.typ": selectable-layout-names, validate-layout-value
#import "../layout/core.typ": layout-field-keys

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

// Derived from the constructor so the canonical key set cannot drift from
// the record it describes.
#let slide-command-field-keys = slide-command(()).keys().sorted()

#let is-slide-command(value) = (
  is-record(value, "slide", slide-command-field-keys, "slide command")
)

#let validate-plane(value, name) = {
  if value != none and type(value) != content {
    fail(name + " must be content or none")
  }
  value
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

/// Creates one logical slide command.
///
/// A logical slide is one unit of content, which may render as several physical
/// frames once incremental steps are applied.
///
/// ```typ
/// #mosaic.slide[
///   == Structure
///   Every slide resolves to a grid tree.
/// ]
/// ```
///
/// *Choosing a layout*
///
/// The selection is the one positional subject, so
/// `slide("content", variant: "body")[...]` and
/// `slide(layout: "content", variant: "body")[...]` are the same slide.
///
/// - `auto`: the configured `content` layout. The default.
/// - `"content"`, `"title"`, `"section"`: the matching entry in
///   `setup(layouts:)`. The name also determines numbering and the section
///   lifecycle.
/// - A `mosaic.layouts.*` value: used directly, carrying its own semantic name.
/// - A raw `mosaic.grids.*` tree: used directly and treated as a content layout.
///
/// *Supplying content*
///
/// Use one of the two forms, never both on the same slide:
///
/// - Positional bodies, filling cells in depth-first layout order.
/// - A `content:` dictionary keyed by cell id, which is order-independent and
///   lets a slide skip cells.
///
/// ```typ
/// #mosaic.slide(content: (
///   header: [== Named cells],
///   body: [Order does not matter here.],
/// ))
/// ```
///
/// The reserved `background` and `foreground` keys of `content:` control the
/// full-slide planes rather than a grid cell. Omitting a key inherits the setup
/// default, `none` suppresses it, and content overrides it.
///
/// *Layout fields*
///
/// Any other named argument is a field of the selected layout, so the slide
/// refines the configured layout rather than replacing it, and fields the theme
/// set survive:
///
/// ```typ
/// #mosaic.slide(layout: "title", variant: "academic")
/// ```
///
/// This requires `layout: auto` or a layout name. With an explicit
/// `mosaic.layouts.*` value the constructor is already at hand, so pass the
/// fields to it instead.
///
/// -> content
#let slide(
  /// Which layout resolves this slide: `auto` for the configured content
  /// layout, one of the names `"content"`, `"title"`, `"section"`, or
  /// `"image"`, a `mosaic.layouts.*` value, or a raw `mosaic.grids.*` tree.
  /// Also accepted as the leading positional argument.
  /// -> auto | str | dictionary
  layout: auto,
  /// Whether the slide contributes to logical slide numbering. `auto` numbers
  /// content layouts and leaves title and section layouts unnumbered; an
  /// explicit boolean always wins.
  /// -> auto | bool
  numbered: auto,
  /// Cell content keyed by cell id, plus the reserved `background` and
  /// `foreground` plane keys. Mutually exclusive with positional bodies.
  /// -> dictionary
  content: (:),
  /// Positional cell bodies in depth-first layout order, plus any named
  /// arguments forwarded as fields of the selected layout.
  /// -> arguments
  ..bodies
) = {
  let named = bodies.named()
  let bodies = bodies.pos()
  // A leading string or layout/grid dictionary is the positional layout
  // selection; cell bodies are always content, so the forms cannot collide.
  if bodies.len() > 0 and type(bodies.first()) in (str, dictionary) {
    if layout != auto {
      fail("slide layout given both positionally and as layout:")
    }
    layout = bodies.first()
    bodies = bodies.slice(1)
  }
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
      _ = validate-plane(content.at(name), name)
    }
  }
  let cell-ids = content.keys().filter(key => key not in plane-ids)
  if bodies.len() > 0 and cell-ids.len() > 0 {
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
