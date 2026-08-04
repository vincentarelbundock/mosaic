// Construction, validation, and resolution of the content layout.
#import "../shared.typ": fail
#import "../grid/constructors.typ": styled-cell, h, v, t, validate-fit
#import "../grid/model.typ": valid-track-size
#import "core.typ": make-layout
#import "support.typ": track-children

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
/// This is the ordinary slide layout, and the one automatic level-two headings
/// resolve to. It builds a vertical Mosaic split whose body child is a
/// horizontal split of plain cells.
///
/// ```typ
/// #mosaic.slide(
///   layout: mosaic.layouts.content(variant: "header-body", columns: 2),
///   [== Two columns],
///   [Left body],
///   [Right body],
/// )
/// ```
///
/// *Cells*
///
/// The surrounding `mosaic.slide` fills cells in traversal order:
///
/// - `header`, when the variant includes one.
/// - `body`, or `body-1`, `body-2`, and so on when `columns` is above one.
/// - `footer`, when the variant includes one.
///
/// A setup-level `content: (footer: ...)` default can satisfy the footer, so a
/// positional slide may omit that final block.
///
/// *Variants*
///
/// - `body`: one region, edge to edge.
/// - `header-body`: a content-sized header above the body.
/// - `body-footer`: the body above a content-sized footer.
/// - `header-body-footer`: both. The default.
///
/// *Styling*
///
/// The layout is purely structural. Resolved cells are labeled
/// `<mosaic-cell-header>`, `<mosaic-cell-body>` (or `<mosaic-cell-body-1>`,
/// `<mosaic-cell-body-2>`, and so on), and `<mosaic-cell-footer>`, so
/// appearance comes from native Typst rules.
///
/// ```typ
/// #show label("mosaic-cell-header"): mosaic.surface(fill: luma(240))
/// ```
///
/// The header cell carries no special typography of its own. Put a native
/// level-two heading in its content to style it as a heading and register it
/// with outlines.
///
/// -> dictionary
#let content(
  /// Structural arrangement: `body`, `header-body`, `body-footer`, or
  /// `header-body-footer`.
  /// -> str
  variant: "header-body-footer",
  /// Number of body columns, and therefore the number of body blocks the slide
  /// must supply. Must be a positive integer.
  /// -> int
  columns: 1,
  /// Native Typst track sizes for the body columns, one per column. `auto`
  /// splits the body evenly.
  ///
  /// ```typ
  /// mosaic.layouts.content(columns: 2, tracks: (2fr, 1fr))
  /// ```
  /// -> auto | array
  tracks: auto,
  /// Shrinks body content that would otherwise overflow its column instead of
  /// letting it spill.
  ///
  /// - `none`: leave content at its natural size, so overflow observation
  ///   reports it instead. The default.
  /// - `"width"`: scale to the column width.
  /// - `"contain"`: scale to the body height.
  /// - `"auto"`: scale to the height and reflow at the smaller size.
  ///
  /// This applies to the body columns only. The header and footer sit in `auto`
  /// tracks sized to their own content, so there is no allocation for them to
  /// shrink into.
  /// -> none | str
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

#let region-cell(
  id,
  settings,
  content-sized: false,
  fit: none,
) = styled-cell(
  id: id,
  style: (
    content-sized: content-sized,
    inset: settings.spacing.inset,
  ) + if fit == none { (:) } else { (fit: fit) },
)

#let shell(body, fields, settings) = {
  let children = ()
  if fields.variant in ("header-body", "header-body-footer") {
    children.push(t(
      auto,
      region-cell("header", settings, content-sized: true),
    ))
  }
  children.push(t(1fr, body))
  if fields.variant in ("body-footer", "header-body-footer") {
    children.push(t(
      auto,
      region-cell("footer", settings, content-sized: true),
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
