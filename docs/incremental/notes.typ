#set document(title: [Notes and handouts])
#metadata((title: "Notes and handouts")) <website-metadata>

#title()

= Speaker notes

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

Notes are also the right home for material that supports a slide without belonging on it: the source URL of a figure, a reminder of what to say, or the link behind an image slide:

```typ
#m.slide(
  layout: "image",
  image: path("fig/happiness-income.png"),
)[
  == Does money buy happiness?
  #m.note[
    https://ourworldindata.org/happiness-and-life-satisfaction

    Source: Our World in Data
  ]
]
```

Choose an output in `m.setup` when you need a printable companion document:

```typ
// Slide thumbnail followed by its notes.
#show: m.setup.with(output: "speaker")

// Notes without a slide thumbnail.
#show: m.setup.with(output: "notes")
```

= Final-frame handouts

Set `handout: true` to render only the final frame of each slide:

```typ
#show: m.setup.with(handout: true)
```

This includes the final state of timed backgrounds and foregrounds.

= Counters and states

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
