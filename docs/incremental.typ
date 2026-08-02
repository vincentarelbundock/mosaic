#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Reveal or replace])
#metadata((title: "Reveal or replace")) <website-metadata>

#title()

After composing a slide's body, foreground, and background, timing controls
what the audience sees in each frame. With Mosaic, you write one logical slide
and reveal, replace, or remove parts of it over a sequence of frames.

The features and API described on this page were heavily influenced by the
excellent #link("https://touying-typ.github.io/docs/intro")[Touying package].

= Commands

Every logical slide starts at step 1. Mosaic adds frames until the last timed
command has run. Hidden content keeps its space by default, so the rest of the
slide stays still. Use `before: "removed"` when surrounding content should
expand into that space.

Choose the smallest command for the timing you need:

- `m.steps.on(range)[content]` shows content over an exact step range.
- `m.steps.reveal[...]` accumulates a list or sequence one item at a time.
- `m.steps.replace[first][second]` swaps alternatives in one stable slot.
- `m.steps.reduce` connects the same timing model to custom structures.

== Final-frame handouts

Set `handout: true` on `setup` to emit one frame per logical slide:

```typ
#show: m.setup.with(handout: true)
```

Mosaic computes the complete sequence but renders only its final step, including
timed backgrounds and foregrounds. Content is evaluated once per logical slide;
`handout: false` is the default.

== Freeze counters and states

Typst ordinarily treats repeated frames as separate copies of their content.
A native equation, theorem, figure, table, or custom counter can therefore
advance once per physical frame. List selected objects in `setup` when they
should advance only once per logical slide:

```typ
#let theorem-counter = counter("theorems")
#let theorem-state = state("theorem-state", 0)

#show: m.setup.with(
  frozen-counters: (theorem-counter,),
  frozen-states: (theorem-state,),
)
```

Mosaic restores each listed value before continuation frames; the final update
remains visible to the next logical slide. Unlisted values keep native Typst
behavior.

== Speaker notes

Use `m.note[...]` to attach ordinary Typst content to the current logical slide.
Notes do not render in the presentation and never increase the number of frames:

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

A note outside a timing command applies to every frame. A note inside
`m.steps.on`, `m.steps.reveal`, or `m.steps.replace` follows that command's
existing frame semantics, so notes next to revealed content receive their frame
assignment automatically. Multiple applicable blocks accumulate in source
order.

The default `output: "slides"` writes the ordinary presentation PDF. Select a
printable A4 companion document through `setup`:

```typ
// The current frame as a thumbnail, followed by its applicable notes.
#show: m.setup.with(output: "speaker")

// Applicable notes without a visible slide thumbnail.
#show: m.setup.with(output: "notes")
```

Both companion outputs write exactly one page per emitted physical frame. If a
frame's notes do not fit in the available A4 notes region, compilation fails
with an explicit overflow diagnostic instead of silently adding a continuation
page. Combining either output with `handout: true` retains Mosaic's
final-frame-only policy. Every
emitted frame also contains native Typst metadata labeled
`<mosaic-speaker-notes>`; its value records `logical-slide`, `frame`, and the
applicable `notes`, making the same data available to external tools through
Typst's `query` function.

= Reveal bullets

Wrap a list in `m.steps.reveal` to show one more item on each step.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-bullets",
  frames: 3,
  title: "Reveal a list one item at a time",
)

= Reveal cells

Revealed grid cells can start removed, allowing visible cells to use the space
until the next panel arrives.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-cells",
  frames: 3,
  title: "Add comparison cells progressively",
)

= Reveal text

Use `m.steps.on` for a word, sentence, or other element that appears only at selected
steps. Ranges may be integers, open ranges such as `"3-"`, or closed ranges such
as `"2-4"`; `before` and `after` control the surrounding steps.

#embedded-example(
  calepin.elements.gallery,
  "incremental/reveal-text",
  frames: 4,
  title: "Control when text appears",
)

= Replace content

Use `m.steps.replace` to revise a word or larger fragment without moving surrounding
content; the largest alternative determines the stable slot.

#embedded-example(
  calepin.elements.gallery,
  "incremental/replace-content",
  frames: 3,
  title: "Revise content in a stable position",
)

= CeTZ drawings

Draw a figure progressively when you want to explain its geometry in the
order it is constructed. Connect `m.steps.reduce` to a CeTZ canvas and preserve
hidden bounds so later additions do not shift the drawing.

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

Reveal a diagram path gradually when you want the audience to follow one
relationship at a time. Connect `m.steps.reduce` to Fletcher, then use ordinary
Mosaic timing functions around nodes and edges.

#embedded-example(
  calepin.elements.gallery,
  "incremental/fletcher-diagram",
  frames: 3,
  title: "Reveal a Fletcher diagram progressively",
)
