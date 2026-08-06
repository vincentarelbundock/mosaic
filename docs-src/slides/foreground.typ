#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Foreground])
#metadata((title: "Foreground")) <website-metadata>

#title()

Cells occupy the main slide body. The foreground plane sits above them, covering the slide without changing the grid. Put recurring foreground content in `m.setup(foreground:)`, and set it for one slide with the same argument on `m.slide`. A plane is not a cell, so it never appears in `cells:`. Use `foreground: none` on a slide to hide inherited content. Footer text belongs in a grid cell because it takes part in the layout; see #link("../presenting/footer.html")[Footer and progress]. The #link("background.html")[Background] page covers the plane behind the body.

= Placed content

Foreground content is painted over the slide body. Use native `place` calls to position images, logos, text, shapes, labels, or counters independently of the grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-content",
  frames: 1,
  title: "Arbitrary foreground objects",
)

= A logo on every slide

A logo is the usual reason to reach for the plane, and it is the case `setup` handles best: state the `place()` call once and every slide in the deck carries it at the same spot. Because `place` resolves its alignment against the slide rather than against the content, the logo does not drift when one slide holds more than another, and `dx` and `dy` in em units keep its inset proportional to the deck's type size.

Any slide can still replace the deck's foreground with one of its own, or hide it with `foreground: none`. The fourth slide below does exactly that.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-image",
  frames: 4,
  title: "A logo placed once in setup, carried by every slide",
)
