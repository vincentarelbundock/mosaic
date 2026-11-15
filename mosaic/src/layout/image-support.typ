// Private image composition shared by title and section layouts.
#import "../shared.typ": fail
#import "../grid/constructors.typ": make-cell, columns, rows
#import "../grid/model.typ": is-track-size
#import "core.typ": validate-image
#import "support.typ": track-children, image-content


// Where a picture sits, as the resolvers reason about it. The four
// directional positions split the slide between a full-bleed picture and the
// text; `background` paints the picture behind the text instead. Only the
// title layout exposes these words as a `position` field. The section and
// image layouts name the same places through their variants, and map a
// variant to its position before composing.
#let directional-positions = ("left", "right", "top", "bottom")
#let image-positions = directional-positions + ("background",)

// The section layout's picture variants and the position each one names.
#let section-image-positions = (
  "image-left": "left",
  "image-right": "right",
  "image-top": "top",
  "image-bottom": "bottom",
  "image-background": "background",
)

// Two spellings, because authors ask two different questions. An array of 2 is
// visual order — "what occupies each side" — and must be mirrored by hand when
// the position flips. A single track size answers "how much room does the
// picture get", which is side-independent: the companion region takes the
// remaining `1fr`, so the `left` and `right` positions stay mirror images of
// each other without the caller reordering anything.
// A directional image layout is a two-region composition by definition: an
// image band and a text band, swapped by position. The pair is the API's shape,
// not a limit that a more general track list would lift, so the count is named
// rather than parameterized. A layout wanting more regions is a grid.
#let directional-cell-count = 2

#let validate-directional-tracks(tracks, name) = {
  if tracks != auto and not is-track-size(tracks) and (
    type(tracks) != array
      or tracks.len() != directional-cell-count
      or not tracks.all(is-track-size)
  ) {
    fail(
      name
        + " must be auto, one native Typst track size for the image, or an"
        + " array of 2 native Typst track sizes in visual order",
    )
  }
  tracks
}

// `auto` is the side-by-side composition.
#let resolve-image-position(fields) = if fields.position == auto {
  "left"
} else {
  fields.position
}

// The title layout's picture fields, validated in one place. Its `image`
// variant composes the stack beside or over a photograph, so the three fields
// travel together: the picture is required exactly when the variant uses one,
// `position` places it, and `tracks` sizes the split of a directional
// position.
//
// A picture does not select the variant by itself. The resolver sees one
// merged record, in which a field written on the slide and one inherited from
// the deck's layout configuration look the same, so "the author asked for a
// picture here" cannot be told from "the deck configures one", and a variant
// inferred from `image:` would also replace whatever text design the deck
// chose. The picture fields are therefore rejected outside the picture
// variant, and the message says what to add.
#let add-image-variant = "; add variant: \"image\""

#let validate-image-fields(fields, name) = {
  if fields.variant == "image" {
    if fields.image == none {
      fail(name + " variant \"image\" requires image")
    }
    _ = validate-image(fields.image, name + " image")
    if fields.position != auto and fields.position not in image-positions {
      fail(name + " position must be auto or one of " + repr(image-positions))
    }
    if resolve-image-position(fields) in directional-positions {
      _ = validate-directional-tracks(fields.tracks, name + " tracks")
    } else if fields.tracks != auto {
      fail(name + " tracks size a split, so they apply only to positions " + repr(directional-positions))
    }
  } else {
    if fields.image != none {
      fail(
        name + " variant " + repr(fields.variant) + " does not use image"
          + add-image-variant,
      )
    }
    if fields.position != auto {
      fail(name + " position applies only to variant \"image\"" + add-image-variant)
    }
    if fields.tracks != auto {
      fail(name + " tracks apply only to variant \"image\"" + add-image-variant)
    }
  }
  fields
}

// The section layout's picture fields. Its picture variants name the place
// themselves, so there is no `position` to check: the picture is required
// exactly when the variant is one of them, and `tracks` sizes the split of the
// four directional ones. As above, a picture does not select a variant by
// itself, and the message names the variants to pick from.
#let pick-section-image-variant = (
  "; pick a picture variant: " + section-image-positions.keys().map(repr).join(", ", last: ", or ")
)

#let validate-section-image-fields(fields, name) = {
  let position = section-image-positions.at(fields.variant, default: none)
  if position == none {
    if fields.image != none {
      fail(
        name + " variant " + repr(fields.variant) + " does not use image"
          + pick-section-image-variant,
      )
    }
  } else {
    if fields.image == none {
      fail(name + " variant " + repr(fields.variant) + " requires image")
    }
    _ = validate-image(fields.image, name + " image")
  }
  if position in directional-positions {
    _ = validate-directional-tracks(fields.tracks, name + " tracks")
  } else if fields.tracks != auto {
    fail(name + " tracks apply only to directional image variants")
  }
  fields
}

// Resolves either spelling to the visual-order pair the grid expects.
#let directional-tracks(tracks, image-first) = if tracks == auto {
  auto
} else if type(tracks) == array {
  tracks
} else if image-first {
  (tracks, 1fr)
} else {
  (1fr, tracks)
}

#let fixed-image-content(value, name) = image-content(
  value,
  name,
  width: 100%,
  height: 100%,
  fit: "cover",
)

#let optional-fixed-image(value, name) = if value == none {
  none
} else {
  fixed-image-content(value, name)
}

// Image cells are full-bleed: the photograph owns its region edge to edge and
// any framing is the image's own business.
#let image-cell(content) = make-cell(
  content: content,
  id: "image",
  style: (
    content-sized: false,
    inset: 0pt,
  ),
)

// A full-bleed picture is its own edge, so the two regions meet with no gutter:
// the companion region already carries the deck inset, and a gap would leave a
// stripe of canvas that a recolored cell or header band cannot cross.
#let directional-image-layout(
  position,
  image,
  body,
  tracks: auto,
) = {
  // Every caller validates `position` first and routes `background` to
  // image-background-cell, so it is one of left/right/top/bottom here.
  _ = validate-directional-tracks(tracks, "directional image layout tracks")
  let image-first = position in ("left", "top")
  let children = if image-first {
    (image, body)
  } else {
    (body, image)
  }
  let split = if position in ("left", "right") { columns } else { rows }
  split(..track-children(children, directional-tracks(tracks, image-first)))
}

// Any tonal adjustment belongs to the picture itself (see the `scrim` argument
// of `components.image`), so the background is the resolved image and nothing
// more.
#let image-background-cell(body, image) = body + (
  style: body.style + (background: image),
)
