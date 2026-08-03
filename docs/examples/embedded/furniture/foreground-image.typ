#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  content: (foreground: [
    #place(
      right + horizon,
      dx: -1.35em,
      m.components.image(
        path("/docs/assets/images/mosaic-logo.svg"),
        width: 8em,
        height: auto,
        alt: "The Mosaic logo",
      ),
    )
  ]),
)

#m.slide[
  #block(width: 52%)[
    == Logos

    Choose a `place()` alignment and refine the position with `dx` and `dy`.
  ]
]
