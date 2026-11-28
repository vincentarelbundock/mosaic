# Foreground

Cells occupy the main slide body. The foreground plane sits above them, covering the slide without changing the grid. Put recurring foreground content in `m.setup(foreground:)`, and set it for one slide with the same argument on `m.slide`. A plane is not a cell, so it never appears in `cells:`. Use `foreground: none` on a slide to hide inherited content. Footer text belongs in a grid cell because it takes part in the layout; see [Footer and progress](../presenting/footer.md). The [Background](background.md) page covers the plane behind the body.

## Placed content

Foreground content is painted over the slide body. Use native `place` calls to position images, logos, text, shapes, labels, or counters independently of the grid.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup

#let badge(body, color) = rect(
  fill: color,
  radius: 0.25em,
  inset: (x: 0.55em, y: 0.3em),
  text(fill: white, weight: "bold", body),
)

#m.slide(
  foreground: [
    #place(
      top + right,
      dx: -1.35em,
      dy: 1.35em,
      badge([Label], rgb("#0072b2")),
    )
    #place(
      right + horizon,
      dx: -2.4em,
      circle(width: 3em, fill: rgb("#e69f00")),
    )
    #place(
      bottom + right,
      dx: -1.35em,
      dy: -2em,
      text(size: 1.25em, weight: "bold")[Any content],
    )
  ],
)[][
  #block(width: 52%)[
    == Place arbitrary objects

    A foreground can contain any number of independently placed Typst objects.
  ]
]
```

## A logo on every slide

A logo is the usual reason to reach for the plane, and it is the case `setup` handles best: state the `place()` call once and every slide in the deck carries it at the same spot. Because `place` resolves its alignment against the slide rather than against the content, the logo does not drift when one slide holds more than another, and `dx` and `dy` in em units keep its inset proportional to the deck's type size.

Any slide can still replace the deck's foreground with one of its own, or hide it with `foreground: none`. The fourth slide below does exactly that.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup.with(
  foreground: [
    #place(
      bottom + right,
      dx: -1.35em,
      dy: -1.35em,
      m.components.image(
        path("/docs-src/assets/images/mosaic-logo.svg"),
        width: 2.5em,
        height: auto,
        alt: "The Mosaic logo",
      ),
    )
  ],
)

#m.slide[][
  == One logo, every slide

  A `foreground` passed to `setup` is painted over every slide in the deck.
]

#m.slide[][
  == It does not move

  The `place()` alignment resolves against the slide rather than the content,
  so the logo lands in the same spot however full the slide is.
]

#m.slide[][
  == Refining the position

  `dx` and `dy` nudge it away from the edge. Em units keep that inset
  proportional to the deck's type size.
]

#m.slide(foreground: none)[][
  == Hiding it

  One slide opts out with `foreground: none`.
]
```
