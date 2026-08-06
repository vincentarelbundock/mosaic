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

#set document(title: [Citations])
#metadata((title: "Citations")) <website-metadata>

#title()

Mosaic adds no citation machinery. A deck is an ordinary Typst document, so `#cite`, `@key` references, and `#bibliography` behave exactly as they do in a paper. Footnotes are the one exception worth knowing about, because a slide is a fixed-height frame rather than a flowing page.

= Citation keys and a reference slide

Load a BibTeX or Hayagriva file with `#bibliography` on a closing slide. Set the style once with `#set bibliography(style: ...)` so the in-text citations and the reference list agree, and pass `title: none` so the slide's own heading names the list instead of the generated one.

#embedded-example(
  calepin.elements.gallery,
  "blocks/citations",
  frames: 2,
  title: "Cite sources and close with a reference slide",
)

The usual Typst citation forms all apply. `@key` produces a normal citation, `#cite(<key>, form: "prose")` reads as the sentence subject, `#cite(<key>, form: "year")` gives the year alone, and a supplement narrows the reference: `@tufte1990[p. 42]`.

`#bibliography` renders one block that cannot be split across slides, so a long reference list overflows its cell. Shrink it with `#set text(size: ...)` in that cell, or split the sources across several `.bib` files and give each reference slide its own `#bibliography` call. Each entry is printed by the first call that owns it, and numbering continues across the slides, so two or three uncrowded reference slides read better than one full one.

= Footnotes

Typst moves a footnote entry to the bottom of the page region that holds its marker. A Mosaic slide is a fixed-size frame, so there is no room below the content for the entry, and Typst pushes it onto a page of its own: the marker appears on the slide, the note text on the next frame. Native `#footnote` is therefore not usable inside a slide body.

Put the notes in a cell instead. An `auto`-height row at the bottom of the grid holds them, sized down and dimmed, and they stay on the slide that references them:

#embedded-example(
  calepin.elements.gallery,
  "blocks/slide-sources",
  frames: 1,
  title: "Source notes in a dedicated grid row",
)

Because the markers are written by hand, numbering is per slide by construction, which is what a deck wants: an audience reading footnote 14 on a single slide has no way to count back to it. Define `marker` and `source` once in a shared file and every slide in the deck can use them.

The same row works for a source line under a figure or a table. Give it a fixed height rather than `auto` when several slides in a row carry notes, so the body area does not shift between them.
