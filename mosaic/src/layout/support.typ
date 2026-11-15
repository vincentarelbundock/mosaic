// Shared content and surface primitives for layout resolvers.
#import "../grid/constructors.typ": make-cell, track
#import "../component/image.typ": image as mosaic-image
#import "core.typ": validate-image
#import "../settings.typ": compact-cell-inset

// Subordinate tiers composed inside a single cell (title subtitle, title
// metadata, section subtitle) pin a muted `fill` so they read as secondary on
// the default surface. That fill must not survive a recolored cell: a
// light-on-dark composition sets one rule on <mosaic-cell-title> and expects
// the whole stack to follow.
#let inherit-fill(styles) = if "fill" in styles {
  let styles = styles
  _ = styles.remove("fill")
  styles
} else {
  styles
}

// Keeps the muted tier muted while the cell still carries the deck's ordinary
// text color, and hands the tier over to the inherited fill as soon as
// anything overrides it. Call inside a `context` block: it reads `text.fill`.
#let adapt-fill(styles, settings) = if text.fill == settings.colors.text {
  styles
} else {
  inherit-fill(styles)
}

#let as-content(value) = if value == none {
  none
} else if type(value) == content {
  value
} else {
  [#value]
}

#let content-or-empty(value) = if value == none { [] } else { as-content(value) }

#let track-children(nodes, tracks) = if tracks == auto {
  nodes
} else {
  nodes.zip(tracks).map(((node, size)) => track(size, node))
}

// The picture a layout places: ready-made content as it stands, or a bare
// path built into an image at the size and fit the composition wants.
#let image-content(
  value,
  name,
  width: auto,
  height: auto,
  fit: "cover",
) = {
  let value = validate-image(value, name)
  if type(value) == content {
    value
  } else {
    mosaic-image(value, width: width, height: height, fit: fit)
  }
}

// Structural fixed-content cell. Typography is not threaded here: the cell's
// <mosaic-cell-ID> label carries it through native show rules.
#let fixed-cell(
  body,
  id,
  settings,
  inset: none,
) = make-cell(
  content: as-content(body),
  id: id,
  style: (
    content-sized: true,
    inset: if inset == none { settings.spacing.compact-gap } else { inset },
  ),
)

// Structural slide-filled cell: the slide supplies its content, and `auto`
// takes the deck's own inset. A compact cell (a header, a footer, marked
// content-sized) hugs its content vertically, so `auto` gives it the compact
// inset instead: full
// inset left and right, `compact-inset` above and below. A user cell in an
// `auto` row track resolves the same way at render time, so a hand-built grid
// draws the same strip as the built-in layout.
#let inset-cell(
  id,
  settings,
  content-sized: false,
  inset: auto,
) = make-cell(
  id: id,
  style: (
    content-sized: content-sized,
    inset: if inset != auto {
      inset
    } else if content-sized {
      compact-cell-inset(settings.spacing)
    } else {
      settings.spacing.inset
    },
  ),
)
