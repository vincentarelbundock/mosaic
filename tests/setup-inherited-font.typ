// Ambient `set text` must flow into layout-driven cells. Body regions carry
// no text delta, so a deck's font (or any native override) reaches default,
// title, and section layout bodies. Each probe asserts the inherited font.
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

#mosaic.slide(layout: mosaic.layouts.content(variant: "body"))[
  #probe("default body")
]

#mosaic.slide(layout: mosaic.layouts.title([#probe("title body")]))

#mosaic.slide(layout: mosaic.layouts.section())[#probe("section body")]
