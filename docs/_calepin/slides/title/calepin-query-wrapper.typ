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
#import "/_includes/embedded-examples.typ": (
  example-source, slideshow, slideshow-grid,
)
#import "/_includes/site.typ": repo-file

#set document(title: [Title slides])
#metadata((title: "Title")) <website-metadata>

#title()

A title slide takes its content from the deck rather than from the slide, and its arrangement from a variant.

= A simple title slide

Declare the title information once in `m.setup`, then place `m.slide(layout: "title")` where the deck opens:

#example-source("structure/title-simple")

#slideshow(calepin.elements.gallery, "structure/title-simple", 1, "A title slide built from the deck's own information", caption: [The default title slide])

The slide names no content of its own. It reads the title, subtitle, authors, and date straight from `setup`, so the deck states them once and a title slide, a handout header, and the PDF's own metadata all agree.

An author is usually just a name, and `authors:` takes one the way `title:` and `subtitle:` do. Several names go in parentheses, separated by commas:

```typ
authors: ([Ada Lovelace], [Charles Babbage])
```

Wrap a name in `m.layouts.author` when it carries more than itself: an affiliation, an ORCID iD, an email address. The next section does exactly that.

To change one field on one slide, name it on `slide`. This deck opens on a draft date without touching the deck's own:

```typ
#m.slide(layout: "title", date: [Draft])
```

Writing `none` drops an inherited title, subtitle, or date from that slide, and `()` drops the authors.

= Variants

Each variant borrows a classic minimalist tradition. The six text variants need nothing beyond the deck's own information:

- `centered`: the heading stack at the slide's center, details at the bottom edge.
- `bordered`: a thin border closes around a centered stack.
- `ruled`, the default: the heading stack over a full-width accent rule, flush left at the vertical center. The beamer-metropolis title page.
- `kicker`: the magazine masthead: an opening rule, the subtitle as a tracked-caps eyebrow, details at the bottom edge.
- `panel`: an ink side panel carries the details; the heading stack takes the main field.
- `academic`: the conference poster: superscript affiliation numbers, a numbered legend, a contact line. Requires at least one author.

The `image` variant requires an `image` and places a full-bleed picture beside or above the title stack: `position:` is `"left"` (the default), `"right"`, `"top"`, or `"bottom"`, and `tracks` sizes the split. A full-slide photographic title is not a variant; the #link(label("custom-title-page"))[Custom title page] section below composes one by hand.

Every variant renders every field the deck and its authors declare: the title and subtitle, each name with its linked ORCID icon and the corresponding asterisk, the affiliations, the contact addresses, and the date. Choosing a variant changes the arrangement, never the information.

The thumbnails below all render the same title information: one deck title and subtitle, and three authors over two institutions, one of which two of them share. Every author carries an affiliation and an ORCID iD, and one of them is marked corresponding with an email address, so the `academic` legend has something to number and the ORCID icons, the contact line, and the corresponding-author asterisk all have somewhere to land. The contact line lists every author who gave an address, so it can carry more than the corresponding one. Only the variant changes between them, so anything you see move, resize, or change color is the variant's doing rather than the content's.

Written out in full, one of those decks is this:

```typ
#import "@local/mosaic:0.0.1" as m

#let ccp = [Centre for Comparative Politics]
#let eis = [European Institute for Social Data]

#show: m.setup.with(
  title: [The Optimal Number of Naps],
  subtitle: [Findings from a subject who slept through the study],
  authors: (
    m.layouts.author(
      [Priya Nair],
      affiliations: (ccp, eis),
      email: "priya.nair@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    m.layouts.author(
      [Elena García],
      affiliations: (eis,),
      orcid: "0000-0002-1825-0097",
    ),
    m.layouts.author(
      [Tomás Ferreira],
      affiliations: (ccp,),
      orcid: "0000-0003-4567-8901",
    ),
  ),
  date: [Toronto · July 2027],
)

#m.slide(layout: "title", variant: "academic")
```

An affiliation is the institution itself rather than an identifier for it, so two authors land on one legend number exactly when they name the same institution. Binding `ccp` and `eis` once and reusing the bindings is what makes that happen.

The remaining decks are that same file with a different variant on the last line, and the image decks also pass an `image:` wrapped in Typst's `path()`, as #link("configuring.html#asset-paths")[Asset paths] explains.

In your own deck, write the title information directly in `setup`, as the listing above does. The decks on this page keep it in one shared #repo-file("docs/examples/embedded/structure/_title-info.typ")[file] only so the page has a single copy to edit.

Open any thumbnail to see the slide at full size:

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "structure/title-centered", 1, "The shared title information under the centered variant", caption: [`centered`])
  #slideshow(calepin.elements.gallery, "structure/title-bordered", 1, "The shared title information under the bordered variant", caption: [`bordered`])
  #slideshow(calepin.elements.gallery, "structure/title-ruled", 1, "The shared title information under the ruled variant", caption: [`ruled`])
  #slideshow(calepin.elements.gallery, "structure/title-kicker", 1, "The shared title information under the kicker variant", caption: [`kicker`])
  #slideshow(calepin.elements.gallery, "structure/title-panel", 1, "The shared title information under the panel variant", caption: [`panel`])
  #slideshow(calepin.elements.gallery, "structure/title-academic", 1, "The shared title information under the academic variant", caption: [`academic`])
  #slideshow(calepin.elements.gallery, "structure/title-image-left", 1, "The shared title information with the picture on the left", caption: [`image`, `position: "left"`])
  #slideshow(calepin.elements.gallery, "structure/title-image-right", 1, "The shared title information with the picture on the right", caption: [`image`, `position: "right"`])
  #slideshow(calepin.elements.gallery, "structure/title-image-top", 1, "The shared title information with the picture above", caption: [`image`, `position: "top"`])
  #slideshow(calepin.elements.gallery, "structure/title-image-bottom", 1, "The shared title information with the picture below", caption: [`image`, `position: "bottom"`])
]

= Inverted

There is no inverted variant, because inversion is not an arrangement. Pass `invert: true` on any slide to swap that slide's ground and ink: the slide takes the deck's text color as its ground, the type is knocked out in the canvas color, and the muted and line tones follow. Any variant composes with it, and so does any other layout, so an inverted section plate or an inverted big-number slide is the same one flag.

```typ
#m.slide(layout: "title", variant: "kicker", invert: true)
```

#slideshow(calepin.elements.gallery, "structure/title-invert", 1, "The kicker variant inverted: light type on the deck's text color", caption: [`kicker` with `invert: true`])

= Custom title page <custom-title-page>

When no variant draws the page you want, build the slide yourself. `m.info()` returns the `title`, `subtitle`, `authors`, and `date` you declared on `setup`, so the custom slide can use them without repeating them. Each author comes back as a dictionary with `name`, `affiliations`, `email`, `orcid`, and `corresponding` fields. Call `m.info()` inside a `context` block, as the example below does. The same reader also reports where the slide sits in the deck, in its `slide` and `section` fields, which is what hand-built chrome is made of; the #link("../presenting/footer.html")[footer and progress] page covers that side of it.

The deck below composes a full-slide photograph on the slide's `background:` plane, anchors the heading to the top edge, and pins the byline to the bottom, an arrangement no built-in variant draws:

#example-source("structure/title-custom")

#slideshow(calepin.elements.gallery, "structure/title-custom", 1, "A hand-built cover: full-slide photograph, heading at the top edge, byline at the bottom", caption: [A custom cover from `m.info()`])

The `scrim:` on the background image quiets the photograph exactly as it does on the image variants, and `numbered: false` keeps the cover out of the slide count the way named title layouts stay out of it automatically.
