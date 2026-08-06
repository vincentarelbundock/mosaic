#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "bbeb6da23c1dee03-1349cde127705c16"
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
#import "/_includes/embedded-examples.typ": thumbnail-gallery

#set document(title: [Section slides])
#metadata((title: "Section")) <website-metadata>

#title()

A section slide divides a talk into parts. It announces where the audience has arrived, carries no body content, and usually shows a number so the deck's shape stays legible.

= Sections from headings

After `#show: m.setup`, a level-one heading is a section slide. Any text between that heading and the next `==` becomes the section's subtitle, and the numbering is automatic:

```typ
= Methods

What the data can and cannot support.

== Data

This is one slide.
```

That is the whole mechanism for most decks. Sections declared this way also feed Typst's native `outline`, the `toc` variant described below, and the breadcrumbs on the #link("../presenting/navigation.html")[Navigation] page, because the headings stay native throughout.

= Explicit section slides

Write the slide with `m.slide` when it needs arguments a heading cannot carry. The section text is the slide's own content, so pass one positional block:

```typ
#m.slide(layout: "section")[Methods]

#m.slide(
  layout: "section",
  number: [02],
  subtitle: [How the grid resolves],
)[Structure]
```

An explicit `number:` overrides the automatic counter for that slide. Omit it and the designed variants read the counter themselves, which is what you want in the ordinary case. Named arguments here refine the configured section layout rather than replacing it; see #link("configuring.html#layout-fields-on-a-slide")[Layout fields on a slide].

= Variants

Each variant borrows a classic minimalist tradition:

- `plain`, the default: the title alone at the slide's center.
- `rule`: the title beneath a heavy full-width rule, the number above it.
- `numeral`: an enormous ghost number bleeding off the top-right edge behind a lower-left title stack.
- `baseline`: title and number tied to one baseline by a hairline.
- `toc`: every section in the deck listed, with the current one alive and the others ghosted.

The designed variants build their composition around the section number, so an omitted `number:` reads the automatic counter.

The image variants place the section text beside a full-bleed picture (`image-left`, `image-right`, `image-top`, `image-bottom`, sized by `tracks:`) or directly over one (`image-background`). Every image variant requires `image:`, wrapped in Typst's `path()` so the picture is found in your project rather than in the package; see #link("configuring.html#asset-paths")[Asset paths].

Written out in full, one of those slides is:

```typ
#m.slide(
  layout: "section",
  variant: "numeral",
  subtitle: [A ghost numeral],
)[Numeral section]
```

The thumbnails below grow the same divider one argument at a time: plain, numbered, the designed text variants, then each image placement. Open any thumbnail to see the slide at full size:

#thumbnail-gallery(
  calepin.elements.gallery,
  "structure/section-layout",
  11,
  "Section divider variants",
)
