// Construction, validation, and resolution of the table layout.
#import "grid-model.typ": styled-cell, v, t
#import "layout-core.typ": make-grid, validate-role
#import "layout-support.typ": fixed-text-cell

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
      fixed-text-cell(
        fields.title,
        "title",
        settings,
        settings.type.heading + (fill: settings.colors.text),
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
        align: left + top,
      ),
    ),
  ))
  for (name, body, text-style) in (
    ("highlight", fields.highlight, settings.type.small + (fill: settings.colors.accent)),
    ("caption", fields.caption, settings.type.caption),
    ("source", fields.source, settings.type.small),
  ) {
    if body != none {
      children.push(t(
        auto,
        fixed-text-cell(body, name, settings, text-style),
      ))
    }
  }
  v(gutter: settings.spacing.compact-gap, ..children)
}
