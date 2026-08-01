// Construction, validation, and resolution of the table layout.
#import "grid-model.typ": styled-cell, v, t
#import "layout-core.typ": make-grid, validate-role
#import "layout-support.typ": fixed-cell

#let validate-fields(fields) = {
  let _ = validate-role(fields)
  fields
}

/// Creates a table-focused grid around a slide-supplied native table.
#let table(
  title: none,
  caption: none,
  source: none,
  highlight: none,
  role: "accent",
) = {
  let fields = validate-fields((
    title: title,
    caption: caption,
    source: source,
    highlight: highlight,
    role: role,
  ))
  make-grid("table", fields)
}

#let resolve-table(command, settings) = {
  let fields = validate-fields(command.fields)
  let children = ()
  if fields.title != none {
    children.push(t(
      auto,
      fixed-cell(
        fields.title,
        "table-title",
        settings,
        inset: settings.spacing.inset,
      ),
    ))
  }
  children.push(t(
    1fr,
    styled-cell(
      id: "table",
      // Inherit ambient text so the deck's font/size flow into the table body.
      style: (
        inset: settings.spacing.inset,
      ),
    ),
  ))
  // Typography for these canonical cells comes from the label rules in
  // `setup` (<mosaic-cell-highlight>, <mosaic-cell-caption>,
  // <mosaic-cell-source>).
  for (name, body) in (
    ("highlight", fields.highlight),
    ("caption", fields.caption),
    ("source", fields.source),
  ) {
    if body != none {
      children.push(t(
        auto,
        fixed-cell(body, name, settings),
      ))
    }
  }
  v(gutter: settings.spacing.compact-gap, ..children)
}
