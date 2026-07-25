// Construction, validation, and resolution of the default template.
#import "shared.typ": fail
#import "grid-model.typ": styled-cell, h, v, t, valid-track-size
#import "template-core.typ": make-grid
#import "template-support.typ": region-surface, track-children
#import "components.typ": progress as progress-component

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
      "template \"default\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  let columns = fields.columns
  if type(columns) != int or columns < 1 {
    fail("template \"default\" columns must be a positive integer")
  }
  let tracks = fields.tracks
  if tracks != auto and (
    type(tracks) != array
      or tracks.len() != columns
      or not tracks.all(valid-track-size)
  ) {
    fail(
      "template \"default\" tracks must be auto or an array of "
        + str(columns) + " native Typst track sizes",
    )
  }
  let inverted = fields.inverted
  if type(inverted) != array or inverted.any(
    region => type(region) != str or region not in ("header", "footer"),
  ) {
    fail(
      "template \"default\" inverted must be an array containing "
        + "only \"header\" and \"footer\"",
    )
  }
  let progress = fields.progress
  if progress != none and (
    type(progress) != str
      or progress not in ("1/1", "1", "circle", "line")
  ) {
    fail(
      "template \"default\" progress must be none, \"1/1\", \"1\", "
        + "\"circle\", or \"line\"",
    )
  }
  let regions = ("header", "body", "footer")
  for name in ("fill", "background", "text", "align", "inset") {
    let value = fields.at(name)
    if type(value) != dictionary {
      fail("template \"default\" " + name + " must be a dictionary")
    }
    let unknown = value.keys().filter(key => key not in regions)
    if unknown.len() > 0 {
      fail(
        "template \"default\" " + name + " has unknown "
          + if unknown.len() == 1 { "region " } else { "regions " }
          + unknown.map(repr).join(", "),
      )
    }
  }
  for (region, value) in fields.text {
    if type(value) != dictionary {
      fail(
        "template \"default\" text style for region "
          + repr(region) + " must be a dictionary",
      )
    }
  }
  for (region, value) in fields.background {
    if value != none and type(value) != content {
      fail(
        "template \"default\" background for region "
          + repr(region) + " must be content or none",
      )
    }
  }
  fields
}

/// Creates a conventional header, body, and footer grid recipe.
///
/// The `variant` selects `body`, `header-body`, `body-footer`, or the default
/// `header-body-footer` structure. The surrounding `mosaic.slide` supplies
/// content in that region order, with one body block per requested column. The
/// template resolves to a vertical Mosaic split whose body child is a
/// horizontal split of ordinary cells.
/// Regional fills and backgrounds are supplied in dictionaries keyed by
/// `header`, `body`, or `footer`. Fill values are native Typst fills;
/// backgrounds are explicit Typst content such as `image(...)`.
/// Regional text, alignment, and inset dictionaries use the same keys. The
/// header cell has no special typography; put a native level-two heading in its
/// content to style it as a heading and register it with outlines.
/// List `header`, `footer`, or both in `inverted` to fill those regions with
/// the inherited scheme's `text` color and set their text to `inverse-text`.
/// Explicit regional `fill` and `text` values override these inherited
/// defaults.
/// Set `progress` to `1/1`, `1`, `circle`, or `line` to place a progress
/// indicator on the slide foreground. Its color, scale, and placement follow
/// the active slide colors and footer styling. Use `none` to omit it.
/// Automatic level-two heading slides use this template with one body column
/// and place the heading in `header`.
///
/// - variant (str): `body`, `header-body`, `body-footer`, or `header-body-footer`.
/// - columns (int): Number of body columns and required body blocks.
/// - tracks (auto | array): Native Typst tracks for the body columns.
/// - inverted (array): Header and footer regions whose colors are inverted from the inherited scheme.
/// - progress (none | str): Foreground progress treatment: `1/1`, `1`, `circle`, `line`, or `none`.
/// - fill (dictionary): Regional fills keyed by `header`, `body`, or `footer`.
/// - background (dictionary): Regional background content keyed by `header`, `body`, or `footer`.
/// - text (dictionary): Regional Typst text styles keyed by `header`, `body`, or `footer`.
/// - align (dictionary): Regional native Typst alignments.
/// - inset (dictionary): Regional native Typst insets.
/// Pass the returned grid to `mosaic.slide`; content blocks fill `header`,
/// `body` (or `body-1`, `body-2`, and so on), and `footer` in traversal order.
///
/// -> dictionary
#let default(
  variant: "header-body-footer",
  columns: 1,
  tracks: auto,
  fill: (:),
  background: (:),
  text: (:),
  align: (:),
  inset: (:),
  inverted: (),
  progress: none,
) = {
  let fields = validate-fields((
    variant: variant,
    columns: columns,
    tracks: tracks,
    fill: fill,
    background: background,
    text: text,
    align: align,
    inset: inset,
    inverted: inverted,
    progress: progress,
  ))
  make-grid("default", fields)
}

#let compact-region-insets(settings) = (
  top: settings.spacing.compact-gap,
  right: settings.spacing.inset,
  bottom: settings.spacing.compact-gap,
  left: settings.spacing.inset,
)

#let footer-insets(fields, settings) = fields.inset.at(
  "footer",
  default: compact-region-insets(settings),
)

#let inset-side(value, side, fallback) = if type(value) == dictionary {
  value.at(
    side,
    default: value.at(
      if side in ("left", "right") { "x" } else { "y" },
      default: fallback,
    ),
  )
} else {
  value
}

/// Resolves the default template's optional progress indicator as foreground.
///
/// -> content | none
#let progress-foreground(command, settings) = {
  let fields = validate-fields(command.fields)
  if fields.progress == none {
    return none
  }
  let has-footer = fields.variant in ("body-footer", "header-body-footer")
  let inverted = has-footer and "footer" in fields.inverted
  let footer-text = settings.type.small + (
    if inverted { (fill: settings.colors.inverse-text) } else { (:) }
  ) + fields.text.at("footer", default: (:))
  let explicit-fill = fields.text.at("footer", default: (:)).at(
    "fill",
    default: none,
  )
  let active = if explicit-fill != none {
    explicit-fill
  } else if inverted {
    settings.colors.inverse-text
  } else {
    settings.colors.accent
  }
  let track = if inverted {
    settings.colors.inverse-text.transparentize(72%)
  } else {
    settings.colors.line
  }
  let insets = if has-footer {
    footer-insets(fields, settings)
  } else {
    settings.spacing.inset
  }
  let right-inset = inset-side(insets, "right", settings.spacing.inset)
  let bottom-inset = inset-side(
    insets,
    "bottom",
    settings.spacing.compact-gap,
  )
  let indicator = text(
    ..footer-text,
    progress-component(
      variant: fields.progress,
      size: 1em,
      thickness: 0.12em,
      color: active,
      track: track,
    ),
  )

  if fields.progress == "line" {
    place(bottom + left, block(width: 100%, indicator))
  } else {
    place(
      bottom + right,
      dx: -right-inset,
      dy: -bottom-inset,
      indicator,
    )
  }
}

#let region-cell(
  id,
  fields,
  settings,
  region: none,
  content-sized: false,
) = {
  let region = if region == none { id } else { region }
  let is-footer = region == "footer"
  let is-edge-region = region in ("header", "footer")
  let is-inverted = region in fields.inverted
  styled-cell(
    id: id,
    style: (
      content-sized: content-sized,
      inset: fields.inset.at(region, default: if is-edge-region {
        compact-region-insets(settings)
      } else {
        settings.spacing.inset
      }),
      align: fields.align.at(
        region,
        default: if region == "body" { left + top } else { left + horizon },
      ),
      // Body regions carry no text delta so ambient `set text` (font, size,
      // fill) flows through; only the footer's smaller role and inverted
      // fills are explicit. Per-region `fields.text` still wins.
      text: (if is-footer { settings.type.small } else { (:) })
        + if is-inverted {
          (fill: settings.colors.inverse-text)
        } else {
          (:)
        }
        + fields.text.at(region, default: (:)),
    ) + region-surface(
      fields.fill.at(
        region,
        default: if is-inverted { settings.colors.text } else { auto },
      ),
      fields.background.at(region, default: none),
      settings,
    ),
  )
}

#let shell(body, fields, settings) = {
  let children = ()
  if fields.variant in ("header-body", "header-body-footer") {
    children.push(t(
      auto,
      region-cell("header", fields, settings, content-sized: true),
    ))
  }
  children.push(t(1fr, body))
  if fields.variant in ("body-footer", "header-body-footer") {
    children.push(t(
      auto,
      region-cell("footer", fields, settings, content-sized: true),
    ))
  }
  v(..children)
}

#let resolve-default(command, settings) = {
  let fields = validate-fields(command.fields)
  let body-cells = range(fields.columns).map(index => region-cell(
    if fields.columns == 1 { "body" } else { "body-" + str(index + 1) },
    fields,
    settings,
    region: "body",
  ))
  let body = h(
    gutter: settings.spacing.gap,
    ..track-children(body-cells, fields.tracks),
  )
  shell(body, fields, settings)
}
