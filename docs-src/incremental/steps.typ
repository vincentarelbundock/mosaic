#import "/.calepin/calepin.typ" as calepin
#import "/_includes/site.typ": unreleased

#set document(title: [Steps and pauses])
#metadata((title: "Steps and pauses")) <website-metadata>

#title()

You write one slide; Mosaic can reveal, replace, or remove parts of it over a sequence of *frames*. Each frame is one page of the compiled document, and all frames of one slide share its slide number.

The features and API described in this section were heavily influenced by the #link("https://touying-typ.github.io/docs/intro")[Touying package].

#unreleased(calepin.elements.callout)[Steps inside tables, math, components, and layout fields, described under #link(label("where-steps-work"))[Where steps work], are new; the commands themselves are the same in the released version.]

= Commands

Every slide starts at step 1. Mosaic adds frames until the last timed command has run. Hidden content keeps its space by default, so the rest of the slide stays still. Use `before: "removed"` when surrounding content should expand into that space.

Choose the smallest command for the timing you need:

- `m.steps.pause` advances subsequent source-order content to the next frame.
- `m.steps.on(range)[content]` shows content over an exact step range: an integer, `"3-"` for step 3 onward, `"2-4"` for a closed range, or `"-2"` for everything up to step 2.
- `m.steps.reveal[...]` accumulates a list or sequence one item at a time.
- `m.steps.replace[first][second]` swaps alternatives in one stable slot.
- `m.steps.drawing` connects the same timing model to custom structures.

The #link("reveals.html")[Reveal and replace] page shows each of these on real slides.

= Pause between blocks

Use `m.steps.pause` when source order already expresses the reveal order:

```typ
#m.slide[
  The estimate is positive.

  #m.steps.pause

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
  #m.steps.pause
  #m.components.quote([Kant touch this.], attribution: [MC Hammer])
]
```

= Hold back a whole block

To open a slide on its title alone, or on one column alone, hold the rest back with `m.steps.on("2-")`. A leading `m.steps.pause` does not work here: a pause with nothing before it in its content stream is collapsed, so the content would appear on frame 1. An explicit range forces the second frame, and because `before` defaults to `"hidden"`, the space is kept and the slide does not jump when the content arrives:

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

= Where steps work <where-steps-work>

Steps, pauses, and notes work wherever Mosaic can see them, which is nearly everywhere: in a cell body and a plane; inside lists, tables, term lists, shapes, transforms, `columns`, and math; inside Mosaic's own components (`card`, `callout`, `quote`, `badge`, `divider`, and `figure`); and in the content a layout takes as a field, such as a section tagline or a title slide's title and subtitle.

Three places stay opaque, because Typst resolves them after the slide's frames are decided: a `context` block of your own, a `layout` callback, and the output of a show rule. A pause, step, or note there fails the compile rather than being dropped. Move it outside, or wrap the whole block in the command instead.

A note never adds a frame. One tied to a step the slide does not reach is shown on the last frame rather than lost.

A list timed with `pause`, `on`, or `reveal` is drawn by Mosaic rather than by the native list, so that a hidden item can hide its marker and keep its place. It takes the deck's own `list.marker`, `enum.numbering`, spacing, and indents, so it reads like every other list in the deck.

One slide cannot hold another: `m.slide` inside a slide body or any container is an error.
