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

#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Get started])
#metadata((title: "Get started")) <website-metadata>

#title()

First, import Mosaic and apply its setup rule:

```typ
#import "@local/mosaic:0.0.1" as m
#show: m.setup
```

`m.setup` applies the page and theme defaults and turns headings and explicit `m.slide` commands into slides.

After `#show: m.setup`, every `==` starts a *content slide*: the heading becomes the title and the text that follows becomes its content. A single `=` starts an unnumbered *section slide* with a larger, centered title, and any text between it and the next `==` becomes that section's subtitle.

Most decks declare their shared settings once at the top with `m.setup.with(...)`: the deck's title and authors, the layout every content slide should use, and any recurring content such as a progress line. After that, the document is mostly headings, with explicit `m.slide` calls for slides a heading cannot express, such as a picture beside text or a two-column comparison.

The example below is a complete deck in that shape. It declares its title and authors once, opens with the built-in `title` layout, creates ordinary slides from headings, and finishes with two explicit slides: one `image` layout and one two-column content slide.

#embedded-example(
  calepin.elements.gallery,
  "getting-started/first-slideshow",
  frames: 6,
  title: "A complete deck: title slide, heading slides, an image slide, and two columns",
)

Read the #link("../reference/concepts.html")[Concepts] page next: it defines the vocabulary this documentation uses and the anatomy every slide shares. The #link("../slides/content.html")[Slides] section then takes each kind of slide in turn: ordinary #link("../slides/content.html")[content], the #link("../slides/title.html")[title] slide, #link("../slides/section.html")[section] dividers, #link("../slides/image.html")[image] slides, and #link("../slides/custom.html")[custom] compositions built from named cells.
