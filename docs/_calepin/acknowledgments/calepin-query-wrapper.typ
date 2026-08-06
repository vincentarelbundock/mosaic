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

#set document(title: [Acknowledgments])
#metadata((
  title: "Acknowledgments",
  description: "Projects, authors, and discussions that informed Mosaic.",
)) <website-metadata>

= Acknowledgments

Mosaic is small because it builds on ideas, tools, and design work shared by the Typst community. This page records the sources that directly informed Mosaic's implementation. Full copyright and license notices remain in
#link("https://github.com/vincentarelbundock/mosaic/blob/main/THIRD_PARTY_LICENSES.md")[`THIRD_PARTY_LICENSES.md`].

== Counter and state freezing

Mosaic's selected counter and state freezing was informed by
#link("https://github.com/touying-typ/touying")[Touying] 0.7.4, particularly its
`_rewind-states` helper and subslide preamble at
#link("https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/core.typ#L5602-L5609")[commit `a8abe0d`].
Credit goes to the Touying project and its contributors for demonstrating the practical pre-slide snapshot and continuation-frame rewind technique.

Mosaic narrows that technique to explicitly selected objects and uses a lexical pre-slide location suited to its own renderer. That avoids freezing unrelated Typst or Mosaic state and keeps repeated logical slides convergence-safe.

The underlying problem and Typst's introspection model are further explained in Laurenz Mädje's article
#link("https://laurmaedje.github.io/posts/frozen-state/")[*Frozen State*].
The community discussion in
#link("https://github.com/typst/typst/issues/1841")[Typst issue #1841] also
helped establish why presentation subframes need deliberate counter and state semantics.

== Fitting utilities

Parts of Mosaic's explicit cell-fitting implementation are adapted from Touying 0.7.4 at the same pinned commit. Touying credits related work to Andreas Kröpelin through
#link("https://github.com/andreasKroepelin/polylux/pull/91")[Polylux PR #91]
and to ntjess. Mosaic preserves these credits in its source and third-party license notices.

== Tutorial colors

The explicit color arrays in several tutorials use the Okabe-Ito Color Universal Design palette. Source attribution is recorded in the full third-party notices.

== Example decks

The example presentations on the #link("examples.html")[Examples] page are each adapted from a freely licensed source. The *Editorial*, *Manifesto*, and *Photojournalist Portfolio* decks are Mosaic/Typst re-creations of designs published by
#link("https://www.slidescarnival.com/")[SlidesCarnival], with photographs
credited on the source templates to Pexels and Pixabay.

SlidesCarnival templates are distributed under the
#link("https://creativecommons.org/licenses/by/4.0/")[Creative Commons
Attribution 4.0 International (CC BY 4.0)] license. The decks have been adapted, and attribution is preserved here and in the full third-party license notices.

The *Metropolis* deck adapts the demonstration slides of the
#link("https://github.com/matze/mtheme")[Metropolis Beamer theme] by Matthias
Vogelgesang, distributed under the
#link("https://creativecommons.org/licenses/by-sa/4.0/")[Creative Commons
Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)] license. The adaptation is offered under the same license.

== Toolchain

Mosaic is built with #link("https://typst.app/")[Typst]. Its documentation site is generated with #link("https://github.com/vincentarelbundock/calepin")[Calepin]. We are grateful to both projects and their contributors.
