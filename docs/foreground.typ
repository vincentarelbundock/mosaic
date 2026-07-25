#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Foreground])
#metadata((title: "Foreground")) <website-metadata>

#title()

Templates, grids, cells, and components occupy the main slide body. Foreground
content is painted over that body without changing its row or column
measurements. Set a recurring foreground with `m.deck`, or pass one to a
specific `m.slide`. A slide inherits the deck foreground by default; use
`foreground: none` to omit it on one slide, or pass different content to
replace it.

= Numbering

Deck foregrounds float above every inherited grid. All incremental frames
from one slide share a logical slide number while their step and page numbers
advance.

#verbatim-example("foreground/numbering.typ")

#slideshow(
  calepin.elements.gallery,
  "foreground/numbering",
  3,
  "Logical and physical numbering",
)

= Place arbitrary objects

`foreground` accepts arbitrary Typst content and covers the full usable slide
area. Add any number of native `place` calls to position images, logos, text,
shapes, labels, counters, or other content independently of the slide grid.

#verbatim-example("foreground/place.typ")

#slideshow(
  calepin.elements.gallery,
  "foreground/place",
  1,
  "Arbitrary foreground objects",
)
