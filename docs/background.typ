#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Background])
#metadata((title: "Background")) <website-metadata>

#title()

Where the #link("foreground.html")[Foreground] plane sits above the slide body,
background content is painted behind it. Neither plane changes the grid's row
or column measurements. Set a recurring background with `m.deck`, or pass
one to a specific `m.slide`. A slide inherits the deck background by
default; use `background: none` to omit it on one slide, or pass different
content to replace it.

= Placement

Background content covers the full usable slide area. Native `place` can
position images, shapes, and other Typst content independently of the slide
grid.

#verbatim-example("background/placement.typ")

#slideshow(
  calepin.elements.gallery,
  "background/placement",
  1,
  "Placed background content",
)
