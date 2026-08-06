#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Background])
#metadata((title: "Background")) <website-metadata>

#title()

Cells occupy the main slide body. The background plane sits behind them, covering the slide without changing the grid. Put recurring background content in `m.setup(background:)`, and set it for one slide with the same argument on `m.slide`. A plane is not a cell, so it never appears in `cells:`. Use `background: none` on a slide to hide inherited content. The #link("foreground.html")[Foreground] page covers the plane above the body.

= Placed content

Native `place` positions images, shapes, and other Typst content independently of the grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/background-content",
  frames: 1,
  title: "Placed background content",
)

= Photographic backgrounds

Pass a slide-sized image through the reserved `background` entry. The optional `scrim` of `m.components.image()` paints a translucent layer over the photograph so the text in front stays readable. The #link("../content/images.html#scrims")[Scrims] section covers the flat, gradient, and light options.

#embedded-example(
  calepin.elements.gallery,
  "blocks/background-image",
  frames: 1,
  title: "Full-slide background image",
)
