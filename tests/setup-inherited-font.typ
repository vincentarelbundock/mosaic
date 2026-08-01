// Ambient `set text` must flow into layout-driven cells. Body regions carry
// no text delta, so a deck's font (or any native override) reaches the default,
// image, and table layout bodies. Each probe asserts the inherited font.
#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup
#set text(font: "DejaVu Serif")

#let probe(name) = context {
  let font = text.font
  let family = if type(font) == str { font } else { font.first() }
  assert(
    lower(family).contains("dejavu"),
    message: "mosaic: " + name + " did not inherit the ambient font, got "
      + repr(font),
  )
}

#mosaic.slide(grid: mosaic.layouts.default(variant: "body"))[
  #probe("default body")
]

// "right" body order is (body, image); probe the text body, supply a plain
// rectangle as the image so the test needs no asset.
#mosaic.slide(grid: mosaic.layouts.image(variant: "right"))[
  #probe("image body")
][
  #rect(width: 10pt, height: 10pt)
]

#mosaic.slide(grid: mosaic.layouts.table(title: [T]))[
  #table(columns: 1, [#probe("table body")])
]
