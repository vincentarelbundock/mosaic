// Construction and validation of deferred deck and slide commands.
#import "shared.typ": tag, fail
#import "grid-model.typ": cell, is-node, validate, validate-cell-styles
#import "template-core.typ": is-template-grid
#import "template-default.typ": default

#let command-field-keys = (
  deck: ("background", "default-grid", "foreground", "kind", "mosaic"),
  slide: (
    "background",
    "bodies",
    "cell-styles",
    "colors",
    "foreground",
    "grid",
    "kind",
    "mosaic",
    "numbered",
    "section",
  ),
)

#let is-command(value, kind) = {
  if (
    type(value) != content
      or value.func() != metadata
      or type(value.value) != dictionary
      or value.value.at("mosaic", default: none) != tag
      or value.value.at("kind", default: none) != kind
  ) {
    return false
  }
  if value.value.keys().sorted() != command-field-keys.at(kind) {
    fail("invalid " + kind + " command record")
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

/// Changes the grid and visual planes inherited by following slides.
///
/// -> content
#let deck(
  /// Default Mosaic grid tree.
  /// -> dictionary
  default-grid: cell(id: "body"),
  /// Default page background content, or `none`.
  /// -> content | none
  background: none,
  /// Default page foreground content, or `none`.
  /// -> content | none
  foreground: none,
) = {
  validate-deck-config(default-grid, background, foreground)
  metadata((
    mosaic: tag,
    kind: "deck",
    default-grid: default-grid,
    background: background,
    foreground: foreground,
  ))
}

#let slide-command(
  bodies,
  grid: auto,
  background: auto,
  foreground: auto,
  colors: auto,
  numbered: true,
  section: false,
  cell-styles: (:),
) = (
  mosaic: tag,
  kind: "slide",
  grid: grid,
  background: background,
  foreground: foreground,
  colors: colors,
  numbered: numbered,
  section: section,
  cell-styles: cell-styles,
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
  /// Visual overrides keyed by resolved cell ID.
  /// Accepts `fill`, `inset`, `align`, `text`, `stroke`, `radius`,
  /// `background`, and `fit`. Template defaults are applied first; text
  /// dictionaries merge deeply. Unknown IDs fail after grid resolution.
  /// -> dictionary
  cell-styles: (:),
  /// Slide background override.
  /// -> auto | content | none
  background: auto,
  /// Slide foreground override.
  /// -> auto | content | none
  foreground: auto,
  /// Slide color-role overrides, or `auto` to inherit presentation colors.
  /// Pass a complete value from `mosaic.color.scheme(...)` or a partial
  /// dictionary such as `(accent: red)`.
  /// -> auto | dictionary
  colors: auto,
  /// Whether the slide contributes to logical slide numbering.
  /// -> bool
  numbered: true,
  /// Whether a custom slide layout represents a semantic section divider.
  /// Slides using `templates.section()` are marked automatically.
  /// -> bool
  section: false,
  /// Cell bodies, optionally preceded by a positional grid.
  /// -> arguments
  ..bodies
) = {
  if type(numbered) != bool {
    fail("numbered must be a boolean")
  }
  if type(section) != bool {
    fail("section must be a boolean")
  }
  let cell-styles = validate-cell-styles(cell-styles)
  let bodies = bodies.pos()
  let positional-grid = if (
    bodies.len() > 0
      and (
        is-node(bodies.first())
          or is-template-grid(bodies.first())
      )
  ) {
    bodies.remove(0)
  } else {
    none
  }
  if positional-grid != none and grid != auto {
    fail("slide cannot combine a positional grid tree with the grid parameter")
  }
  let requested-grid = if positional-grid != none {
    positional-grid
  } else {
    grid
  }
  metadata(slide-command(
    bodies,
    grid: requested-grid,
    background: background,
    foreground: foreground,
    colors: colors,
    numbered: numbered,
    section: section,
    cell-styles: cell-styles,
  ))
}
#let automatic-slide-command(title, body) = {
  slide-command(
    (title, body),
    grid: default(variant: "header-body"),
  )
}
