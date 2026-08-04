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
- `m.steps.reduce` connects the same timing model to custom structures.

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
