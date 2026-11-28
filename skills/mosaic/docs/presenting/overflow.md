# Overflow and fitting

> **Requires Mosaic 0.0.3.** Breakable slides are new: `setup(breakable:)` and `slide(breakable:)` do not exist in the released version. This is the development version, which is not on Typst Universe yet: a deck that uses it imports `@local/mosaic:0.0.3` rather than the released `@preview/mosaic:0.0.2`. See [Install](../start/install.md).

A cell does not resize its content. A body larger than its cell is drawn past the edge, so a slide that holds too much fails silently on screen rather than at compile time. Before presenting, run a checking compile to find those slides, and scale the rare indivisible block with `m.fit`. A slide whose content is long by nature, such as a list of references, can instead break onto continuation pages.

## Inspecting overflowing cells

Overflow observation is off by default, because measuring every cell on every frame roughly doubles the layout work a deck does. It is a checking pass, not something to leave on while you write. The usual way to run it is to set `overflow: "error"` on `setup` and compile once before presenting: Mosaic renders the whole deck, then fails naming every overflowing cell with its slide and frame.

For tooling that would rather read the records than stop the build, `setup(overflow: "record")` emits them and keeps compiling:

```sh
typst eval \
  'query(<mosaic-overflow-warning>).map(it => it.value)' \
  --in slides.typ
```

Each record identifies the slide, frame, cell, and measured height. Typst gives a package no warning channel, so `"record"` prints nothing on its own; see the [Setup API](../api/setup.md).

An overflow means the slide holds more than it can show. The remedy is editorial: cut a bullet, split the slide in two, or move to a layout with more room. Mosaic deliberately offers no automatic shrink-to-fit for body content, because a deck whose type size is decided slide by slide loses the scale that holds it together.

## Fitting a block to its cell

When a single indivisible block is the problem, a wide table, a chart, or a generated list, scale that one block with `m.fit` and leave the deck's typography alone:

```typ
#m.slide[== Regression results][
  #m.fit(my-table)
]
```

It measures the block against the space its cell gives it, scales it geometrically, and reflows the surrounding layout around the new size. Shrinking is the default, and it takes no hand-picked factor, so the block stays within the cell when the table gains a row. `grow: true` also scales content up, which is how a single number or word fills a cell.

The block is offered the cell's width first, so text and lists wrap and are then scaled only if they are still too tall. A table or diagram given a narrower width rearranges itself instead of shrinking, so `wrap: false` measures and scales it as written.

`width:` and `height:` fit to part of the region instead of all of it, and take a length, ratio, or fraction. A fitted block cannot overflow, so it no longer appears in the overflow records.

Measuring a block means holding it inside a closure, which the slide runtime cannot look into. `m.steps.pause`, `m.steps`, and `m.note` are found by walking the slide's content, so inside a fitted block they would be invisible: the reveals would collapse into one frame and the notes would never reach the speaker output. `m.fit` reports that as an error instead. Keep them outside the fitted block, or fit each revealed part on its own. [Where steps work](../incremental/steps.md#where-steps-work) lists the other places the runtime cannot see into.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup
#set text(size: 22pt)

#let estimates = table(
  columns: 8,
  align: (left, right, right, right, right, right, right, right),
  inset: 0.6em,
  table.header(
    [Specification], [Estimate], [Std. error], [#math.equation(alt: "t", $t$)], [#math.equation(alt: "p", $p$)],
    [CI lower], [CI upper], [Observations],
  ),
  [Baseline], [0.412], [0.081], [5.09], [\<0.001], [0.253], [0.571], [12,480],
  [With covariates], [0.386], [0.079], [4.89], [\<0.001], [0.231], [0.541], [12,480],
  [Region fixed effects], [0.344], [0.092], [3.74], [\<0.001], [0.164], [0.524], [12,480],
  [Region and year effects], [0.351], [0.095], [3.69], [\<0.001], [0.165], [0.537], [12,480],
)

// The table is wider than the cell. `wrap: false` keeps its columns as written
// and scales the whole block, instead of letting the table re-lay out narrower.
#m.slide[][
  == Regression results

  #m.fit(wrap: false, estimates)
]

// The other direction: display type scaled up until it fills the cell.
#m.slide[][
  == Response rate

  #m.fit(grow: true)[42%]
]
```

See the [Slides API](../api/slides.md) for the full `m.fit` signature.

## Breakable slides

A breakable slide continues on as many pages as its body needs, the way a document page does. Every continuation page repeats the slide's header and footer, and its background and foreground, and the body picks up where the previous page left off. It is the remedy for content that is long by nature and that you would otherwise split by hand, such as a bibliography.

Breaking is off by default, because a slide that grows a page without asking hides the overflow you would want to hear about. Turn it on for one slide:

```typ
#import "@local/mosaic:0.0.3" as m
#show: m.setup

#m.slide(breakable: true)[== References][
  #bibliography("refs.bib", title: none)
]
```

Or for the whole deck, with `setup(breakable: true)`. Under the deck-wide switch every slide that can break does, and the others stay ordinary fixed frames; `slide(breakable: false)` keeps one slide fixed.

```typ
#import "@local/mosaic:0.0.3" as m
#show: m.setup.with(breakable: true)

== References
#bibliography("refs.bib", title: none)
```

The continuation pages belong to one logical slide. `m.info().slide.number` reports the same number on each of them, so a footer that prints the slide number shows it unchanged, while the physical page number advances.

### What can break

A breakable slide has limits, each because the frame no longer has one fixed size:

- **Content slides only.** The slide's grid must be a stack of rows, with one flowing row between header and footer rows sized to their content, which is what every built-in content layout builds. A title, section, or image slide does not break, nor does a custom grid of another shape, one that draws rules between its rows, or one whose row gutter is a fraction.
- **Columns break together.** On a content layout with several `columns:`, each column continues on the next page beside the others.
- **One step.** A slide that reveals in steps (`m.steps.pause`, `m.steps`, or a grid `on` node) does not break, because every step would need its own run of pages.
- **The `slides` output only.** The `speaker`, `notes`, and `split` outputs draw each frame as a fixed thumbnail, so there a breakable slide is an ordinary frame and its overflow is drawn past the edge.
- **Only the flowing row breaks.** The header and footer repeat on every page, so they must leave the body room on one page. A slide whose header alone outgrows the frame does not break. A slide with a single body runs into this, because that body fills the header, the first cell; write `[== Title][..]` or name the cell with `cells: (body: ..)`.
- **Content breaks where Typst can break it.** Text breaks between lines, and lists, bibliographies, and tables break between their rows. An indivisible block taller than the page, such as an image or a block scaled with `m.fit`, still overflows.
- **The body takes its content's height.** A slide that fits renders exactly as a fixed slide would; one that overflows sizes its body to the content on each page, so a vertically centered body sits at the top and a body fill ends where the content does on the last page.
- **Notes stay on the first page.** Speaker notes attach to the slide's first page; the continuation pages carry none.
- **No overflow records once it breaks.** The flowing body has no fixed region to overflow, so `setup(overflow:)` does not observe a slide that paginates. A breakable slide drawn as a fixed frame is observed like any other.

`slide(breakable: true)` on a slide that cannot break is an error that names the reason. Under `setup(breakable: true)` the same slide is left as a fixed frame without a word, so a deck-wide switch never turns every title slide into an error; run the overflow check above to find the ones that still do not fit.
