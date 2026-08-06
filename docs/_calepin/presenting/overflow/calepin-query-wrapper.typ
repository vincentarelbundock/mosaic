#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element



#let _raw-chunk-langs = ("python", "r", "mermaid", "dot", "tikz", "d2")
#show raw.where(block: true, lang: "typ", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "typst", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "python", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("python", it) }
#show raw.where(block: true, lang: "r", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("r", it) }
#show raw.where(block: true, lang: "mermaid", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("mermaid", it) }
#show raw.where(block: true, lang: "dot", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("dot", it) }
#show raw.where(block: true, lang: "tikz", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("tikz", it) }
#show raw.where(block: true, lang: "d2", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("d2", it) }

#show raw.where(block: true, theme: auto): it => {
  if _is-query() {
    it
  } else if _disable-raw-chunk-transforms.get() {
    _html-themed-raw-block(it)
  } else if it.has("lang") and it.lang != none and _raw-chunk-langs.contains(it.lang) and _fenced-chunks-runs(
    it.lang,
    _resolve-options(it.lang, _call-defaults).at("fenced-chunks"),
  ) {
    chunk_from_raw_plain(it.lang, it)
  } else {
    _html-themed-raw-block(it)
  }
}

#show heading: it => {
  if _is-html() and "label" in it.fields() {
    std.html.elem("calepin-heading-anchor", attrs: (data-id: str(it.label)))
  }
  it
}

// Notebook theme
#import "/_calepin/calepin.typ": _html-themed-raw-block, _is-query, chunk_from_raw_plain

// Body text size, captured below at document-body level. Code blocks are sized
// relative to this rather than to `1em`, which would compound: a literal
// ```typ block is rendered by replacing its source `raw` element, so it renders
// inside Typst's already-reduced raw text context, whereas executed chunks are
// emitted as ordinary calls at body size. Anchoring to the captured body size
// gives both paths a single, matching reduction instead of shrinking twice.
#let _calepin-body-size = std.state("calepin-body-size", 11pt)

#show raw.where(block: true): it => {
  if it.theme != auto {
    context {
      set text(size: _calepin-body-size.get() * 0.8)
      it
    }
  } else if it.lang != none and (_is-query() or _raw-chunk-langs.contains(it.lang)) and _fenced-chunks-runs(
    it.lang,
    _resolve-options(it.lang, _call-defaults).at("fenced-chunks"),
  ) {
    chunk_from_raw_plain(it.lang, it)
  } else {
    _html-themed-raw-block(it)
  }
}

#context _calepin-body-size.update(text.size)

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
