// Construction, validation, and resolution of the content layout.
#import "shared.typ": fail
#import "grid-model.typ": styled-cell, h, v, t, valid-track-size, validate-fit
#import "layout-core.typ": make-layout
#import "layout-support.typ": track-children

#let variants = (
  "body",
  "header-body",
  "body-footer",
  "header-body-footer",
)

#let validate-fields(fields) = {
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "layout \"content\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  let columns = fields.columns
  if type(columns) != int or columns < 1 {
    fail("layout \"content\" columns must be a positive integer")
  }
  let tracks = fields.tracks
  if tracks != auto and (
    type(tracks) != array
      or tracks.len() != columns
      or not tracks.all(valid-track-size)
  ) {
    fail(
      "layout \"content\" tracks must be auto or an array of "
        + str(columns) + " native Typst track sizes",
    )
  }
  let _ = validate-fit(fields.fit, "layout \"content\"")
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
/// The built-in content layout uses one body column. Automatic
/// level-two headings supply its `header` and `body` cells.
///
/// `fit` shrinks body content that would otherwise overflow its column instead
/// of letting it spill: `"contain"` scales to the body height, `"auto"` scales
/// and reflows at the smaller size, and `"width"` scales to the column width.
/// It applies to the body columns only, since the header and footer sit in
/// `auto` tracks sized to their own content. The default `none` leaves content
/// at its natural size, where overflow observation reports it instead.
///
/// - variant (str): `body`, `header-body`, `body-footer`, or `header-body-footer`.
/// - columns (int): Number of body columns and required body blocks.
/// - tracks (auto | array): Native Typst tracks for the body columns.
/// - fit (none | str): Body shrink-to-fit mode: `none`, `"width"`, `"contain"`, or `"auto"`.
/// Pass the returned layout to `mosaic.slide`; content blocks fill `header`,
/// `body` (or `body-1`, `body-2`, and so on), and `footer` in traversal order.
/// A setup-level `content.footer` default may satisfy the footer so a positional
/// slide can omit that final body.
///
/// -> dictionary
#let content(
  variant: "header-body-footer",
  columns: 1,
  tracks: auto,
  fit: none,
) = {
  let fields = validate-fields((
    variant: variant,
    columns: columns,
    tracks: tracks,
    fit: fit,
  ))
  make-layout("content", fields)
}

#let compact-region-insets(settings) = (
  top: settings.spacing.compact-gap,
  right: settings.spacing.inset,
  bottom: settings.spacing.compact-gap,
  left: settings.spacing.inset,
)


#let region-cell(
  id,
  settings,
  edge: false,
  content-sized: false,
  fit: none,
) = styled-cell(
  id: id,
  style: (
    content-sized: content-sized,
    inset: if edge {
      compact-region-insets(settings)
    } else {
      settings.spacing.inset
    },
  ) + if fit == none { (:) } else { (fit: fit) },
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

#let resolve-content-layout(command, settings) = {
  let fields = validate-fields(command.fields)
  // `fit` applies to the body columns only. The header and footer sit in
  // `auto` tracks sized to their own content, so there is no allocation for
  // them to shrink into.
  let body-cells = range(fields.columns).map(index => region-cell(
    if fields.columns == 1 { "body" } else { "body-" + str(index + 1) },
    settings,
    fit: fields.fit,
  ))
  let body = h(
    gutter: settings.spacing.gap,
    ..track-children(body-cells, fields.tracks),
  )
  shell(body, fields, settings)
}
