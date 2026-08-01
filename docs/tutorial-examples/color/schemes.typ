#import "@local/mosaic:0.0.1" as m

#show: m.setup

#let scheme-names = (
  "light",
  "dark",
  "gallery",
  "editorial",
  "botanical",
  "studio",
  "conference",
  "spotlight",
)

#let dog-card(colors) = block(
  width: 100%,
  fill: colors.surface,
  stroke: 1pt + colors.line,
  radius: 8pt,
  inset: 0.5em,
)[
  #rect(
    width: 100%,
    height: 0.28em,
    fill: colors.accent,
    stroke: none,
    radius: 999pt,
  )
  #v(0.45em)
  #m.image(
    path("/docs/assets/images/dog.webp"),
    width: 100%,
    height: 7.3em,
    fit: "cover",
    alt: "A brown dog outdoors",
  )
]

#for name in scheme-names {
  let colors = m.color.scheme(name)
  // Invert the footer for this scheme: fill it with the scheme's text color
  // and switch its own text to the inverse. Both are native rules on the
  // footer cell's <mosaic-cell-footer> label.
  [
    #show label("mosaic-cell-footer"): set text(fill: colors.inverse-text)
    #show label("mosaic-cell-footer"): it => block(
      width: 100%,
      height: 100%,
      fill: colors.text,
      it,
    )
    #m.slide(
      grid: m.layouts.default(
        columns: 2,
        tracks: (2fr, 1fr),
      ),
      colors: colors,
    )[
      == #name
    ][
      #text(size: 0.78em)[#lorem(36)]
    ][
      #dog-card(colors)
    ][
      Mosaic semantic color preview
    ]
  ]
}
