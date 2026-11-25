#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  slideshow,
  thumbnail-gallery,
)

#import "/_includes/site.typ": unreleased

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

The default applies whenever the slide's layout contains a cell named `footer`. A title slide has no such cell, so it is unaffected. Positional bodies fill the cells in order, header, body, footer, so a slide that supplies two keeps the deck footer:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
)[== Results][Main result]
```

A third block would replace the footer on that slide. Named content can likewise omit `footer`, and it combines with positional bodies. An explicit value overrides the deck default, while `none` suppresses it on one slide:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  cells: (footer: none),
)[== Appendix][Supporting details]
```

The footer is an ordinary cell, and there is no separate global footer feature, so footers cannot overlap slide numbers, progress indicators, or the slide body.

#embedded-example(
  calepin.elements.gallery,
  "structure/setup-content",
  frames: 3,
  title: "A default footer, a slide override, and explicit suppression",
  renderer: thumbnail-gallery,
)

= Progress

`m.components.progress()` shows the current position in a deck. All frames from one incremental slide share the same slide number. Use `"1/1"` or `"1"` for numbers, `"circle"` for a compact indicator, and `"line"` for a full-width bar.

#unreleased(calepin.elements.callout)[The component quiets itself on pages where its counter has no meaningful reading: a slides count on unnumbered slides (titles and sections), and a sections count before the first section slide. A bare `progress()` in a deck foreground is therefore already correct page-number chrome, and a `quiet:` argument overrides the rule (`false` always displays, `true` silences every unnumbered page). In the released `0.0.1` the component always displays, so a foreground indicator needs the `slide.numbered` guard shown at the bottom of this page. Four further things on this page are new: positional bodies fill every cell in order, `cells:` combines with positional bodies, `slide.number` is `none` on an unnumbered slide, and the `m.appendix` marker for backup slides.]

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

== Backup slides

Slides kept for questions should not inflate the total the audience sees. Write `#m.appendix` once, between the last slide of the talk and the first backup slide:

```typ
== Conclusion
Thank you.

#m.appendix

= Backup
== Robustness checks
```

The totals stop at the marker, so the footer counts the talk: "12 / 30" on slide 12, and "31 / 30" on the first backup slide, which keeps its own number for a question that refers to it. Sections work the same way. A progress bar or circle stays full on backup slides, and the `toc` section variant lists only the talk's sections. `m.info()` reports the same totals, so a hand-built footline follows too.

The marker is content, not a function call, so it takes no parentheses. Written inside a slide it is an error, and so is a second marker.

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
  [`slide.number`], [This slide's logical number. All frames of one incremental slide share it. It is `none` on an unnumbered slide, which has no number of its own.],
  [`slide.total`], [The deck's final count of logical slides.],
  [`slide.numbered`], [Whether this slide counts. Titles and sections are unnumbered by default, and `numbered:` on the slide decides it. This is the switch that keeps a folio or a counter off a cover.],
  [`section.number`], [The number of the section this slide is in, counting slides that use the `section` layout. Before the first section slide it is `0`.],
  [`section.total`], [The deck's final section count.],
  [`section.title`], [That section's own text, with any heading stripped, or `none` before the first section slide. A section slide reports its own section, not the previous one.],
)

Because `slide.numbered` says whether the slide counts, a footline can hold its counter slot clear on a cover rather than printing a number that is not the cover's:

```typ
#context {
  let deck = m.info()
  if deck.slide.numbered [#deck.slide.number/#deck.slide.total]
}
```

Reading the position rather than counting for yourself is what keeps a theme's chrome honest across handouts and incremental frames, which is why the #link("../examples.html")[AnnArbor] deck's headline and footline are both one `m.info()` call.
