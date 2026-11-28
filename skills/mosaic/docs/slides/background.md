# Background

Cells occupy the main slide body. The background plane sits behind them, covering the slide without changing the grid. Put recurring background content in `m.setup(background:)`, and set it for one slide with the same argument on `m.slide`. A plane is not a cell, so it never appears in `cells:`. Use `background: none` on a slide to hide inherited content. The [Foreground](foreground.md) page covers the plane above the body.

## Placed content

Native `place` positions images, shapes, and other Typst content independently of the grid.

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#m.slide(
  "content",
  variant: "body",
  background: [
    #place(center)[
      #circle(width: 410pt, fill: blue.lighten(88%), stroke: none)
    ]
  ],
)[
  == Full-slide backgrounds

  The circle is behind the grid.
]
```

## Photographic backgrounds

Pass a slide-sized image to the `background:` argument. The optional `scrim` of `m.components.image()` paints a translucent layer over the photograph so the text in front stays readable. The [Scrims](../content/images.md#scrims) section covers the flat, gradient, and light options.

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set page(fill: rgb("#f4f1ea"))
#set text(size: 22pt, fill: rgb("#172033"))

// Anchor the body content to the right, past the image, through its label.
#show label("mosaic-cell-body"): set align(right + horizon)

#m.slide(
  "content",
  variant: "body",
  background: m.components.image(
  path("/docs-src/assets/images/bonsai.webp"),
  scrim: white.transparentize(65%),
  alt: "A pine bonsai",
),
)[
  #block(width: 38%)[
    == A background image

    Pass `m.components.image()` content through the `background` entry.
  ]
]
```
