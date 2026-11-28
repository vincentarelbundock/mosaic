# Incremental steps

Generated from the package sources, so it describes the development version (0.0.3) throughout; [the changelog](https://github.com/vincentarelbundock/mosaic/blob/main/CHANGELOG.md) lists what differs from the released one. Each entry shows the signature, a description, then the parameters with their types and defaults.

## steps.on

Shows a grid node or content only over a step range.

```typ
on(
  range,
  before: "hidden",
  after: "hidden",
  body
) -> content | dictionary
```

This is the explicit form of incremental control: the range says exactly which frames the body appears on, independent of source order.

```typ
#mosaic.slide[== Findings][
  #mosaic.steps.on(1)[First, in isolation.]
  #mosaic.steps.on("2-")[Then, for the rest of the slide.]
  #mosaic.steps.on("2-3", after: "dimmed")[A passing remark.]
]
```

**Ranges**

- `2`: the single step 2.
- `"2-"`: step 2 onward, to the end of the slide.
- `"-2"`: from the first step through step 2.
- `"2-4"`: steps 2 through 4 inclusive.

**States**

`before` and `after` say what happens outside the range:

- `"hidden"`: the body reserves its space but is not drawn.
- `"visible"`: the body is drawn normally.
- `"dimmed"`: the body is drawn muted, which is how a point stays legible after the discussion has moved on. See **Dimming** below for what that reaches.
- `"removed"`: the body is absent and gives up its space, so the content around it moves.

The body may be content or a Mosaic grid node, so whole regions of a layout can appear and disappear, not just text. Inside `steps.drawing` it may also be a drawing command or an array of them.

**List items**

`on` around list items keeps them in the surrounding list:

```typ
- Always here
#mosaic.steps.on("2-")[- Arrives on step 2]
```

The marker of a hidden item is hidden with it, and the list keeps the place and shape it has without the timing. While an item of a bulleted list is hidden, dimmed, or removed, Mosaic hands the list to Typst as an `enum` whose "numbers" are the list's own markers, which is the one way to give each item a marker of its own. It looks the same, but a `show list` rule of the deck does not match it on those frames; `show enum` does.

**Dimming**

Dimming sets the ink of the body to gray, which is what a set rule can do: it reaches text. A Mosaic component in the body follows, muting its own fill, border, and rail, so a dimmed card is dimmed as a whole. A fill or a stroke written on a native element (`rect(fill: ..)`, a table's stroke) stays as written, because Typst has no way to fade a group of drawings; restate such paint for the dimmed steps if it matters.

**Where it works**

Mosaic resolves steps by walking the slide's content, rebuilding each element around what this frame shows. It can do that for ordinary markup, for the native containers a slide is made of (blocks and boxes, lists, tables and grids, figures, shapes, transforms, columns, and math), and for everything Mosaic itself provides: the body, title, attribution, and caption of a component, and a layout's content fields, such as a section tagline or a title slide's subtitle. It cannot look inside a `context` block, a `layout` callback, or the output of a show rule, nor rebuild an element it does not know. A step, `pause`, or `note` placed there fails the compile rather than vanishing; move it outside.

A body that is not content is a drawing command, and has meaning only inside `steps.drawing`. Written anywhere else it is an error.

**Parameters**

- `range` (`int | str`): Which steps show the body: an integer, `"N-"` for open-ended, `"-M"` for everything up to a step, or `"N-M"` for a closed range.
- `before` (`str`, default `"hidden"`): How the body renders before the range: `"hidden"`, `"visible"`, `"dimmed"`, or `"removed"`.
- `after` (`str`, default `"hidden"`): How the body renders after the range: `"hidden"`, `"visible"`, `"dimmed"`, or `"removed"`.
- `body` (`content | dictionary | any`): Content or Mosaic grid node controlled by the range. Anything else is a drawing command, which only `steps.drawing` can interpret: write text as content (`[text]`), not as a string.

## steps.reveal

Reveals content or grid nodes one step at a time.

```typ
reveal(
  start: 1,
  before: "hidden",
  after: "visible",
  ..items
) -> content | array
```

Where `on` sets one range by hand, `reveal` assigns consecutive steps for you, which is what a bulleted build usually wants.

```typ
#mosaic.steps.reveal[
  - Collect the data
  - Fit the model
  - Report the interval
]
```

**What counts as an item**

- A single content block holding list items reveals one list item per step. Any non-item siblings inside that block ride along and stay visible throughout.
- Otherwise each positional argument is one item, revealed whole.
- Grid nodes may be revealed too, but content and nodes cannot be mixed in one call.
- Inside `steps.drawing`, the items may be drawing commands, one per step.

A hidden item hides its marker too, and the list keeps the place and shape it has unrevealed; see `steps.on` for how a bulleted list is handled while one of its items is not plainly visible.

```typ
#mosaic.steps.reveal(start: 2, after: "dimmed",
  [First claim], [Second claim], [Third claim],
)
```

**Parameters**

- `start` (`int`, default `1`): Step on which the first item appears. Later items follow one step apart.
- `before` (`str`, default `"hidden"`): How an item renders before its own step: `"hidden"`, `"visible"`, or `"dimmed"`.
- `after` (`str`, default `"visible"`): How an item renders after its own step: `"visible"` keeps it on screen, `"dimmed"` mutes it as the build moves on, and `"hidden"` removes it.
- `..items` (`arguments`): The items: content blocks, Mosaic grid nodes, or drawing commands, but only one kind per call. At least one is required.

## steps.replace

Replaces one content block with the next on successive steps.

```typ
replace(start: 1, align: top + left, ..bodies) -> content
```

Exactly one body is on screen at a time, and every body occupies the same space, so surrounding content does not shift as the slide advances. Each body is laid out at the width the slot is offered, so prose wraps as usual, and the slot is as large as the largest of them. That makes it the tool for an equation that rewrites itself or a diagram that gains an annotation.

```typ
#mosaic.steps.replace(
  align: center + horizon,
  $ a^2 + b^2 $,
  $ a^2 + b^2 = c^2 $,
)
```

This accepts content only. To swap structure, keep the grid stable and replace the content inside a cell.

**Parameters**

- `start` (`int`, default `1`): Step on which the first body appears. Each later body replaces it one step further on.
- `align` (`alignment`, default `top + left`): Alignment applied to every body inside the shared area they occupy.
- `..bodies` (`arguments`): The content blocks, shown one per step in order. At least one is required.

## steps.drawing

Teaches Mosaic to step through a drawing library's own command values.

```typ
drawing(
  render: none,
  hide: none,
  dim: none,
  ..args
) -> content
```

`on` and `reveal` work on content, which a drawing package such as CETZ or Fletcher does not produce: its nodes and edges are opaque command values that only mean something to its own renderer. `drawing` bridges the two. Mosaic resolves the step ranges, drops what this frame does not show, passes what remains through `hide` or `dim`, and hands the surviving array to `render`.

The usual shape is to bind the three functions once, then call the result like the library's own renderer.

```typ
#import "@preview/fletcher:0.5.8" as fletcher

#let diagram = mosaic.steps.drawing.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

#diagram(
  spacing: 4em,
  fletcher.node((0, 0), `reading`),
  mosaic.steps.on("2-", (
    fletcher.edge(`read()`, "-|>"),
    fletcher.node((1, 0), `eof`),
  )),
)
```

Positional arguments are the commands, each of which may be wrapped in `on` or `reveal`, alone or as an array. Named arguments are forwarded untouched to `render`, which is how `spacing:` above reaches `fletcher.diagram`.

`render` is required; `none` is only the placeholder that `drawing.with(..)` fills in. `hide` and `dim` are needed only by a drawing that asks for the state each one draws.

**Parameters**

- `render` (`function`, default `none`): Draws the frame. Called as `render(..named, commands)` with the named arguments given here and the array of commands this frame keeps. Usually the library's own top-level renderer. Required.
- `hide` (`function | none`, default `none`): Turns one command into its invisible counterpart, so it still reserves space and the drawing does not shift between frames. Usually the library's own `hide`. Required only if some step range leaves a command `"hidden"`, which is the default before and after a range; a drawing whose commands are all `"removed"` outside their range needs none.
- `dim` (`function | none`, default `none`): Turns one command into its muted counterpart. Required only if some step range uses the `"dimmed"` state; omitting it makes that an error.
- `..args` (`arguments`): Positionally, the drawing commands, optionally wrapped in `on` or `reveal`. By name, arguments forwarded unchanged to `render`.

## steps.pause

Advances subsequent content to the next physical frame.

`content`

This is the least ceremonious way to build a slide: drop a marker where the pause belongs, and everything after it moves to the following frame. Everything before it stays on screen, so the slide accumulates.

```typ
#mosaic.slide[== Argument][
  The premise.
  #mosaic.steps.pause
  The consequence.
  #mosaic.steps.pause
  The objection.
]
```

A pause is a value rather than a function, so it takes no arguments and no body. Compare `steps.on` and `steps.reveal`, which name their steps explicitly and can therefore reach frames out of source order.

Empty leading, trailing, or consecutive pauses produce no blank frames, and neither does a stretch between two pauses that holds only spacing.

A pause splits the content it sits in, so put it between the things it separates. Between list items it goes on a line of its own:

```typ
- Shown first
#mosaic.steps.pause
- Shown second
```

The marker of a hidden item is hidden with it, and the list keeps the place and shape it has without the pauses, so its last frame is the plain list. A pause written at the end of an item (`- Shown first #mosaic.steps.pause`) would split only that item and reveal nothing, so it is an error. A pause works wherever `steps.on` does, which includes the body of a component and a layout field such as a section tagline, and excludes a `context` block, a `layout` callback, and the output of a show rule.
