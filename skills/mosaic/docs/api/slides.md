# Slides

Generated from the package sources, so it describes the development version (0.0.3) throughout; [the changelog](https://github.com/vincentarelbundock/mosaic/blob/main/CHANGELOG.md) lists what differs from the released one. Each entry shows the signature, a description, then the parameters with their types and defaults.

## slide

Creates one logical slide command.

```typ
slide(
  layout: auto,
  numbered: auto,
  invert: false,
  breakable: auto,
  cells: (:),
  background: auto,
  foreground: auto,
  ..bodies
) -> content
```

A logical slide is one unit of content, which may render as several physical frames once incremental steps are applied.

```typ
#mosaic.slide[== Structure][
  Every slide resolves to a grid tree.
]
```

**Choosing a layout**

The selection is the one positional subject, so `slide("content", variant: "body")[...]` and `slide(layout: "content", variant: "body")[...]` are the same slide.

- `auto`: the configured `content` layout. The default.
- `"content"`, `"title"`, `"section"`, `"image"`: the matching entry in `setup(layouts:)`. The name also determines numbering and the section lifecycle.
- A `mosaic.layouts.*` value: used directly, carrying its own semantic name.
- A raw `mosaic.grids.*` tree: used directly and treated as a content layout.

**Supplying content**

Two forms, which combine:

- Positional bodies, which fill the layout's cells in depth-first order, starting with the first. Every cell counts, the header and the footer included, and a body's content is never read: the second body always lands in the second cell. Fewer bodies than cells leaves the trailing cells to their deck default from `setup(cells:)`, or empty; more is an error. On the usual header-and-body layout:

```typ
#mosaic.slide[== Title][Body.]
#mosaic.slide[][Body under no title.]
```

- A `cells:` dictionary keyed by cell id, which is order-independent and lets a slide skip cells.

```typ
#mosaic.slide(cells: (
  header: [== Named cells],
  body: [Order does not matter here.],
  footer: [Replaces the deck footer on this slide.],
))
```

Given together, a cell named in `cells:` is filled from it, and the positional bodies fill the cells that remain, in order:

```typ
#mosaic.slide(cells: (header: [== Title]))[Body.][Source: OECD]
```

**Planes**

`background:` and `foreground:` are full-slide layers rather than grid cells, so they have parameters of their own. `auto` inherits the plane declared on `setup`, `none` suppresses it for this slide, and content overrides it.

```typ
#mosaic.slide(
  cells: (body: [Over a photograph.]),
  background: mosaic.components.image(path("cover.webp")),
)
```

**Layout fields**

Any other named argument is a field of the selected layout, so the slide refines the configured layout rather than replacing it, and fields the theme set survive:

```typ
#mosaic.slide(layout: "title", variant: "academic")
```

This requires `layout: auto` or a layout name. With an explicit `mosaic.layouts.*` value the constructor is already at hand, so pass the fields to it instead.

**Breakable slides**

`breakable: true` lets a body that outgrows the frame continue onto continuation pages, each repeating the header, the footer, and the planes:

```typ
#mosaic.slide(breakable: true)[== References][
  #bibliography("refs.bib", title: none)
]
```

Only a content slide in one step breaks; asking for it on any other slide is an error that names the reason. Only the body breaks: the header and footer repeat on every page, so they must leave it room. A single positional body fills the header, the first cell, so write the body second or name it with `cells: (body: ..)`. In the printed outputs (`speaker`, `notes`, `split`) a breakable slide is drawn as an ordinary frame. `auto` follows `setup(breakable:)`, which breaks the slides that can and leaves the others fixed.

**Parameters**

- `layout` (`auto | str | dictionary`, default `auto`): Which layout resolves this slide: `auto` for the configured content layout, one of the names `"content"`, `"title"`, `"section"`, or `"image"`, a `mosaic.layouts.*` value, or a raw `mosaic.grids.*` tree. Also accepted as the leading positional argument.
- `numbered` (`auto | bool`, default `auto`): Whether the slide contributes to logical slide numbering. `auto` numbers every layout except title and section, which are deck chrome; an explicit boolean always wins.
- `invert` (`bool`, default `false`): Whether to invert this slide's polarity: the slide ground takes the deck's text color, type is knocked out in the canvas color, and the muted and line colors are derived to match. Works with any layout, so an inverted title, section plate, or big-number slide are all one flag. Cell text and components follow the inverted palette, including fills a theme pins on `<mosaic-cell-*>` labels; colors applied inside the content itself, such as an explicit `text(fill: ..)`, keep their own values.
- `breakable` (`auto | bool`, default `auto`): Whether a body that outgrows the slide continues onto continuation pages. `auto` follows `setup(breakable:)`; see "Breakable slides" above for which slides can break.
- `cells` (`dictionary`, default `(:)`): Cell bodies keyed by cell id. A cell named here is not filled positionally.
- `background` (`auto | content | none`, default `auto`): Full-slide layer drawn behind the grid. `auto` inherits the deck background from `setup`, `none` suppresses it.
- `foreground` (`auto | content | none`, default `auto`): Full-slide layer drawn over the grid. `auto` inherits the deck foreground from `setup`, `none` suppresses it.
- `..bodies` (`arguments`): Positional cell bodies, each one content or `none` for an empty cell, filling cells by the rule under "Supplying content" above, plus any named arguments forwarded as fields of the selected layout.

## info

Reads what the deck knows about itself: the metadata declared on `setup`, and the position of the slide being rendered. This is what a custom composition reads instead of restating the deck, and what deck chrome reads instead of counting for itself.

```typ
info() -> dictionary
```

Returns a dictionary with six fields. Four are the deck metadata, exactly as `setup` received it:

- `title`: the deck title.
- `subtitle`: the deck subtitle.
- `authors`: always an array of resolved author records, whether the deck wrote a bare name or a full `layouts.author` record. Every entry carries `name`, `affiliations`, `email`, `orcid`, and `corresponding`.
- `date`: the deck date.

Two are the position of the slide being rendered, which is what makes the reader contextual:

- `slide`: a dictionary of `number`, `total`, and `numbered`. The count is of logical slides rather than pages, so one incremental slide is one number however many frames it prints. Unnumbered slides (titles and sections, by default) are passed over by the count: they report `numbered: false` and `number: none`, because such a slide has no number of its own, and the previous slide's would be a wrong answer. Deck furniture reads either field to quiet itself on those pages. With an `appendix` marker in the deck, `total` is the count at the marker, and backup slides after it number past it.
- `section`: a dictionary of `number`, `total`, and `title`. The number is the current section's, counting slides that use the `section` layout, and the title is that section's own text with any heading stripped. Before the deck's first section slide the number is `0` and the title is `none`. Its `total` likewise stops at an `appendix` marker.

Call it inside a `context` block (slide bodies, planes, and show rules already are one):

```typ
#mosaic.slide(
  background: mosaic.components.image(path("cover.webp"), scrim: black.transparentize(45%)),
)[][
  #context {
    let deck = mosaic.info()
    place(top + left, text(size: 2.2em, weight: "bold", deck.title))
    place(bottom + left, deck.authors.map(author => author.name).join([, ]))
  }
]
```

The metadata half is the escape hatch for title pages the built-in variants do not draw: declare the information once on `setup`, and a hand-built cover reads it back instead of duplicating it. The position half is what a footline or a headline is made of, and it is the same reading `components.progress` does, so a theme drawing its own chrome keeps no counters of its own:

```typ
#let footline = context {
  let deck = mosaic.info()
  grid(
    columns: (1fr, 1fr),
    deck.section.title,
    if deck.slide.numbered {
      align(right)[#deck.slide.number\/#deck.slide.total]
    },
  )
}
```

## appendix

Marks where the talk ends and the backup slides begin.

`content`

Write it once, between two slides:

```typ
== Conclusion
Thank you.

#mosaic.appendix

== Robustness checks
```

The slides and sections after the marker keep counting, but the totals stop at the marker, so a footer reads "12 / 30" through the talk and "31 / 30" on the first backup slide. A progress indicator stays full on backup slides, and the `toc` section variant lists only the sections before the marker. `info()` reports the same totals.

The marker is content, not a function: write `#mosaic.appendix`, with no parentheses. It belongs between slides; inside a slide it is an error, and a second marker is an error too.

## note

Attaches non-rendering speaker notes to a logical slide.

```typ
note(body) -> content
```

Notes never appear in the slides themselves. They are collected and shown by the `"speaker"` and `"notes"` outputs of `setup`.

```typ
#show: mosaic.setup.with(output: "speaker")

#mosaic.slide[== Results][
  #mosaic.note[Mention the confidence interval before the table.]
  The estimate holds under both specifications.
]
```

Multiple note blocks on one slide accumulate in source order. Wrap a note in `steps.on`, `steps.reveal`, or `steps.replace` to tie it to the same physical frames as the incremental content it belongs with, so the speaker view shows it beside the frame it describes.

A note never adds a frame, and is never dropped. Tied to a step the slide does not reach, such as `steps.on(3)` on a slide whose visible content ends at step 2, it is shown on the slide's last frame.

A note can be written anywhere Mosaic can find it by walking the slide's content: in ordinary markup, in a native container, in a component, or in a layout field such as a section tagline. It cannot be found inside a `context` block, a `layout` callback, or the output of a show rule, and a note placed there fails the compile rather than being dropped.

**Parameters**

- `body` (`content`): The note text. Ordinary content, so lists and emphasis work as usual.

## fit

Scales one block of content to the space it is given.

```typ
fit(
  body,
  width: auto,
  height: auto,
  wrap: true,
  grow: false,
  shrink: true
) -> content
```

Mosaic never resizes body content on its own, so a slide holding more than it can show reports an overflow rather than shrinking. `fit` is the explicit per-block exception, for content whose size the author does not control: a wide table, a chart, a generated list, a number meant to fill the slide.

It measures the content against the region the call sits in and scales it geometrically, so proportions are preserved and the surrounding layout accounts for the new size. With no `width` or `height` it fits the whole region.

```typ
#mosaic.slide[== A long argument][
  #mosaic.fit(generated-list)
]
```

Fitting works in cells, in the `background` and `foreground` planes, and in ordinary content. Pass `grow: true` for display type that should fill its cell rather than merely avoid overflowing it:

```typ
#mosaic.fit(grow: true)[42%]
```

**Content that must not be re-laid out**

By default the content is offered the region's width first, so text and lists wrap into the cell and are scaled only if they are still too tall. Prose that must shrink is re-wrapped at a wider measure first, so the scaled block fills the width of its cell instead of standing in a narrow column. A table, chart, or diagram would rearrange its own columns instead, which changes the composition rather than its size. Pass `wrap: false` to scale such a block exactly as it stands:

```typ
#mosaic.fit(wrap: false, my-wide-table)
```

**Overflow**

A fitted block cannot overflow, so it emits no `<mosaic-overflow-warning>` record and never fails an `overflow: "error"` compile. A cell that fits its content therefore stops reporting how full it is.

**Incremental content and speaker notes**

Fitting measures its body, which means holding it inside a closure that the slide runtime cannot look into. Incremental markers and speaker notes are found by walking the slide's content, so anything inside a fitted block would be invisible to that walk: the reveals would collapse into one frame and the notes would vanish. `fit` rejects such a body rather than dropping it silently. Keep `pause`, `steps`, and `note` outside the fitted block, or fit each revealed part on its own.

**Sizes**

`width` and `height` take a length (`12cm`, `20em`), a ratio of the region (`50%`), or a relative length combining the two (`50% + 1cm`). A fractional `width` such as `1fr` means the whole region, like `auto`; its magnitude is not read, because a fitter measuring one block has no free width to share out. A fractional `height` makes the fitted block take that share of the remaining height, as `block(height: 1fr)` would, and fits into it.

**Parameters**

- `body` (`content`): The content to scale.
- `width` (`auto | length | ratio | relative | fraction`, default `auto`): Width to fit into. `auto` uses the full width of the region.
- `height` (`auto | length | ratio | relative | fraction`, default `auto`): Height to fit into. `auto` uses the full height of the region.
- `wrap` (`bool`, default `true`): Let the content re-lay out at the available width before it is measured. Pass `false` for a block whose own arrangement must be preserved.
- `grow` (`bool`, default `false`): Scale content up when it is smaller than the space available.
- `shrink` (`bool`, default `true`): Scale content down when it is larger than the space available.
