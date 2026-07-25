#import "@local/mosaic:0.0.1" as mosaic

#assert("color" in mosaic)
#assert("palette" in mosaic.color)
#assert("scheme" in mosaic.color)

#let colors = mosaic.color.palette("okabe-ito")
#assert(type(colors) == array)
#assert(colors.len() == 8)
#assert(colors.first() == rgb("#E69F00"))
#assert(colors.last() == rgb("#000000"))

// Named and indexed selection preserve ordinary palette-array behavior.
#let tol-bright = mosaic.color.palette("tol-bright")
#assert(type(tol-bright) == array)
#assert(tol-bright.len() == 7)
#assert(tol-bright.first() == rgb("#4477AA"))
#assert(tol-bright.last() == rgb("#BBBBBB"))
#assert(mosaic.color.palette("tol-bright", color: 0) == rgb("#4477AA"))
#assert(mosaic.color.palette("tol-bright", color: "blue") == rgb("#4477AA"))

#let palette-contracts = (
  ("tol-muted", 9, rgb("#CC6677"), rgb("#AA4499"), "rose"),
  ("brewer-dark2", 8, rgb("#1B9E77"), rgb("#666666"), "teal"),
  ("brewer-set2", 8, rgb("#66C2A5"), rgb("#B3B3B3"), "teal"),
  ("brewer-paired", 12, rgb("#A6CEE3"), rgb("#B15928"), "light-blue"),
  ("carto-antique", 12, rgb("#855C75"), rgb("#7C7C7C"), "color-1"),
  ("carto-safe", 12, rgb("#88CCEE"), rgb("#888888"), "sky-blue"),
  ("carto-bold", 12, rgb("#7F3C8D"), rgb("#A5AA99"), "purple"),
  ("carto-pastel", 12, rgb("#66C5CC"), rgb("#B3B3B3"), "color-1"),
  ("carto-prism", 12, rgb("#5F4690"), rgb("#666666"), "color-1"),
  ("carto-vivid", 12, rgb("#E58606"), rgb("#A5AA99"), "color-1"),
)

#for (name, length, first, last, first-name) in palette-contracts {
  let values = mosaic.color.palette(name)
  assert(type(values) == array)
  assert(values.len() == length)
  assert(values.first() == first)
  assert(values.last() == last)
  assert(mosaic.color.palette(name, color: first-name) == first)
}

#let light = mosaic.color.palette("okabe-ito", lighten: 80%)
#assert(light.first() == colors.first().lighten(80%))
#assert(light.last() == colors.last().lighten(80%))

#let darkened = mosaic.color.palette("okabe-ito", darken: 20%)
#assert(darkened.first() == colors.first().darken(20%))
#assert(darkened.last() == colors.last().darken(20%))

#let role-keys = (
  "accent",
  "canvas",
  "inverse-text",
  "line",
  "muted",
  "surface",
  "text",
)

#let light-scheme = mosaic.color.scheme("light")
#assert(type(light-scheme) == dictionary)
#assert(light-scheme.keys().sorted() == role-keys)
#assert(light-scheme.canvas == rgb("#fafaf9"))
#assert(light-scheme.surface == white)
#assert(light-scheme.accent == rgb("#2563eb"))
#assert(light-scheme.text == rgb("#1c1917"))
#assert(light-scheme.inverse-text == white)
#assert(light-scheme.muted == rgb("#78716c"))
#assert(light-scheme.line == rgb("#e7e5e4"))

#let dark-scheme = mosaic.color.scheme("dark")
#assert(type(dark-scheme) == dictionary)
#assert(dark-scheme.keys().sorted() == role-keys)
#assert(dark-scheme.canvas == rgb("#111827"))
#assert(dark-scheme.surface == rgb("#1f2937"))
#assert(dark-scheme.accent == rgb("#60a5fa"))
#assert(dark-scheme.text == rgb("#f3f4f6"))
#assert(dark-scheme.inverse-text == rgb("#111827"))
#assert(dark-scheme.muted == rgb("#9ca3af"))
#assert(dark-scheme.line == rgb("#374151"))

#let presentation-scheme-contracts = (
  (
    "gallery",
    (
      canvas: rgb("#f4f0e8"), surface: rgb("#fffefa"), accent: rgb("#17324d"),
      text: rgb("#20262d"), inverse-text: white,
      muted: rgb("#646d76"), line: rgb("#d6d0c5"),
    ),
  ),
  (
    "editorial",
    (
      canvas: rgb("#f7f3ec"), surface: white, accent: rgb("#a3312d"),
      text: rgb("#211f1c"), inverse-text: white,
      muted: rgb("#716a61"), line: rgb("#d9d1c5"),
    ),
  ),
  (
    "botanical",
    (
      canvas: rgb("#f3f4ed"), surface: rgb("#fcfdf8"), accent: rgb("#315c49"),
      text: rgb("#202721"), inverse-text: white,
      muted: rgb("#687268"), line: rgb("#d4d9cf"),
    ),
  ),
  (
    "studio",
    (
      canvas: rgb("#f7f1f5"), surface: rgb("#fffdfe"), accent: rgb("#673a61"),
      text: rgb("#2b222a"), inverse-text: white,
      muted: rgb("#756a73"), line: rgb("#ddd1da"),
    ),
  ),
  (
    "conference",
    (
      canvas: rgb("#f4f6fb"), surface: white, accent: rgb("#2447a8"),
      text: rgb("#202536"), inverse-text: white,
      muted: rgb("#687087"), line: rgb("#d7ddea"),
    ),
  ),
  (
    "spotlight",
    (
      canvas: rgb("#171a21"), surface: rgb("#232733"), accent: rgb("#d9a441"),
      text: rgb("#f5f1e8"), inverse-text: rgb("#171a21"),
      muted: rgb("#b3b7c1"), line: rgb("#3a404c"),
    ),
  ),
)

#for (name, expected) in presentation-scheme-contracts {
  let actual = mosaic.color.scheme(name)
  assert(type(actual) == dictionary)
  assert(actual.keys().sorted() == role-keys)
  assert(actual == expected)
}

#show: mosaic.setup.with(colors: dark-scheme)

#mosaic.slide[Dark body slide]

#mosaic.slide(grid: mosaic.templates.default())[
  == Dark complete structure
][
  Body text
][
  Muted footer
]
