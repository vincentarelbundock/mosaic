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
#import "@preview/tidy:0.4.3"

#set document(title: [API reference])
#metadata((
  title: "API reference",
  description: "Every exported Mosaic function, grouped by reference page.",
)) <website-metadata>

#title()

Every exported function and variable, grouped by reference page. Each name
links to its full documentation: signature, parameter types, defaults, and
descriptions.

#let pages = (
  (
    title: "Document setup",
    href: "api/setup.html",
    sources: ("/api/modules/setup.typ",),
  ),
  (
    title: "Theme authoring",
    href: "api/theme.html",
    sources: ("/api/modules/theme-extension.typ",),
  ),
  (
    title: "Slides",
    href: "api/slides.html",
    sources: (
      "/api/modules/slide-command.typ",
      "/api/modules/note-command.typ",
      "/api/modules/surface.typ",
      "/api/modules/fit.typ",
    ),
  ),
  (
    title: "Incremental steps",
    href: "api/steps.html",
    sources: (
      "/api/modules/incremental-command.typ",
      "/api/modules/pause-command.typ",
    ),
  ),
  (
    title: "mosaic.grids constructors",
    href: "api/grids.html",
    sources: ("/api/modules/grid-constructors.typ",),
  ),
  (
    title: "Semantic layouts",
    href: "api/layouts.html",
    sources: (
      "/api/modules/author.typ",
      "/api/modules/layout-content.typ",
      "/api/modules/layout-image.typ",
      "/api/modules/layout-title.typ",
      "/api/modules/layout-section.typ",
    ),
  ),
  (
    title: "Components and furniture",
    href: "api/components.html",
    sources: (
      "/api/modules/component-card.typ",
      "/api/modules/component-callout.typ",
      "/api/modules/component-badge.typ",
      "/api/modules/component-quote.typ",
      "/api/modules/component-divider.typ",
      "/api/modules/component-progress.typ",
      "/api/modules/image.typ",
      "/api/modules/component-figure.typ",
    ),
  ),
)

#let page-entries(page) = {
  let module = tidy.parse-module(page.sources.map(read).join("\n"))
  let entries = ()
  for fn in module.functions {
    if fn.name.starts-with("_") { continue }
    entries.push(link(page.href + "#" + fn.name, raw(fn.name + "()", lang: none)))
  }
  for variable in module.variables {
    if variable.name.starts-with("_") { continue }
    entries.push(link(page.href + "#" + variable.name, raw(variable.name, lang: none)))
  }
  entries
}

#list(..pages.map(page => [
  #link(page.href)[*#page.title*]
  #list(..page-entries(page))
]))

#link("api/labels.html")[*Labels*] lists every label a rendered slide emits, which is the surface a deck or a theme writes `show` rules against.
