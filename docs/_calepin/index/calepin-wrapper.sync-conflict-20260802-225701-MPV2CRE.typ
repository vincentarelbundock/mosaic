#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "7128243e19958bc4-1349cde127705c16"
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

#set document(title: [Mosaic])
#metadata((
  title: "Home",
  layout: "layouts/site-landing.html",
  toc: (enabled: false),
)) <website-metadata>

#calepin.elements.target(
  html: () => [
    #html.elem("section", attrs: (class: "mosaic-hero"))[
      #html.elem("div")[
        #html.elem("h1")[
          Create beautiful
          #html.elem("br")
          slides with
          #html.elem("span", attrs: (
            class: "mosaic-hero__typst-box",
          ))[
            #html.elem("img", attrs: (
              class: "mosaic-hero__typst-logo",
              src: "assets/typst.svg",
              alt: "Typst",
            ))
          ]
        ]
        #html.elem("p")[
          Write a deck as an ordinary Typst document. Each slide is a grid of
          cells between a background and foreground plane. Mosaic labels the
          cells; you style them with native Typst show and set rules.
        ]
      ]
      #html.elem("img", attrs: (
        class: "mosaic-slide-demo",
        src: "assets/mosaic-slide.svg",
        alt: "Mosaic slide with a slim orange title band above asymmetric blue and green columns",
      ))
    ]
    #html.elem("nav", attrs: (
      class: "mosaic-actions mosaic-home-links",
      "aria-label": "Explore Mosaic",
    ))[
      #html.elem("a", attrs: (
        class: "mosaic-button mosaic-button--secondary",
        href: "basics.html",
      ))[Get started]
      #html.elem("a", attrs: (
        class: "mosaic-button mosaic-button--secondary",
        href: "examples.html",
      ))[Examples]
      #html.elem("a", attrs: (
        class: "mosaic-button mosaic-button--secondary",
        href: "api/setup.html",
      ))[API]
    ]
    #html.elem("section", attrs: (class: "mosaic-feature-showcase"))[
      #html.elem("div", attrs: (class: "mosaic-feature-cards"))[
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Layouts]
          #html.elem("p")[
            Default, title, and section layouts, with matching typography and
            explicit accent controls.
          ]
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Grids]
          #html.elem("p")[
            Every slide is a grid: a tree of cells split horizontally or
            vertically, nested as deeply as needed.
          ]
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Native styling]
          #html.elem("p")[
            Cells, background, and foreground are native Typst layers, and
            every cell has a stable label. Style them with ordinary show and
            set rules, not a separate API.
          ]
        ]
      ]
      #html.elem("div", attrs: (class: "mosaic-showcase-frame"))[
        #html.elem("video", attrs: (
          class: "mosaic-showcase mosaic-showcase--video",
          autoplay: "autoplay",
          loop: "loop",
          muted: "muted",
          playsinline: "playsinline",
          poster: "assets/examples/structure/title-layout-1.svg",
          "aria-label": "Animated gallery of Mosaic title slides, native styling, and incremental diagrams",
        ))[
          #html.elem("source", attrs: (
            src: "assets/images/showcase.webm",
            type: "video/webm",
          ))
        ]
        #html.elem("img", attrs: (
          class: "mosaic-showcase mosaic-showcase--poster",
          src: "assets/examples/structure/title-layout-1.svg",
          alt: "Example of an academic title slide made with Mosaic",
        ))
      ]
    ]
  ],
  fallback: () => [
    = Slides with Typst

    Write a deck as an ordinary Typst document. Each slide is a grid of cells
    between a background and foreground plane. Mosaic labels the cells; you
    style them with native Typst show and set rules.
  ],
)
