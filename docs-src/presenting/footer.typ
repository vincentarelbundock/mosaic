#import "/.calepin/calepin.typ" as calepin
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

#calepin.elements.callout(kind: "warning", title: [Changed in Mosaic 0.0.2])[
  From 0.0.2, which is not on Typst Universe yet, the component quiets itself on pages where its counter has no meaningful reading: a slides count on unnumbered slides (titles and sections), and a sections count before the first section slide. A bare `progress()` in a deck foreground is therefore already correct page-number chrome, and a `quiet:` argument overrides the rule (`false` always displays, `true` silences every unnumbered page). In the released `0.0.1` the component always displays, so a foreground indicator needs the `slide.numbered` guard shown at the bottom of this page. One command installs the development version — `curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh` — and then it imports as `#import "@local/mosaic:0.0.2" as m`. See #link("../start/install.html")[Install] for the full instructions.
]

The deck below puts a bare counter in the setup foreground and nothing else. The counter appears on the two content slides and stays quiet on the title and section pages, with no guard written anywhere; sizing comes from an ordinary `text` rule around the component, and a one-off color would go through its `accent:` argument rather than a text rule, because the component paints its own ink from the theme role:

#embedded-example(
  calepin.elements.gallery,
  "furniture/quiet-footline",
  frames: 4,
  title: "A bare foreground counter, quiet on the title and section pages",
  renderer: thumbnail-gallery,
)

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
