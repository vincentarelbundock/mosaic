#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "e4d43401caf02a97-1349cde127705c16"
#let _calepin-verify-generation() = {
  let path = sys.inputs.at("calepin-results", default: none)
  if path != none and path != "" {
    let actual = json(path).at("generation", default: "")
    if actual != _calepin-expected-generation {
      panic("Calepin results changed while this render was starting; Typst will retry with the completed build")
    }
  }
}
#_calepin-verify-generation()



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

#import "/_calepin/calepin.typ" as calepin
#set document(title: [Speaker notes])
#metadata((title: "Speaker notes")) <website-metadata>

#title()

Attach speaker notes with `m.note[...]`. Notes never appear in the presentation and never add a frame:

```typ
#m.slide[
  #m.note[Introduce the result.]

  #m.steps.reveal(
    [
      The estimate is positive.
      #m.note[Explain the sign and magnitude.]
    ],
    [
      The interval excludes zero.
      #m.note[Discuss uncertainty.]
    ],
  )
]
```

A note outside a timing command applies to every frame. A note inside `m.steps.on`, `m.steps.reveal`, or `m.steps.replace` appears with that content.

Notes also hold material that supports a slide without belonging on it: the source URL of a figure, a reminder of what to say, or the link behind an image slide.

= Printed outputs

To print a companion document, choose an output in `m.setup`:

```typ
// Slide thumbnail followed by its notes.
#show: m.setup.with(output: "speaker")

// Notes without a slide thumbnail.
#show: m.setup.with(output: "notes")
```

On those printed pages, the frame heading renders under the `<mosaic-note-heading>` label and the note text under `<mosaic-note-body>`. Both default to plain black type that reads against paper whatever the theme does. Restyle them with ordinary rules after `m.setup`:

```typ
#show label("mosaic-note-body"): set text(size: 11pt)
#show label("mosaic-note-heading"): set text(fill: rgb("#0072B2"))
```

The note outputs are independent of `handout:`, so a deck can print a #link("../incremental/handouts.html")[handout], a speaker script, or both.
