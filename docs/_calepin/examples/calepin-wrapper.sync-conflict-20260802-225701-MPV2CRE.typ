#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "4b1db97ef5fdb0c8-1349cde127705c16"
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
#import "/_includes/pdf-slideshow.typ": pdf-slideshow

#set document(title: [Examples])
#metadata((
  title: "Examples",
  description: "Complete slide decks built with Mosaic, adapted from real-world presentation templates.",
)) <website-metadata>

#let decks = json("/examples/decks/manifest.json").decks

#let deck(entry) = {
  let slug = entry.slug
  let dir = "examples/decks/" + slug
  let pdf = dir + "/" + slug + ".pdf"
  let cover = dir + "/cover.jpg"
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    pdf-slideshow(
      pdf,
      cover,
      "pdf-slideshow-example-" + slug,
      entry.title,
      entry.frames,
      entry.alt,
      max-width: 42em,
      unit: "slides",
    )
  } else {
    align(center, image("/" + cover, width: 70%, alt: entry.alt))
  }
}

#let repo = "https://github.com/vincentarelbundock/mosaic/tree/main/docs/examples/decks"

#title()

Explore four complete decks built with Mosaic. Click a thumbnail to page through
its slides. The #link(repo)[GitHub repository] contains every deck's full Typst
source, assets, Makefile, and compiled PDF. Each deck builds its slides from
custom grids and styles every cell with native `show` rules on its
`<mosaic-cell-ID>` label. Each deck's look is a single-module theme; three ship
inside the package under `m.themes`, and
#link("appearance.html#themes")[Appearance] explains how to write your own. See
#link("acknowledgments.html#example-decks")[Acknowledgments] for sources and
licenses.

#if sys.inputs.at("calepin-target", default: "paged") == "html" {
  html.elem("style", "
    .examples-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(min(100%, 24rem), 1fr));
      gap: 1.25rem;
      margin-block: 1.5rem;
    }

    .examples-grid > .pdf-slideshow {
      min-width: 0;
    }

    .examples-grid .pdf-slideshow,
    .examples-grid .pdf-slideshow-preview {
      width: 100%;
      max-width: none !important;
      margin: 0;
    }
  ")
  html.elem("div", attrs: (class: "examples-grid"))[
    #for entry in decks { deck(entry) }
  ]
} else {
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    ..decks.map(deck),
  )
}
