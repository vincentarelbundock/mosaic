#import "/_calepin/calepin.typ" as calepin_runtime
#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Overflow and fitting])
#metadata((title: "Overflow and fitting")) <website-metadata>

#title()

A cell does not resize its content. A body larger than its cell is drawn past the edge, so a slide that holds too much fails silently on screen rather than at compile time. Before presenting, run a checking compile to find those slides, and scale the rare indivisible block with `m.fit`.

= Inspecting overflowing cells

Overflow observation is off by default, because measuring every cell on every frame roughly doubles the layout work a deck does. It is a checking pass, not something to leave on while you write. The usual way to run it is to set `overflow: "error"` on `setup` and compile once before presenting: Mosaic renders the whole deck, then fails naming every overflowing cell with its slide and frame.

For tooling that would rather read the records than stop the build, `setup(overflow: "record")` emits them and keeps compiling:

#calepin_runtime.chunk_from_raw_plain("sh", raw("  'query(<mosaic-overflow-warning>).map(it => it.value)' \\\n  --in slides.typ\n", block: true, lang: "sh"))

Each record identifies the slide, frame, cell, and measured height. Typst gives a package no warning channel, so `"record"` prints nothing on its own; see the
#link("../api/setup.html")[Setup API].

An overflow means the slide holds more than it can show. The remedy is editorial: cut a bullet, split the slide in two, or move to a layout with more room. Mosaic deliberately offers no automatic shrink-to-fit for body content, because a deck whose type size is decided slide by slide loses the scale that holds it together.

= Fitting a block to its cell

When a single indivisible block is the problem, a wide table, a chart, or a generated list, scale that one block with `m.fit` and leave the deck's typography alone:

```typ
#m.slide[
  == Regression results
  #m.fit(my-table)
]
```

It measures the block against the space its cell gives it, scales it geometrically, and reflows the surrounding layout around the new size. Shrinking is the default, and it takes no hand-picked factor, so the block stays within the cell when the table gains a row. `grow: true` also scales content up, which is how a single number or word fills a cell.

The block is offered the cell's width first, so text and lists wrap and are then scaled only if they are still too tall. A table or diagram given a narrower width rearranges itself instead of shrinking, so `wrap: false` measures and scales it as written.

`width:` and `height:` fit to part of the region instead of all of it, and take a length, ratio, or fraction. A fitted block cannot overflow, so it no longer appears in the overflow records.

Measuring a block means holding it inside a closure, which the slide runtime cannot look into. `m.pause`, `m.steps`, and `m.note` are found by walking the slide's content, so inside a fitted block they would be invisible: the reveals would collapse into one frame and the notes would never reach the speaker output. `m.fit` reports that as an error instead. Keep them outside the fitted block, or fit each revealed part on its own.

#embedded-example(
  calepin.elements.gallery,
  "content/fit-block",
  frames: 2,
  title: "A table scaled to its cell, and display type grown to fill one",
)

See the #link("../api/slides.html")[Slides API] for the full `m.fit` signature.
