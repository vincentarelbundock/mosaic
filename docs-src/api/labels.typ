#set document(title: [Labels])
#metadata((title: "Labels")) <website-metadata>

#title()

Every part of a rendered slide carries a Typst label, and those labels are the whole styling surface. A deck reaches them with ordinary `show` rules, and a theme's `apply` reaches the same ones. This page is the complete inventory.

Two kinds of rules cover a labeled region, split by what they touch. Properties of the content *inside* it pass through as ordinary `set` rules. Properties of its own block, its fill, stroke, and corner radius, are `set block` rules on the same label. The #link("../appearance/styling.html")[styling] page explains that split in full.

= Cells

Each cell of a slide is a single block labeled with its own id.

#table(
  columns: (auto, 1fr),
  [`mosaic-cell-ID`], [Any cell, by the id its layout or grid gave it. This is the general form; the entries below are the ids the built-in layouts produce.],
  [`mosaic-cell-header`], [The header of a content slide.],
  [`mosaic-cell-body`], [The body of a content slide, and the default cell for slide content with no layout.],
  [`mosaic-cell-footer`], [The footer of a content slide, and the usual home for a progress indicator.],
  [`mosaic-cell-title`], [The title stack of a title slide.],
  [`mosaic-cell-authors`], [The author block of a title slide.],
  [`mosaic-cell-details`], [The date and other fine print of a title slide.],
  [`mosaic-cell-section`], [The heading of a section slide.],
  [`mosaic-cell-image`], [The image cell of an image layout.],
)

A theme is expected to style at least `mosaic-cell-title`, `mosaic-cell-section`, and the content cells it uses. A theme that omits one renders that region in the engine's bare defaults, and nothing warns about it.

= Composed tiers

The `title` and `section` layouts are compositions rather than bare grids. Each text tier they emit carries its own label, so a rule reaches it without knowing how the variant is assembled.

#table(
  columns: (auto, 1fr),
  [`mosaic-title-display`], [The display line of a title slide, inside `mosaic-cell-title`. This is where a theme states the title's display size and tracking.],
  [`mosaic-section-number`], [The section numeral of a section slide.],
  [`mosaic-section-title`], [The section's title text.],
  [`mosaic-section-subtitle`], [The section's subtitle, where the variant emits one.],
)

Typography goes through these labels. Geometry does not: the spacers, rules, and offsets a variant composes itself from are produced during layout and no show rule reaches inside them. A size, weight, or color is always a label rule; an arrangement is the variant's design.

= Whole slide and planes

#table(
  columns: (auto, 1fr),
  [`mosaic-slide`], [The entire cell grid of one slide. One rule here reaches every cell at once, which is what light text over a photograph wants. A `mosaic-cell-*` rule still refines it.],
  [`mosaic-background`], [The full-slide plane behind the grid.],
  [`mosaic-foreground`], [The full-slide plane in front of the grid.],
)

= Engine-owned labels

These carry rules from Mosaic itself rather than from a theme. A theme or deck rule on the same label overrides them, but the defaults are deliberate.

#table(
  columns: (auto, 1fr),
  [`mosaic-note-heading`], [The heading on a printed speaker or notes page. Set black on white, because those pages are paper whatever the deck's theme does.],
  [`mosaic-note-body`], [The note text on those same pages. Inherits the deck's base text size.],
  [`mosaic-overflow-warning`], [The diagnostic emitted when content exceeds its cell. Not a styling target.],
)
