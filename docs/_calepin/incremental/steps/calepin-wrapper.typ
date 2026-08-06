#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "f929bbe71a10d12f-1349cde127705c16"
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
#set document(title: [Steps and pauses])
#metadata((title: "Steps and pauses")) <website-metadata>

#title()

You write one slide; Mosaic can reveal, replace, or remove parts of it over a sequence of *frames*. Each frame is one page of the compiled document, and all frames of one slide share its slide number.

The features and API described in this section were heavily influenced by the #link("https://touying-typ.github.io/docs/intro")[Touying package].

= Commands

Every slide starts at step 1. Mosaic adds frames until the last timed command has run. Hidden content keeps its space by default, so the rest of the slide stays still. Use `before: "removed"` when surrounding content should expand into that space.

Choose the smallest command for the timing you need:

- `m.pause` advances subsequent source-order content to the next frame.
- `m.steps.on(range)[content]` shows content over an exact step range.
- `m.steps.reveal[...]` accumulates a list or sequence one item at a time.
- `m.steps.replace[first][second]` swaps alternatives in one stable slot.
- `m.steps.drawing` connects the same timing model to custom structures.

The #link("reveals.html")[Reveal and replace] page shows each of these on real slides.

= Pause between blocks

Use `m.pause` when source order already expresses the reveal order:

```typ
#m.slide[
  The estimate is positive.

  #m.pause

  The interval excludes zero.
]
```

The first frame contains only the estimate. The second retains the estimate and adds the interval. Pauses are scoped to their containing content stream, so they also work inside blocks, fixed grid cells, and background or foreground planes. If a segment contains `m.steps.reveal`, `m.steps.replace`, or another explicit timing command, that segment completes before the following segment starts. Empty leading, trailing, or consecutive pause markers never create blank frames.

A pause inside one column of a two-column slide therefore delays that column's content without disturbing the other:

```typ
#m.slide(layout: "content", columns: 2)[== The categorical imperative][
  #m.components.quote(
    [Act as if the maxim of your action were to become a universal law.],
    attribution: [Kant],
  )
][
  #m.pause
  #m.components.quote([Kant touch this.], attribution: [MC Hammer])
]
```

= Hold back a whole block

To open a slide on its title alone, or on one column alone, hold the rest back with `m.steps.on("2-")`. A leading `m.pause` does not work here: a pause with nothing before it in its content stream is collapsed, so the content would appear on frame 1. An explicit range forces the second frame, and because `before` defaults to `"hidden"`, the space is kept and the slide does not jump when the content arrives:

```typ
== Consequences and remedies

What could be done about each of these?

#m.steps.on("2-")[
  - Subsidies for pro-social behavior
  - Pigouvian taxes
  - Quotas
]
```

The first frame shows the title and the question. The second frame reveals the list. The same command holds back one full column of a two-column slide while the other stays visible from the first frame.
