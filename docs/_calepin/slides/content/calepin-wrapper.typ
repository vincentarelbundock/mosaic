#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "ac75e72270d1e31c-1349cde127705c16"
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
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  thumbnail-gallery,
)

#set document(title: [Content slides])
#metadata((title: "Content")) <website-metadata>

#title()

Content slides carry the body of a talk: a title and some prose, a bulleted list, a two-column comparison. They are the most common slide in almost every deck, and Mosaic makes them the default. A slide with no `layout:` argument is a content slide, and so is every `==` heading in the document.

```typ
== Three exams, equal weight

Each exam counts for a third of the grade.
```

```typ
#m.slide[== Three exams, equal weight][Each exam counts for a third of the grade.]
```

Both forms render the same slide through the same layout. Write headings for the ordinary case and reach for `m.slide` when a slide needs arguments a heading cannot express.

Mosaic recognizes four layouts by name: `"content"`, `"title"`, `"section"`, and `"image"`. Because `"content"` is the default you can usually omit it. This page covers the content layout. Content reaches the cells of every layout the same two ways, described in #link("custom.html#filling-cells")[Filling cells].

= Choosing a structure

The content layout comes in four variants: `body`, `header-body`, `body-footer`, and `header-body-footer`. Each theme picks one; the default theme uses `header-body`. Ask a slide for another with `variant:`. The `==` heading then fills the header, the next block fills the body, and a third block fills the footer:

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-full",
  frames: 1,
  title: "A slide with header, body, and footer cells",
  renderer: thumbnail-gallery,
)

See #link("../presenting/footer.html#default-footer-content")[Footer and progress] for recurring footer content and #link("../appearance/styling.html#styling-cells")[Styling cells] for cell styling.

= Two columns

For a side-by-side comparison, set `columns: 2` and supply three #link("custom.html#filling-cells")[positional blocks]: header, left, right. Write the header as a `==` heading so the slide keeps its place in the outline:

#embedded-example(
  calepin.elements.gallery,
  "structure/content-columns",
  frames: 1,
  title: "A two-column comparison under one header",
  renderer: thumbnail-gallery,
)

Add `tracks: (2fr, 1fr)` for an uneven split.

Every layout takes its fields this way, and a deck can adopt one throughout instead of naming it slide by slide. #link("custom.html#refine-a-layout")[Refine a layout] and #link("custom.html#replace-or-reuse-a-layout")[Replace or reuse a layout] cover both; the #link("../api/layouts.html")[Layouts API] lists all variants, cell IDs, and arguments.
