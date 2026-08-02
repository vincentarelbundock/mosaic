// Construction, validation, and resolution of the default layout.
#import "shared.typ": fail
#import "grid-model.typ": styled-cell, h, v, t, valid-track-size
#import "layout-core.typ": make-grid, validate-accent
#import "layout-support.typ": track-children
#import "components.typ": progress as progress-component
#import "color-defaults.typ": default-accent, default-line

#let variants = (
  "body",
  "header-body",
  "body-footer",
  "header-body-footer",
)

#let validate-fields(fields) = {
  validate-accent(fields, "default")
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "layout \"default\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  let columns = fields.columns
  if type(columns) != int or columns < 1 {
    fail("layout \"default\" columns must be a positive integer")
  }
  let tracks = fields.tracks
  if tracks != auto and (
    type(tracks) != array
      or tracks.len() != columns
      or not tracks.all(valid-track-size)
  ) {
    fail(
      "layout \"default\" tracks must be auto or an array of "
        + str(columns) + " native Typst track sizes",
    )
  }
  let progress = fields.progress
  if progress != none and (
    type(progress) != str
      or progress not in ("1/1", "1", "circle", "line")
  ) {
    fail(
      "layout \"default\" progress must be none, \"1/1\", \"1\", "
        + "\"circle\", or \"line\"",
    )
  }
  fields
}

/// Creates a conventional header, body, and footer grid recipe.
///
/// The `variant` selects `body`, `header-body`, `body-footer`, or the default
/// `header-body-footer` structure. The surrounding `mosaic.slide` supplies
/// content in that cell order, with one body block per requested column.
/// The layout resolves to a vertical Mosaic split whose body child is a
/// horizontal split of ordinary cells.
///
/// The layout is purely structural. Each resolved cell is labeled
/// `<mosaic-cell-header>`, `<mosaic-cell-body>` (or `<mosaic-cell-body-1>`,
/// `<mosaic-cell-body-2>`, ...), and `<mosaic-cell-footer>`, so appearance is
/// supplied with native Typst rules, for example
/// `show label("mosaic-cell-header"): it => block(fill: ..., it)`.
/// The header cell has no special typography; put a native level-two heading
/// in its content to style it as a heading and register it with outlines.
/// Use `"1/1"`, `"1"`, `"circle"`, or `"line"` to place a progress
/// indicator on the slide foreground. `accent` colors the active decoration;
/// use `none` to omit it.
/// Automatic level-two heading slides use this layout with one body column
/// and place the heading in `header`.
///
/// - variant (str): `body`, `header-body`, `body-footer`, or `header-body-footer`.
/// - columns (int): Number of body columns and required body blocks.
/// - tracks (auto | array): Native Typst tracks for the body columns.
/// - progress (none | str): Foreground progress treatment: `1/1`, `1`, `circle`, `line`, or `none`.
/// Pass the returned grid to `mosaic.slide`; content blocks fill `header`,
/// `body` (or `body-1`, `body-2`, and so on), and `footer` in traversal order.
///
/// -> dictionary
#let default(
  variant: "header-body-footer",
  columns: 1,
  tracks: auto,
  progress: none,
  /// Color used by optional progress decoration.
  /// -> color
  accent: default-accent,
) = {
  let fields = validate-fields((
    variant: variant,
    columns: columns,
    tracks: tracks,
    progress: progress,
    accent: accent,
  ))
  make-grid("default", fields)
}

#let compact-region-insets(settings) = (
  top: settings.spacing.compact-gap,
  right: settings.spacing.inset,
  bottom: settings.spacing.compact-gap,
  left: settings.spacing.inset,
)

/// Resolves the default layout's optional progress indicator as foreground.
///
/// -> content | none
#let progress-foreground(command, settings) = {
  let fields = validate-fields(command.fields)
  if fields.progress == none {
    return none
  }
  let indicator = text(
    ..settings.type.small,
    progress-component(
      variant: fields.progress,
      size: 1em,
      thickness: 0.12em,
      color: fields.accent,
      track: default-line,
    ),
  )
  if fields.progress == "line" {
    place(bottom + left, block(width: 100%, indicator))
  } else {
    place(
      bottom + right,
      dx: -settings.spacing.inset,
      dy: -settings.spacing.compact-gap,
      indicator,
    )
  }
}

#let region-cell(
  id,
  settings,
  edge: false,
  content-sized: false,
) = styled-cell(
  id: id,
  style: (
    content-sized: content-sized,
    inset: if edge {
      compact-region-insets(settings)
    } else {
      settings.spacing.inset
    },
  ),
)

#let shell(body, fields, settings) = {
  let children = ()
  if fields.variant in ("header-body", "header-body-footer") {
    children.push(t(
      auto,
      region-cell("header", settings, edge: true, content-sized: true),
    ))
  }
  children.push(t(1fr, body))
  if fields.variant in ("body-footer", "header-body-footer") {
    children.push(t(
      auto,
      region-cell("footer", settings, edge: true, content-sized: true),
    ))
  }
  v(..children)
}

#let resolve-default(command, settings) = {
  let fields = validate-fields(command.fields)
  let body-cells = range(fields.columns).map(index => region-cell(
    if fields.columns == 1 { "body" } else { "body-" + str(index + 1) },
    settings,
  ))
  let body = h(
    gutter: settings.spacing.gap,
    ..track-children(body-cells, fields.tracks),
  )
  shell(body, fields, settings)
}
