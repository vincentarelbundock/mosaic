#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Reveal or replace])
#metadata((title: "Reveal or replace")) <website-metadata>

#title()

After composing a slide's body, foreground, and background, timing controls what the audience sees in each frame. With Mosaic, you write one logical slide and reveal, replace, or remove parts of it over a sequence of frames.

The features and API described on this page were heavily influenced by the excellent #link("https://touying-typ.github.io/docs/intro")[Touying package].

= Commands

Every logical slide starts at step 1. Mosaic adds frames until the last timed command has run. Hidden content keeps its space by default, so the rest of the slide stays still. Use `before: "removed"` when surrounding content should expand into that space.

Choose the smallest command for the timing you need:

- `m.pause` advances subsequent source-order content to the next frame.
- `m.steps.on(range)[content]` shows content over an exact step range.
- `m.steps.reveal[...]` accumulates a list or sequence one item at a time.
- `m.steps.replace[first][second]` swaps alternatives in one stable slot.
- `m.steps.reduce` connects the same timing model to custom structures.

== Pause between blocks

Use `m.pause` when source order already expresses the reveal order:

```typ
#m.slide[
  The estimate is positive.

  #m.pause

  The interval excludes zero.
]
```

The first frame contains only the estimate. The second retains the estimate and adds the interval. Pauses are scoped to their containing content stream, so they also work inside blocks, fixed grid cells, and background or foreground planes. If a segment contains `m.steps.reveal`, `m.steps.replace`, or another explicit timing command, that segment completes before the following segment starts. Empty leading, trailing, or consecutive pause markers never create blank frames.

= Reveal bullets

Wrap a list in `m.steps.reveal` to show one more item on each step.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-bullets",
  frames: 3,
  title: "Reveal a list one item at a time",
)

= Reveal cells

Revealed grid cells can start removed, allowing visible cells to use the space until the next panel arrives.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-cells",
  frames: 3,
  title: "Add comparison cells progressively",
)

= Reveal text

Use `m.steps.on` for a word, sentence, or other element that appears only at selected steps. Ranges may be integers, open ranges such as `"3-"`, or closed ranges such as `"2-4"`; `before` and `after` control the surrounding steps.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-text",
  frames: 4,
  title: "Control when text appears",
)

= Replace content

Use `m.steps.replace` to revise a word or larger fragment without moving surrounding content; the largest alternative determines the stable slot.

#embedded-example(
  calepin.elements.gallery,
  "incremental/replace-content",
  frames: 3,
  title: "Revise content in a stable position",
)

= Equations

The same timing commands can annotate parts of an equation without moving the surrounding math.

#embedded-example(
  calepin.elements.gallery,
  "blocks/incremental-math",
  frames: 4,
  title: "Annotate an equation one part at a time",
)

= CeTZ drawings

Draw a figure progressively when you want to explain its geometry in the order it is constructed. Connect `m.steps.reduce` to a CeTZ canvas and preserve hidden bounds so later additions do not shift the drawing.

This example adapts the #link(
  "https://diagrams.janosh.dev/bloch-sphere",
)[Bloch sphere from Scientific Diagrams].

#embedded-example(
  calepin.elements.gallery,
  "incremental/cetz-drawing",
  frames: 4,
  title: "Construct a Bloch sphere progressively",
)

= Fletcher diagrams

Reveal a diagram path gradually when you want the audience to follow one relationship at a time. Connect `m.steps.reduce` to Fletcher, then use ordinary Mosaic timing functions around nodes and edges.

#embedded-example(
  calepin.elements.gallery,
  "incremental/fletcher-diagram",
  frames: 3,
  title: "Reveal a Fletcher diagram progressively",
)

= Notes and handouts

== Speaker notes

Use `m.note[...]` to attach notes to a slide. Notes do not appear in the presentation or add frames.

```typ
#m.slide[
  #m.note[Introduce the result.]

  #m.steps.reveal(
    [
      The estimate is positive.
      #m.note[Explain the sign and magnitude.]
    ],
    [
      The interval excludes zero.
      #m.note[Discuss uncertainty.]
    ],
  )
]
```

A note outside a timing command applies to every frame. A note inside `m.steps.on`, `m.steps.reveal`, or `m.steps.replace` appears with that content.

Choose an output in `m.setup` when you need a printable companion document:

```typ
// Slide thumbnail followed by its notes.
#show: m.setup.with(output: "speaker")

// Notes without a slide thumbnail.
#show: m.setup.with(output: "notes")
```

== Final-frame handouts

Set `handout: true` to render only the final frame of each slide:

```typ
#show: m.setup.with(handout: true)
```

This includes the final state of timed backgrounds and foregrounds.

== Counters and states

Content repeated across frames can advance a Typst counter or state more than once. List the counters and states that should advance only once per slide:

```typ
#let theorem-counter = counter("theorems")
#let theorem-state = state("theorem-state", 0)

#show: m.setup.with(
  frozen-counters: (theorem-counter,),
  frozen-states: (theorem-state,),
)
```

Counters and states not listed here keep their normal Typst behavior.
