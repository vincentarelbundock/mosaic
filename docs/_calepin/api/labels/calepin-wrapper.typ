#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "3fd2354f36f0d81d-1349cde127705c16"
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
#set document(title: [Labels])
#metadata((title: "Labels")) <website-metadata>

#title()

Every part of a rendered slide carries a Typst label, and those labels are the whole styling surface. A deck reaches them with ordinary `show` rules, and a theme's `apply` reaches the same ones. This page is the complete inventory.

Two kinds of rules cover a labeled region, split by what they touch. Properties of the content *inside* it pass through as ordinary `set` rules. Properties of its own block, its fill, stroke, and corner radius, go through `m.surface`, which wraps the labeled block in one that carries the paint. The #link("../appearance/styling.html")[styling] page explains that split in full.

= Cells

Each cell of a slide is a single block labeled with its own id.

#table(
  columns: (auto, 1fr),
  [`mosaic-cell-ID`], [Any cell, by the id its layout or grid gave it. This is the general form; the entries below are the ids the built-in layouts produce.],
  [`mosaic-cell-header`], [The header of a content slide.],
  [`mosaic-cell-body`], [The body of a content slide, and the default cell for slide content with no layout.],
  [`mosaic-cell-footer`], [The footer of a content slide, and the usual home for a progress indicator.],
  [`mosaic-cell-title`], [The title stack of a title slide.],
  [`mosaic-cell-authors`], [The author block of a title slide.],
  [`mosaic-cell-details`], [The date and other fine print of a title slide.],
  [`mosaic-cell-section`], [The heading of a section slide.],
  [`mosaic-cell-image`], [The image cell of an image layout.],
)

A theme is expected to style at least `mosaic-cell-title`, `mosaic-cell-section`, and the content cells it uses. A theme that omits one renders that region in the engine's bare defaults, and nothing warns about it.

= Composed tiers

The `title` and `section` layouts are compositions rather than bare grids. Each text tier they emit carries its own label, so a rule reaches it without knowing how the variant is assembled.

#table(
  columns: (auto, 1fr),
  [`mosaic-title-display`], [The display line of a title slide, inside `mosaic-cell-title`. This is where a theme states the title's display size and tracking.],
  [`mosaic-section-number`], [The section numeral of a section slide.],
  [`mosaic-section-title`], [The section's title text.],
  [`mosaic-section-subtitle`], [The section's subtitle, where the variant emits one.],
)

Typography goes through these labels. Geometry does not: the spacers, rules, and offsets a variant composes itself from are produced during layout and no show rule reaches inside them. A size, weight, or color is always a label rule; an arrangement is the variant's design.

= Whole slide and planes

#table(
  columns: (auto, 1fr),
  [`mosaic-slide`], [The entire cell grid of one slide. One rule here reaches every cell at once, which is what light text over a photograph wants. A `mosaic-cell-*` rule still refines it.],
  [`mosaic-background`], [The full-slide plane behind the grid.],
  [`mosaic-foreground`], [The full-slide plane in front of the grid.],
)

= Engine-owned labels

These carry rules from Mosaic itself rather than from a theme. A theme or deck rule on the same label overrides them, but the defaults are deliberate.

#table(
  columns: (auto, 1fr),
  [`mosaic-note-heading`], [The heading on a printed speaker or notes page. Set black on white, because those pages are paper whatever the deck's theme does.],
  [`mosaic-note-body`], [The note text on those same pages.],
  [`mosaic-overflow-warning`], [The diagnostic emitted when content exceeds its cell. Not a styling target.],
)
