#import "@preview/mosaic:0.0.1" as m

#show: m.setup

#let river = "/docs-src/assets/images/title-river.webp"
#let describe = "Autumn wetlands under a pale overcast sky"

// The same white text runs across the first three frames, so the scrim is the
// only thing that changes between them.
#let light-text = it => {
  show label("mosaic-cell-body"): set text(fill: white)
  it
}

// No scrim. White text disappears into the pale sky.
#[
  #show: light-text
  #m.slide(
    layout: m.layouts.image(
      (path: path(river), alt: describe),
      variant: "full",
    ),
    cells: (body: [
      == Without a scrim

      The picture is unmodified, so light text survives over the dark reeds
      and vanishes against the sky.
    ],
    ),
  )
]

// A flat color quiets the whole frame by the same amount.
#[
  #show: light-text
  #m.slide(
    layout: m.layouts.image(
      (
        path: path(river),
        scrim: black.transparentize(45%),
        alt: describe,
      ),
      variant: "full",
    ),
    cells: (body: [
      == A flat scrim

      `scrim: black.transparentize(45%)` covers the picture with black at 55%
      opacity. The text is now readable anywhere on the slide.
    ],
    ),
  )
]

// A gradient darkens the band the text occupies and releases the rest.
#[
  #show: light-text
  #m.slide(
    layout: m.layouts.image(
      (
        path: path(river),
        scrim: gradient.linear(
          black.transparentize(100%),
          black.transparentize(10%),
          angle: 90deg,
        ),
        alt: describe,
      ),
      variant: "full",
    ),
    cells: (body: [
      #v(1fr)

      == A gradient scrim

      A scrim accepts any Typst paint, so `gradient.linear(..)` protects the
      text along the bottom edge and leaves the horizon at full strength.
    ],
    ),
  )
]

// A scrim is not always dark: a white wash lifts the picture behind the
// deck's ordinary text color.
#m.slide(
  layout: m.layouts.image(
    (
      path: path(river),
      scrim: white.transparentize(25%),
      alt: describe,
    ),
    variant: "full",
  ),
  cells: (body: [
    == A light scrim

    `scrim: white.transparentize(25%)` washes the picture out instead, which
    keeps the deck's ordinary dark text readable and needs no color rule.
  ],
  ),
)
