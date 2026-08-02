// Construction and validation of deferred slide commands.
#import "shared.typ": tag, fail
#import "grid-model.typ": is-node, validate, plane-ids
#import "layout-core.typ": is-layout-grid
#import "layout-default.typ": default

#let slide-command-field-keys = (
  "bodies",
  "content",
  "grid",
  "kind",
  "mosaic",
  "numbered",
  "section",
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

#let validate-deck-config(default-grid, background, foreground) = {
  validate(default-grid)
  validate-plane(background, "background")
  validate-plane(foreground, "foreground")
}

#let slide-command(
  bodies,
  grid: auto,
  numbered: true,
  section: false,
  content: (:),
) = (
  mosaic: tag,
  kind: "slide",
  grid: grid,
  numbered: numbered,
  section: section,
  content: content,
  bodies: bodies,
)

/// Creates a logical slide command.
///
/// The grid may be passed through `grid` or as the first positional
/// argument. Positional content blocks fill its cells.
///
/// -> content
#let slide(
  /// Grid tree or `auto` to inherit the deck default.
  /// -> auto | dictionary
  grid: auto,
  /// Whether the slide contributes to logical slide numbering.
  /// -> bool
  numbered: true,
  /// Whether a custom slide layout represents a semantic section divider.
  /// Slides using `layouts.section()` are marked automatically.
  /// -> bool
  section: false,
  /// Content assigned by ID: a dictionary mapping each content-bearing cell's
  /// ID to its content, plus the reserved plane IDs `background` and
  /// `foreground`. This is the recommended form for custom grids with more
  /// than one supplied cell, because assignment no longer depends on the
  /// grid's traversal order. Every content-bearing cell must have an entry;
  /// entries targeting an unknown or fixed-content cell are errors. The plane
  /// entries are optional overrides of the deck planes: content replaces the
  /// inherited plane for this slide and `none` omits it. Cell entries cannot
  /// be combined with positional bodies; plane entries can. Leave cell
  /// entries out to use positional content.
  /// -> dictionary
  content: (:),
  /// Cell bodies, optionally preceded by a positional grid. A terse
  /// alternative to cell entries in `content:`; the bodies fill
  /// content-bearing cells in the grid's depth-first declaration order.
  /// -> arguments
  ..bodies
) = {
  if type(numbered) != bool {
    fail("numbered must be a boolean")
  }
  if type(section) != bool {
    fail("section must be a boolean")
  }
  if type(content) != dictionary {
    fail("slide content must be a dictionary")
  }
  for key in plane-ids {
    if key in content {
      validate-plane(content.at(key), key)
    }
  }
  let named-bodies = bodies.named()
  if named-bodies.len() > 0 {
    let name = named-bodies.keys().sorted().first()
    fail("slide does not accept named argument " + repr(name))
  }
  let bodies = bodies.pos()
  let positional-grid = if (
    bodies.len() > 0
      and (
        is-node(bodies.first())
          or is-layout-grid(bodies.first())
      )
  ) {
    bodies.remove(0)
  } else {
    none
  }
  if positional-grid != none and grid != auto {
    fail("slide cannot combine a positional grid tree with the grid parameter")
  }
  let cell-keys = content.keys().filter(key => key not in plane-ids)
  if cell-keys.len() > 0 and bodies.len() > 0 {
    fail("slide cannot combine named and positional cell content")
  }
  let requested-grid = if positional-grid != none {
    positional-grid
  } else {
    grid
  }
  metadata(slide-command(
    bodies,
    grid: requested-grid,
    numbered: numbered,
    section: section,
    content: content,
  ))
}
#let automatic-slide-command(title, body) = {
  slide-command(
    (),
    grid: default(variant: "header-body"),
    content: (header: title, body: body),
  )
}
