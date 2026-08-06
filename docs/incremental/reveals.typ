#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Reveal and replace])
#metadata((title: "Reveal and replace")) <website-metadata>

#title()

The timing commands introduced on the #link("steps.html")[Steps and pauses] page apply to lists, grid cells, inline text, equations, and drawing packages alike. Each section below shows one on a real slide. For equations, see #link("../content/math.html")[Math].

= Reveal bullets

Wrap a list in `m.steps.reveal` to show one more item on each step.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-bullets",
  frames: 3,
  title: "Reveal a list one item at a time",
)

= Reveal cells

Revealed grid cells can start removed, allowing visible cells to use the space until the next panel arrives.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-cells",
  frames: 3,
  title: "Add comparison cells progressively",
)

= Reveal text

Use `m.steps.on` for a word, sentence, or other element that appears only at selected steps. Ranges may be integers, open ranges such as `"3-"`, or closed ranges such as `"2-4"`; `before` and `after` control the surrounding steps.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-text",
  frames: 4,
  title: "Control when text appears",
)

= Replace content

Use `m.steps.replace` to revise a word or larger fragment without moving surrounding content; the largest alternative determines the stable slot.

#embedded-example(
  calepin.elements.gallery,
  "incremental/replace-content",
  frames: 3,
  title: "Revise content in a stable position",
)

= CeTZ drawings

Draw a figure progressively when you want to explain its geometry in the order it is constructed. Connect `m.steps.drawing` to a CeTZ canvas and preserve hidden bounds so later additions do not shift the drawing.

This example adapts the #link(
  "https://diagrams.janosh.dev/bloch-sphere",
)[Bloch sphere from Scientific Diagrams].

#embedded-example(
  calepin.elements.gallery,
  "incremental/cetz-drawing",
  frames: 4,
  title: "Construct a Bloch sphere progressively",
)

= Fletcher diagrams

Reveal a diagram path gradually when you want the audience to follow one relationship at a time. Connect `m.steps.drawing` to Fletcher, then use ordinary Mosaic timing functions around nodes and edges.

#embedded-example(
  calepin.elements.gallery,
  "incremental/fletcher-diagram",
  frames: 3,
  title: "Reveal a Fletcher diagram progressively",
)
