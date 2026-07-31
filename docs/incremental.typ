#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

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

== Final-frame handouts

Set `handout: true` on `setup` to emit one frame per logical slide:

```typ
#show: m.setup.with(handout: true)
```

Mosaic still computes the slide's complete timing sequence, but renders only
its final step. The final state of `on`, `reveal`, `replace`, reducers,
backgrounds, and foregrounds is retained. Static slides are unchanged.

Handout content is evaluated once, so selected and unlisted counters and states
both advance once per logical slide. `handout: false` is the default.

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

Mosaic records each selected object's value before the first frame and restores
that value before every continuation frame. Updates made by the last physical
frame remain visible to the following logical slide. Only listed objects are
rewound; Mosaic's own step state and every unlisted Typst counter or state keep
their normal behavior.

== on

`m.on(range)[content]` controls exactly when content appears. Use an
integer such as `2`, an open range such as `"2-"`, or a closed range such as
`"2-4"`.

```typ
#m.on("2-")[Appears on step 2.]
```

== reveal

`m.reveal[...]` shows items one at a time. It is the shortest way to
reveal a list or a sequence of grid cells.

```typ
#m.reveal[
  - First
  - Second
]
```

== replace

`m.replace[first][second]` swaps alternatives in one stable slot. The
largest alternative determines the slot's size.

```typ
#m.replace[Draft][Final]
```

= Reveal bullets

Reveal a list gradually when you want your audience to discuss each point
before seeing the next one. Wrap the whole list in `m.reveal`; Mosaic
recognizes its items and shows one more on each step.

#verbatim-example("incremental/reveal.typ")

#slideshow(
  calepin.elements.gallery,
  "incremental/reveal",
  3,
  "Reveal a list one item at a time",
)

= Reveal cells

Introduce a comparison gradually when showing every panel at once would be
overwhelming. Revealed grid cells can start removed, allowing the visible
cells to use all available space until the next one arrives.

#verbatim-example("incremental/grid.typ")

#slideshow(
  calepin.elements.gallery,
  "incremental/grid",
  3,
  "Add comparison cells progressively",
)

= Reveal text

Use `m.on` when a word, sentence, or other element should appear only at
particular moments. A step can be written as an integer such as `2`, an open
range such as `"3-"`, or a closed range such as `"2-4"`. The `before` and
`after` options control what the audience sees outside that range.

#verbatim-example("incremental/on.typ")

#slideshow(
  calepin.elements.gallery,
  "incremental/on",
  4,
  "Control when text appears",
)

= Replace content

Replace a word or larger fragment when you want to revise an idea without
moving the surrounding content. `m.replace` reserves enough room for all
alternatives and displays them in sequence.

#verbatim-example("incremental/replace.typ")

#slideshow(
  calepin.elements.gallery,
  "incremental/replace",
  3,
  "Revise content in a stable position",
)

= CeTZ drawings

Draw a figure progressively when you want to explain its geometry in the
order it is constructed. Connect `m.reduce` to a CeTZ canvas and preserve
hidden bounds so later additions do not shift the drawing.

This example adapts the #link(
  "https://diagrams.janosh.dev/bloch-sphere",
)[Bloch sphere from Scientific Diagrams].

#verbatim-example("incremental/cetz.typ")

#slideshow(
  calepin.elements.gallery,
  "incremental/cetz",
  4,
  "Construct a Bloch sphere progressively",
)

= Fletcher diagrams

Reveal a diagram path gradually when you want the audience to follow one
relationship at a time. Connect `m.reduce` to Fletcher, then use ordinary
Mosaic timing functions around nodes and edges.

#verbatim-example("incremental/fletcher.typ")

#slideshow(
  calepin.elements.gallery,
  "incremental/fletcher",
  3,
  "Reveal a Fletcher diagram progressively",
)
