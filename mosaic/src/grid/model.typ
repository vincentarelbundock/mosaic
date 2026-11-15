// Canonical grid values and node predicates.
#import "../shared.typ": tag

#let plane-ids = ("background", "foreground")

// Fitting is internal: the section layouts scale content they generate
// themselves, whose size no author can predict. Authors scale an oversized
// block of their own with native `scale(.., reflow: true)`.
#let fit-modes = (none, "width", "contain")

#let is-track-size(size) = (
  size == auto
    or type(size) in (
      type(1fr),
      type(1pt),
      type(1%),
      type(1% + 1pt),
    )
)

#let is-node(node) = (
  type(node) == dictionary
    and node.at("mosaic", default: none) == tag
    and node.at("kind", default: none) in ("cell", "split", "on")
)

#let is-track(value) = (
  type(value) == dictionary
    and value.keys().sorted() == ("child", "kind", "mosaic", "size")
    and value.mosaic == tag
    and value.kind == "track"
)

#let axis-name(axis) = if axis == "width" { "columns" } else { "rows" }

// The keys a native stroke dictionary accepts. Checked here so a misspelled
// key reports as a Mosaic diagnostic where the stroke is declared, not as a
// raw error from the grid line that eventually draws it.
#let stroke-keys = ("paint", "thickness", "cap", "join", "dash", "miter-limit")

#let is-stroke(value) = (
  value == none
    or type(value) in (length, color, gradient, tiling, stroke)
    or (
      type(value) == dictionary
        and value.keys().all(key => key in stroke-keys)
    )
)

// What a native `inset` accepts: one length for every side, or a dictionary
// of sides.
#let inset-sides = ("top", "right", "bottom", "left", "x", "y", "rest")

#let is-inset-part(value) = type(value) in (length, ratio, relative)

#let is-inset(value) = (
  is-inset-part(value)
    or (
      type(value) == dictionary
        and value.keys().all(side => side in inset-sides)
        and value.values().all(is-inset-part)
    )
)


