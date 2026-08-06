#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "e554db73300778d6-1349cde127705c16"
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
  example-source, slideshow, slideshow-grid,
)
#import "/_includes/site.typ": repo-file

#set document(title: [Colors])
#metadata((title: "Colors")) <website-metadata>

#title()

Every color in a Mosaic deck flows from one palette: a flat dictionary of eight colors that the theme supplies, `setup(colors: ..)` overrides, and every layout and component reads. This page covers the three ways to work with it: override individual entries, swap in one of the bundled palettes, or invert a single slide.

= Overriding colors

Each theme supplies a complete color palette. Override only the deck-wide colors that need to change; omitted colors keep the theme defaults:

```typ
#show: m.setup.with(colors: (
  canvas: rgb("#f4f8f7"),
  accent: rgb("#007f73"),
))
```

The palette holds eight entries: six name the deck's own surfaces and text, two name the status colors that components paint with:

#table(
  columns: (auto, 1fr),
  [`canvas`], [The page fill behind every slide.],
  [`surface`], [Raised panels: the fill a neutral card or badge sits on.],
  [`text`], [Body text.],
  [`muted`], [Secondary text: captions, footers, fine print.],
  [`line`], [Drawn rules, borders, and dividers.],
  [`accent`], [The deck's emphasis color.],
  [`warning`], [A remark that qualifies what is on the slide.],
  [`error`], [A remark that contradicts it.],
)

Unknown names and non-color values are errors. The canvas, typography, components, and layouts all use the resolved values. Explicit component colors remain local overrides:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body"),
  foreground: [
    #place(bottom + left)[
      #m.components.progress(
        variant: "line",
        width: 100%,
        accent: rgb("#e69f00"),
      )
    ]
  ],
)[Title][Body]
```

Native rules after `m.setup` are still the right tool for typography or a special local composition:

```typ
#[
  #show label("mosaic-cell-body"): set text(fill: white)
  #m.slide(
    background: block(width: 100%, height: 100%, fill: rgb("#111827")),
  )[Dark for this slide only]
]
```

Color collections remain ordinary Typst arrays. Define them near the chart or diagram that uses them, or import a color package. A component's `role:` names one palette entry, so recoloring the palette recolors every `card`, `badge`, and `quote` that uses it.

To recolor an entire slide at once, use the `<mosaic-slide>` label described under #link("styling.html#styling-a-whole-slide")[Styling a whole slide].

= Bundled palettes

Beyond per-entry overrides, every facade exports `palettes`, a curated collection of complete color schemes in one Japandi voice: oat and greige grounds, wood-tone and dried-plant accents, and status colors that whisper. Each entry is the same flat eight-color dictionary `colors:` accepts, so any of them repaints any theme with one line:

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(colors: m.palettes.espresso)
```

#table(
  columns: (auto, 1fr),
  [`light`], [The default light palette, applied when a deck names no colors.],
  [`dark`], [The bundled dark polarity twin of `light`.],
  [`parchment`], [Barely-oat paper with espresso ink and a walnut accent.],
  [`sage`], [Cool daylight with the faintest green cast and a dried-sage accent.],
  [`stone`], [Faintly warm greige with a muted indigo accent.],
  [`espresso`], [Roasted brown-black with a pale wood accent.],
  [`forest`], [Moss night with a dried-sage accent.],
  [`slate`], [Blue-gray charcoal warmed by a wood accent.],
)

Every bundled palette is held to a tested contrast contract: body and muted text stay readable on the canvas, the accent and status colors stay legible on both the canvas and on an inverted slide's swapped ground, and rules stay visible without turning into ink. Your own palettes face no such gate. Whatever dictionary you pass to `colors:` is applied as given, and the bundled entries are ordinary dictionaries, so `m.palettes.espresso + (accent: ..)` extends one exactly like the partial overrides above.

= One deck, every palette

The galleries below all render the same five-slide deck under the default theme: a title slide, a content slide with a list, a code block, and a warning callout, a section slide, a components slide with a table, badges, and a card, and one inverted slide. Only the `colors:` line changes between them, so anything that shifts from gallery to gallery is the palette's doing rather than the theme's or the content's.

The deck lives in one #repo-file("docs/examples/embedded/appearance/_palette-deck.typ")[shared file] exporting a single `deck` function, exactly like the running example on the #link("themes.html")[Themes] page. Each wrapper imports it, names one bundled palette, and renders:

#example-source("appearance/palette-espresso")

The dark schemes swap in the dark syntax highlighting theme on their own; polarity is read off the canvas each palette supplies, never declared. Component panels tint their role colors into whichever canvas the palette brings, so the callout and badges stay quiet washes in every scheme.

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/palette-light", 5, "The palette deck on the default light palette", caption: [`light`])
  #slideshow(calepin.elements.gallery, "appearance/palette-dark", 5, "The palette deck on the bundled dark palette", caption: [`dark`])
  #slideshow(calepin.elements.gallery, "appearance/palette-parchment", 5, "The palette deck on the parchment palette", caption: [`parchment`])
  #slideshow(calepin.elements.gallery, "appearance/palette-sage", 5, "The palette deck on the sage palette", caption: [`sage`])
  #slideshow(calepin.elements.gallery, "appearance/palette-stone", 5, "The palette deck on the stone palette", caption: [`stone`])
  #slideshow(calepin.elements.gallery, "appearance/palette-espresso", 5, "The palette deck on the espresso palette", caption: [`espresso`])
  #slideshow(calepin.elements.gallery, "appearance/palette-forest", 5, "The palette deck on the forest palette", caption: [`forest`])
  #slideshow(calepin.elements.gallery, "appearance/palette-slate", 5, "The palette deck on the slate palette", caption: [`slate`])
]

= Inverting one slide

The last slide of every gallery above is the same command:

```typ
#m.slide(invert: true)[
  One inverted slide for the headline number.
]
```

`invert: true` swaps ground and ink within the active palette for that slide only: the canvas becomes the palette's text color, the text becomes its canvas, and muted, line, and surface are derived to match. The accent and status colors carry over unchanged, which is why a badge or callout keeps its color on the swapped ground. That survival is part of the bundled palettes' tested contract, so `invert:` composes with every scheme in the collection; a custom palette whose accent only reads on its own canvas will look washed out here, and passing a hand-picked palette to that one slide's components is the escape hatch.
