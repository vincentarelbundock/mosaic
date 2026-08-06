#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "54c35f6a8aef2022-1349cde127705c16"
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
  slideshow,
  thumbnail-gallery,
)

#set document(title: [Footer and progress])
#metadata((title: "Footer and progress")) <website-metadata>

#title()

= Default footer content

Most decks repeat the same source, event name, or organization in every ordinary slide footer. Declare that value once in setup:

```typ
#show: m.setup.with(
  cells: (
    footer: [Mosaic · Engineering],
  ),
)
```

The default applies whenever the slide's layout contains a cell named `footer`. A title slide has no such cell, so it is unaffected. With a default footer, positional content supplies only the remaining cells:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
)[RESULTS][Main result]
```

Named content can likewise omit `footer`. An explicit value overrides the deck default, while `none` suppresses it on one slide:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  cells: (
    header: [APPENDIX],
    body: [Supporting details],
    footer: none,
  ),
)
```

A complete positional body list remains valid and overrides every corresponding default. The footer is an ordinary cell, and there is no separate global footer feature, so footers cannot overlap slide numbers, progress indicators, or the slide body.

#embedded-example(
  calepin.elements.gallery,
  "structure/setup-content",
  frames: 3,
  title: "A default footer, a slide override, and explicit suppression",
  renderer: thumbnail-gallery,
)

= Progress

`m.components.progress()` shows the current position in a deck. All frames from one incremental slide share the same slide number. Use `"1/1"` or `"1"` for numbers, `"circle"` for a compact indicator, and `"line"` for a full-width bar.

A recurring progress line along the bottom edge is one foreground entry in setup. The foreground plane is already a full-slide block, so `align` alone places the bar, and because the plane takes no space from the grid, the line does not shrink the slide body:

```typ
#show: m.setup.with(
  foreground: align(bottom, m.components.progress(variant: "line")),
)
```

#embedded-example(
  calepin.elements.gallery,
  "furniture/slide-numbering",
  frames: 2,
  title: "Logical and physical numbering",
)

#embedded-example(
  calepin.elements.gallery,
  "blocks/progress-numbers",
  frames: 3,
  title: "Foreground numbering with components.progress()",
)

#slideshow(
  calepin.elements.gallery,
  "blocks/progress-line",
  3,
  "Foreground line with components.progress()",
)

The component can sit in a foreground, a cell, or another Typst container. This example adds a foreground bar to a custom grid:

#embedded-example(
  calepin.elements.gallery,
  "blocks/progress-custom-layout",
  frames: 3,
  title: "A reusable custom-grid slide function with foreground progress",
)

= What the deck knows about itself

When a footline needs more than one indicator, read the deck directly. `m.info()` is a contextual reader returning everything the deck knows about itself: what the deck declared on setup, and where the slide being rendered sits. It is the same reading `m.components.progress()` does, so a hand-built bar and the component can never print different numbers.

```typ
#context {
  let deck = m.info()
  [#deck.section.title #h(1fr) #deck.slide.number/#deck.slide.total]
}
```

The record has six fields. Four are the deck metadata, exactly as setup received it:

#table(
  columns: (auto, 1fr),
  [`title`], [The deck title.],
  [`subtitle`], [The deck subtitle.],
  [`authors`], [Always an array of resolved author records, whether the deck wrote a bare name or a full `m.layouts.author` record. Each carries `name`, `affiliations`, `email`, `orcid`, and `corresponding`.],
  [`date`], [The deck date.],
)

Two are the position of the slide being rendered, which is what makes the reader contextual:

#table(
  columns: (auto, 1fr),
  [`slide.number`], [This slide's logical number. All frames of one incremental slide share it, and unnumbered slides report `0`.],
  [`slide.total`], [The deck's final count of logical slides.],
  [`slide.numbered`], [Whether this slide counts. Titles and sections are unnumbered by default, and `numbered:` on the slide decides it. This is the switch that keeps a folio or a counter off a cover.],
  [`section.number`], [The number of the section this slide is in, counting slides that use the `section` layout. Before the first section slide it is `0`.],
  [`section.total`], [The deck's final section count.],
  [`section.title`], [That section's own text, with any heading stripped, or `none` before the first section slide. A section slide reports its own section, not the previous one.],
)

Because `slide.numbered` says whether the slide counts, a footline can hold its counter slot clear on a cover rather than printing a zero into it:

```typ
#context {
  let deck = m.info()
  if deck.slide.numbered [#deck.slide.number/#deck.slide.total]
}
```

Reading the position rather than counting for yourself is what keeps a theme's chrome honest across handouts and incremental frames, which is why the #link("../examples.html")[AnnArbor] deck's headline and footline are both one `m.info()` call.
