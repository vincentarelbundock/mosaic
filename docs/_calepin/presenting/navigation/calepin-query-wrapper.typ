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

#set document(title: [Navigation])
#metadata((title: "Navigation")) <website-metadata>

#title()

Because Mosaic keeps Typst headings native, the same headings that create slides can drive tables of contents, breadcrumbs, and links between sections.

= Table of contents

Mosaic keeps headings native, so a table of contents is Typst's own #link("https://typst.app/docs/reference/model/outline/")[`outline`]. Three of its defaults behave differently on a slide than in a document.

== Depth

`depth: 1` lists sections. `depth: 2` adds every slide, which on most decks is the whole slide list.

== Entries

A default entry ends in dotted leaders and the page its heading falls on. On slides that page is the physical frame, so on a deck using `#m.pause` it differs from the logical slide number in the footer.

A `show outline.entry` rule replaces the entry. `it.body()` is the title, `it.element.location()` is the link target, and `it.prefix()` is the heading number when headings are numbered.

== The contents slide itself

Its own heading is outlined like any other, so it appears in its own outline unless it carries `#heading(outlined: false)` or a narrower `target:` excludes it.

#embedded-example(
  calepin.elements.gallery,
  "furniture/outline",
  frames: 5,
  title: "A linked table of contents",
)

== Columns

`#columns(2, outline(..))` does not spread entries across a slide. Typst fills the first column to the full height of its container before starting the second, and a slide cell is full-slide height, so a list that fits vertically stays in column one. A surrounding `block` does not change that.

`query(heading.where(level: 1, outlined: true))` returns the section headings in document order, each with a `body` to print and a `location()` to link to. Slice them and place the chunks in a native `grid`.

#embedded-example(
  calepin.elements.gallery,
  "furniture/outline-columns",
  frames: 7,
  title: "Contents in two columns",
)

== Lists longer than the slide

An overflowing cell is drawn past the bottom edge rather than clipped. #link("../api/slides.html")[`m.fit`] scales a block into the space available:

```typ
#m.fit(outline(title: none, depth: 1))
```

Fitting scales the type with the layout, so the contents slide no longer matches the deck's type scale.

== The current section

The #link("../slides/section.html#variants")[section layout]'s `toc` variant lists every section with the current one marked, reading the deck's section records rather than an outline:

```typ
#m.slide(layout: "section", variant: "toc")[Results]
```

It takes no `outline` and no query, and fits itself to the slide.

= Breadcrumbs

Use native contextual `query` with a selector ending at `here()` to find the active section and slide headings. Their `body` fields provide the labels, and `location()` provides a link target.

#embedded-example(
  calepin.elements.gallery,
  "furniture/breadcrumbs",
  frames: 3,
  title: "Section and slide breadcrumbs",
)

= Section links

Use `query(heading.where(level: 1, outlined: true))` to collect every outlined section heading. Each result provides a label through `body` and a destination through `location()`. Compare it with the last matching heading before `here()` to style the active section differently.

#embedded-example(
  calepin.elements.gallery,
  "furniture/section-links",
  frames: 3,
  title: "Clickable section navigation",
)
