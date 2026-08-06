#import "@preview/mosaic:0.0.1" as m

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
)[
  #block(width: 52%)[
    == Place arbitrary objects

    A foreground can contain any number of independently placed Typst objects.
  ]
]
