#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "4dbc7ae59cdd7982-1349cde127705c16"
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

#set document(title: [Image slides])
#metadata((title: "Image")) <website-metadata>

#title()

Use `layout: "image"` for any slide whose main content is a picture. In many decks this is the most common explicit slide.

= A figure with a caption

The default `figure` variant places a header above a contained picture, with an optional `caption:` beneath. It never crops, which is what a chart or screenshot needs:

```typ
#m.slide(layout: "image", image: path("fig/gdp.png"))[== Growth since 1950]

#m.slide(
  layout: "image",
  image: path("fig/pie.png"),
  caption: [Teaching, research, admin],
)[== My job]
```

The `figure` variant has header, image, and caption cells but no body, so a single line of commentary belongs in `caption:`. The caption produces a native Typst `figure`, so it follows the deck's `show figure.caption` rules.

= A picture beside text

The directional variants `left`, `right`, `top`, and `bottom` pair a full-bleed picture cell with header and body cells, filled by two positional blocks. Pass `[]` as the second block when the picture needs a title but no body:

```typ
#m.slide(
  layout: "image",
  variant: "right",
  image: path("fig/book.jpg"),
)[== Readings][
  - Almost every week.
  - PDFs on the course site.
]
```

Two arguments control the picture cell:

- `tracks:` sizes it. The value is independent of the side, so `tracks: 40%` means the same thing under `left` and `right`, and the two stay mirror images.
- `fit:` controls cropping. The directional variants default to `"cover"`, which fills the cell by cropping the picture. Pass `fit: "contain"` for a chart, a book cover, or any picture whose edges carry meaning.

= A full-bleed picture

The `full` variant puts the picture behind a single body cell that covers the whole slide. The cell inherits the deck's ordinary text color, so text over a photograph needs two things: a `scrim:` in the image specification to darken the picture, and a text fill override in the body:

```typ
#m.slide(
  layout: "image",
  variant: "full",
  image: (
    path: path("fig/auditorium.jpg"),
    scrim: black.transparentize(45%),
  ),
)[
  #set text(fill: white)
  == Who are you?
]
```

Omit the body entirely for a bare picture slide with no text at all. The `full` variant also works for a custom opening slide: when no #link("title.html")[title variant] fits, write the title as ordinary text over a full-bleed picture.

#embedded-example(
  calepin.elements.gallery,
  "structure/image-layout",
  frames: 4,
  title: "The figure, right, bottom, and full variants of the image layout",
  renderer: thumbnail-gallery,
)

Image paths inside layout arguments cross the package boundary, so wrap every asset path in Typst's `path()`; see #link("configuring.html#asset-paths")[Asset paths].

Named arguments on an image slide refine the configured layout rather than replacing it; see #link("configuring.html#layout-fields-on-a-slide")[Layout fields on a slide]. For image loading, fitting, scrims, and figures in ordinary cells, see #link("../content/images.html")[Images]; for a picture on a plane behind the whole grid, see #link("background.html")[Background].
