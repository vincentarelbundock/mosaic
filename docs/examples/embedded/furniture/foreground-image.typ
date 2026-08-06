#import "@preview/mosaic:0.0.1" as m

#show: m.setup.with(
  foreground: [
    #place(
      bottom + right,
      dx: -1.35em,
      dy: -1.35em,
      m.components.image(
        path("/docs/assets/images/mosaic-logo.svg"),
        width: 2.5em,
        height: auto,
        alt: "The Mosaic logo",
      ),
    )
  ],
)

#m.slide[
  == One logo, every slide

  A `foreground` passed to `setup` is painted over every slide in the deck.
]

#m.slide[
  == It does not move

  The `place()` alignment resolves against the slide rather than the content,
  so the logo lands in the same spot however full the slide is.
]

#m.slide[
  == Refining the position

  `dx` and `dy` nudge it away from the edge. Em units keep that inset
  proportional to the deck's type size.
]

#m.slide(foreground: none)[
  == Hiding it

  One slide opts out with `foreground: none`.
]
