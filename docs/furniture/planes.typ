#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Background and foreground])
#metadata((title: "Background and foreground")) <website-metadata>

#title()

Cells occupy the main slide body. The background plane sits behind them and the foreground plane sits above them. Both cover the slide without changing the grid. Put recurring plane content in `m.setup(background:)` or `m.setup(foreground:)`, and set it for one slide with the same arguments on `m.slide`. A plane is not a cell, so it never appears in `cells:`. Use `none` on a slide to hide inherited content. Footer text belongs in a grid cell because it takes part in the layout; see #link("footer.html")[Footer and progress].

= Background

Background content is painted behind the slide body over the full usable area.

== Placed content

Native `place` positions images, shapes, and other Typst content independently of the grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/background-content",
  frames: 1,
  title: "Placed background content",
)

== Photographic backgrounds

Pass a slide-sized image through the reserved `background` entry. The optional `scrim` of `m.components.image()` paints a translucent layer over the photograph so the text in front stays readable. The #link("../content/images.html#scrims")[Scrims] section covers the flat, gradient, and light options.

#embedded-example(
  calepin.elements.gallery,
  "blocks/background-image",
  frames: 1,
  title: "Full-slide background image",
)

= Foreground

Foreground content is painted over the slide body. Use native `place` calls to position images, logos, text, shapes, labels, or counters independently of the grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-content",
  frames: 1,
  title: "Arbitrary foreground objects",
)

Put a recurring logo in `m.setup(foreground: ...)`. Any slide can replace it or hide it with `foreground: none`.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-image",
  frames: 1,
  title: "Logo in the foreground",
)
