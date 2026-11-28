# Components and furniture

Generated from the package sources, so it describes the development version (0.0.3) throughout; [the changelog](https://github.com/vincentarelbundock/mosaic/blob/main/CHANGELOG.md) lists what differs from the released one. Each entry shows the signature, a description, then the parameters with their types and defaults.

## components.card

Wraps content in a clipped, semantically styled block.

```typ
card(
  body,
  role: "neutral",
  fill: auto,
  accent: auto,
  stroke: auto,
  radius: auto,
  inset: auto,
  align: auto,
  text: (:),
  width: auto,
  height: auto
) -> content
```

This is the base the other components are built on, and the one to reach for when you want a panel that follows the deck's colors without spelling them out.

```typ
#mosaic.components.card(role: "warning")[
  The interval covers zero.
]
```

**Roles**

A role names one color in the deck palette. The component paints its border and rails with that color, its text with the deck's text color, and its panel with the color tinted into the deck's canvas, so a component tracks the active theme instead of hard-coding paint.

- `neutral`: the deck's own surface, outlined in its line color. The default.
- `accent`: the deck's accent.
- `warning`, `error`: the status colors.

Every one of them is a palette entry a theme or a deck can restate, so a deck that wants a different warning sets `colors: (warning: ..)` at `setup` once rather than restyling each component.

**Overrides**

`fill`, `accent`, `stroke`, `radius`, `inset`, and `align` each default to `auto`, meaning "take it from the role". Pass one to override just that part. `text` is a dictionary of native `text` arguments, empty by default, and is merged into the role's text color rather than replacing it.

```typ
#mosaic.components.card(
  radius: 0pt,
  stroke: none,
  text: (size: 0.8em),
)[Quiet panel]
```

**Steps, pauses, and notes**

A component is transparent to Mosaic's own commands: `steps.pause`, `steps.on`, `steps.reveal`, `steps.replace`, and `note` work in its body as they do in the slide around it. The same holds for every component that takes content, including a callout's title and a quotation's attribution.

```typ
#mosaic.components.card[
  The premise.
  #mosaic.steps.pause
  The consequence.
]
```

A component dimmed by a step (`steps.on(.., before: "dimmed")`, `steps.reveal(after: "dimmed")`, a dimmed list item) mutes its own paint along with its text: fill, border, and rail lose their color and most of their strength. Only a step does this. Gray text around a component is just gray text, and leaves the component's paint alone.

**Parameters**

- `body` (`content`): Content inside the card.
- `role` (`str`, default `"neutral"`): Semantic role name: `neutral`, `accent`, `warning`, or `error`.
- `fill` (`auto | color | gradient | tiling | none`, default `auto`): Panel fill. `auto` uses the role's color tinted into the deck canvas.
- `accent` (`auto | color`, default `auto`): Border and rail color. `auto` uses the role's own color.
- `stroke` (`auto | stroke | dictionary | none`, default `auto`): Border stroke. `auto` draws the standard thickness in `accent`.
- `radius` (`auto | length | dictionary`, default `auto`): Corner radius. `auto` uses the shared component radius.
- `inset` (`auto | length | relative | dictionary`, default `auto`): Padding inside the panel. `auto` uses the shared component inset.
- `align` (`auto | alignment`, default `auto`): Horizontal alignment of the body. `auto` is `left`.
- `text` (`dictionary`, default `(:)`): Native `text` arguments merged over the role's text color.
- `width` (`auto | length | relative`, default `auto`): Native block width. `auto` hugs the content.
- `height` (`auto | length | relative | fraction`, default `auto`): Native block height. `auto` hugs the content.

## components.callout

Creates a callout with a semantic side stripe.

```typ
callout(
  body,
  role: "accent",
  title: none,
  fill: auto,
  accent: auto,
  stroke: auto,
  radius: auto,
  inset: auto,
  align: auto,
  text: (:),
  width: 100%
) -> content
```

A callout is a `card` with two additions: a colored stripe down its left edge, and an optional bold title in the same color. Where `card` is a neutral panel, this one announces what kind of remark it holds.

```typ
#mosaic.components.callout(role: "warning", title: [Caveat])[
  The estimate assumes independent errors.
]
```

**Roles**

- `accent`: the deck's accent. The default.
- `warning`, `error`: the status colors.
- `neutral`: the deck's own surface.

**Custom colors**

A role is the portable spelling, and it stays correct when the deck changes theme. When a callout needs a color the palette does not name, pass `accent` directly: it paints the stripe and the title. The panel keeps the role's own fill, so a callout that should be tinted to match states `fill` as well.

```typ
#mosaic.components.callout(
  accent: rgb("#7c3aed"),
  fill: rgb("#f1ebfd"),
  title: [Takeaway],
)[
  Bounded work beats unbounded intent.
]
```

See `card` for the full list of overrides.

**Parameters**

- `body` (`content`): Callout content.
- `role` (`str`, default `"accent"`): Semantic role name: `accent`, `warning`, `error`, or `neutral`.
- `title` (`content | none`, default `none`): Bold title set above the body in the stripe color. Under the `neutral` role the stripe is the deck's line color, too faint to read as type, so the title takes the text color instead unless `accent` is passed.
- `fill` (`auto | color | gradient | tiling | none`, default `auto`): Panel fill. `auto` uses the role's color tinted into the deck canvas.
- `accent` (`auto | color`, default `auto`): Stripe and title color. `auto` uses the role's own color.
- `stroke` (`auto | stroke | dictionary | none`, default `auto`): Border stroke. `auto` draws the left stripe and no other edge.
- `radius` (`auto | length | dictionary`, default `auto`): Corner radius. `auto` uses the shared component radius.
- `inset` (`auto | length | relative | dictionary`, default `auto`): Padding inside the panel. `auto` uses the shared component inset.
- `align` (`auto | alignment`, default `auto`): Horizontal alignment of the body. `auto` is `left`.
- `text` (`dictionary`, default `(:)`): Native `text` arguments merged over the role's text color.
- `width` (`auto | length | relative`, default `100%`): Native block width. Full width by default, so a column of callouts rules to one edge; `auto` hugs the content the way `card` does.

## components.badge

Creates a compact inline badge.

```typ
badge(
  body,
  role: "neutral",
  radius: auto,
  fill: auto,
  accent: auto,
  stroke: auto,
  inset: auto,
  text: (:)
) -> content
```

A badge is a small pill that sits in the text flow rather than breaking it, which suits a status marker, a version marker, or a keyword beside a heading.

```typ
== Estimator #mosaic.components.badge(role: "accent")[stable]
```

Any radius at least half the badge's height rounds its ends completely, so an oversized value such as `999pt` gives fully rounded pill ends. Restyle the body through `text`.

```typ
#mosaic.components.badge(
  role: "warning",
  radius: 999pt,
  text: (weight: "bold", size: 0.7em),
)[draft]
```

See `card` for the list of roles, how they resolve against the active theme, and the full list of overrides.

**Parameters**

- `body` (`content`): Badge content, usually a word or two.
- `role` (`str`, default `"neutral"`): Semantic role name: `neutral`, `accent`, `warning`, or `error`.
- `radius` (`auto | length | dictionary`, default `auto`): Corner radius. `auto` uses the compact badge radius. Oversize it (`999pt`) for fully rounded pill ends.
- `fill` (`auto | color | gradient | tiling | none`, default `auto`): Pill fill. `auto` uses the role's color tinted into the deck canvas.
- `accent` (`auto | color`, default `auto`): Border color. `auto` uses the role's own color.
- `stroke` (`auto | stroke | dictionary | none`, default `auto`): Border stroke. `auto` draws the standard thickness in `accent`.
- `inset` (`auto | length | relative | dictionary`, default `auto`): Padding inside the pill. `auto` uses the compact badge inset.
- `text` (`dictionary`, default `(:)`): Native `text` arguments merged over the role's text color, such as `size` and `weight`.

## components.quote

Creates a quotation treatment with optional attribution.

```typ
quote(
  body,
  block: true,
  quotes: auto,
  attribution: none,
  source: none,
  role: "neutral",
  fill: auto,
  accent: auto,
  stroke: auto,
  radius: auto,
  inset: auto,
  align: auto,
  text: (:),
  ..native
) -> content
```

The quotation sits in a lightly tinted `card`; attribution and source share one right-aligned line beneath it, joined by a comma when both are present.

```typ
#mosaic.components.quote(
  attribution: [Ada Lovelace],
  source: [Notes on the Analytical Engine, 1843],
)[
  The Analytical Engine weaves algebraic patterns.
]
```

To set a portrait beside the quotation, compose one natively:

```typ
#grid(
  columns: (auto, 1fr),
  gutter: 0.6em,
  mosaic.components.image(path("ada.webp"), width: 4em, height: 4em),
  mosaic.components.quote(attribution: [Ada Lovelace])[...],
)
```

**Roles**

A plain quotation carries no border at all. Naming a role other than `neutral`, or passing `accent`, hangs the quotation on a rail down its left edge in that color, the way a pull quote is marked in print.

```typ
#mosaic.components.quote(role: "accent")[
  Bounded work beats unbounded intent.
]
```

**The native quote**

This is a superset of Typst's own `quote`: `block`, `quotes`, and `attribution` keep their native meaning, and the quoted text is a native `quote` element inside the panel, so a deck's `show quote` rules and the document's structure see a quotation. `block` defaults to `true` here, because the component is a panel; `block: false` gives the plain inline quotation Typst would, with no panel, and the panel's own arguments then have nothing to apply to. `quotes: auto` follows the native rule, which adds quotation marks to an inline quotation and none to a block.

```typ
#mosaic.components.quote(quotes: true, attribution: <lovelace1843>)[
  The Analytical Engine weaves algebraic patterns.
]
```

See `card` for the list of roles and the full list of overrides.

**Parameters**

- `body` (`content`): The quoted text.
- `block` (`bool`, default `true`): Whether this is a block quotation, drawn as a panel, or an inline one, drawn as Typst draws it.
- `quotes` (`auto | bool`, default `auto`): Whether to wrap the text in quotation marks. `auto` adds them to an inline quotation only.
- `attribution` (`content | label | none`, default `none`): Who is being quoted, set on the fine-print line below the quotation. A label cites that bibliography entry, as it does natively.
- `source` (`content | none`, default `none`): Where the quotation comes from, appended after the attribution.
- `role` (`str`, default `"neutral"`): Semantic role name: `neutral`, `accent`, `warning`, or `error`. Any role but `neutral` draws the left rail in that role's color.
- `fill` (`auto | color | gradient | tiling | none`, default `auto`): Panel fill. `auto` is a faint wash of the deck's text color.
- `accent` (`auto | color`, default `auto`): Rail color. `auto` uses the role's own color, and draws no rail under the `neutral` role.
- `stroke` (`auto | stroke | dictionary | none`, default `auto`): Border stroke. `auto` draws the left rail when a role or an `accent` asks for one and nothing otherwise; an explicit stroke replaces the rail.
- `radius` (`auto | length | dictionary`, default `auto`): Corner radius. `auto` uses the shared component radius.
- `inset` (`auto | length | relative | dictionary`, default `auto`): Padding inside the panel. `auto` uses the shared component inset.
- `align` (`auto | alignment`, default `auto`): Horizontal alignment of the body. `auto` is `left`.
- `text` (`dictionary`, default `(:)`): Native `text` arguments merged over the role's text color.
- `..native` (`arguments`): Further named arguments forwarded unchanged to the native `quote`.

## components.divider

Creates a horizontal divider, optionally split around a title.

```typ
divider(title: none, stroke: auto) -> content
```

Without a title it is one full-width rule. With one, it becomes two rules with the title centered between them, which is how a slide marks a change of name without spending a heading on it.

```typ
#mosaic.components.divider()

#mosaic.components.divider(
  title: text(size: 0.7em)[Robustness checks],
  stroke: 0.5pt + luma(70%),
)
```

**Parameters**

- `title` (`content | none`, default `none`): Content centered between the two line segments. `none` draws one unbroken rule instead.
- `stroke` (`auto | stroke`, default `auto`): Native Typst stroke used for both line segments. `auto` draws the deck's line color at the shared component thickness.

## components.progress

Displays progress through logical slides or semantic sections in the deck.

```typ
progress(
  variant: "1/1",
  count: "slides",
  quiet: auto,
  role: "accent",
  width: auto,
  thickness: component-tokens.rule-thickness,
  fill: auto,
  accent: auto
) -> content
```

It reads the deck's own counters, so it needs no arguments in the ordinary case. The usual home for it is a setup-level footer default, which puts one indicator on every slide that has a footer.

```typ
#show: mosaic.setup.with(
  cells: (
    footer: align(right, mosaic.components.progress()),
  ),
)
```

**Variants**

- `1/1`: the current and final values, as text. The default.
- `1`: the current value alone.
- `circle`: a compact ring filling clockwise, sized by `width` and `thickness`.
- `line`: a horizontal bar filling left to right, sized by `width` and `thickness`.

**What it counts**

`count` selects the automatic counter: `slides` counts logical slides, and `sections` counts slides with `layout: "section"`.

Both readings come from `info()`, which publishes the same position as `slide` and `section` records. Chrome that needs more than one indicator, or the section's title rather than its number, reads that instead of composing several of these.

**Quieting**

The indicator is deck furniture, so it quiets itself on pages where its counter has no meaningful reading: a `slides` count on unnumbered slides (titles and sections, by default), and a `sections` count before the first section slide. A `sections` count does display on section slides, where the counter reads the section being opened. `quiet:` overrides the rule in either direction.

**Parameters**

- `variant` (`str | function`, default `"1/1"`): Visual treatment: `"1/1"`, `"1"`, `"circle"`, `"line"`, or a function drawing one. A renderer is called with a dictionary holding `current`, `total`, `amount`, `accent`, `fill`, `width`, and `thickness`, and returns the content to place.

  ```typ
  #mosaic.components.progress(
    variant: state => grid(
      columns: state.total,
      ..range(state.total).map(i => rect(
        height: state.thickness,
        fill: if i < state.current { state.accent } else { state.fill },
      )),
    ),
  )
  ```
- `count` (`str`, default `"slides"`): Which automatic counter to read: `"slides"` or `"sections"`.
- `quiet` (`auto | bool`, default `auto`): Whether the indicator quiets itself. `auto` silences a `slides` count on unnumbered slides and a `sections` count before the first section slide; `true` silences every unnumbered slide; `false` always displays.
- `role` (`str`, default `"accent"`): Semantic role supplying the default colors: `accent`, `neutral`, `warning`, or `error`. The role's own color paints the completed portion and its tinted fill paints the remainder.
- `width` (`auto | length | relative`, default `auto`): Length of the `line` variant, or diameter of the `circle` variant. `auto` is the full width for `line` and a compact fixed diameter for `circle`.
- `thickness` (`length`, default `component-tokens.rule-thickness`): Stroke thickness of the `circle` and `line` variants.
- `fill` (`auto | color | gradient | tiling`, default `auto`): Paint of the inactive remainder. `auto` uses the role's fill. The `circle` variant draws both portions as stops of one gradient, so there it must be a color.
- `accent` (`auto | color`, default `auto`): Paint of the completed portion, and of the text variants. `auto` uses the role's accent.

## components.image

Creates a slide-sized native Typst image with an optional scrim.

```typ
image(
  source,
  width: 100%,
  height: 100%,
  fit: "cover",
  scrim: none,
  ..native
) -> content
```

This is Typst's own `image` with presentation defaults: it fills its container instead of hugging its natural size, and it can carry a scrim. Everything else is forwarded unchanged, so `alt`, `format`, `page`, and `scaling` all work as usual.

```typ
#mosaic.slide(
  background: mosaic.components.image(path("cover.webp")),
)[][Text over the photograph]
```

When Mosaic is imported as a package, wrap an asset of the calling project in a native `path` value, as above. A bare string would resolve relative to the package instead.

**Scrims**

A `scrim` paints a layer over the picture and under whatever text is composed on top of it, which is how a photograph is quieted enough to read against. It takes an ordinary Typst paint, so it accepts exactly what a `fill` accepts.

```typ
// Darken the whole picture evenly.
#mosaic.components.image(
  path("cover.webp"),
  scrim: black.transparentize(55%),
)

// Darken only the band the text occupies.
#mosaic.components.image(
  path("cover.webp"),
  scrim: gradient.linear(
    black.transparentize(20%), black.transparentize(100%),
    angle: 90deg,
  ),
)
```

Without a scrim this returns the native image element directly, unwrapped.

**Parameters**

- `source` (`str | path | bytes`): Native image source. Use `path(...)` for an asset in the calling project.
- `width` (`auto | length | relative`, default `100%`): Width of the image area. Defaults to filling the container.
- `height` (`auto | length | relative`, default `100%`): Height of the image area. Defaults to filling the container.
- `fit` (`str`, default `"cover"`): Native Typst fitting mode: `"cover"` fills and crops, `"contain"` fits the whole picture inside.
- `scrim` (`none | color | gradient | tiling`, default `none`): Paint layered over the picture and under any text composed on top of it. Accepts whatever a native `fill` accepts.
- `..native` (`arguments`): Further arguments forwarded unchanged to native Typst `image`, such as `alt`, `format`, `page`, and `scaling`.

## components.figure

Creates a centered, captioned figure sized to its cell.

```typ
figure(
  body,
  caption: none,
  fit: "contain",
  width: 100%,
  height: auto,
  scrim: none,
  ..native
) -> content
```

This is the in-cell counterpart to the [image layout](../slides/image.md). Use the layout when one picture is the whole point of a slide; use this when a figure shares the slide with other content, most often as one of two side by side.

```typ
#mosaic.slide(layout: "content", columns: 2)[== Before and after][
  #mosaic.components.figure(path("before.png"), caption: [Baseline])
][
  #mosaic.components.figure(path("after.png"), caption: [After the reform])
]
```

**Pictures**

Given an image source, this differs from `mosaic.components.image` in its defaults, which are the ones a chart or a photograph in a cell wants rather than the ones a full-bleed background wants: `fit` is `"contain"`, so the picture is never cropped, and the result is centered in its cell.

The default `height: auto` gives the picture the cell's full height, less whatever the caption and its gap consume. Nothing has to be measured by hand, and adjacent cells agree: each picture is as large as its own aspect ratio allows, and the captions share one baseline at the foot of the cells.

**Other content**

A table, a chart drawn in code, or a diagram is passed as content instead of a source. Such a body cannot be re-fitted the way a picture can, so it is laid out at the cell's width and then scaled as a whole if it is still too tall, exactly as `mosaic.fit` does. Its own arrangement is preserved, the caption keeps the size the deck gave it, and a body that already fits is left alone. It is never magnified past its natural size.

```typ
#mosaic.components.figure(
  table(columns: 3, ..cells),
  caption: [Estimates by specification],
  kind: table,
)
```

A content body that does not fill its cell sits at the top of it and is captioned directly beneath itself, rather than stretching and captioning at the foot of the cell as a picture does.

Scaling a table also costs it the automatic `kind` a native `figure` would have detected, so state `kind: table` for the table numbering and the "Table" supplement. Further arguments go to the native `figure` here, and to the native `image` for a picture source.

**Height**

`auto` reads the size of the cell, not the space left over inside it, so a figure that follows prose in the same cell needs an explicit height:

```typ
#mosaic.slide(layout: "content", columns: 2)[== Two revenues][
  - Payroll taxes carry the system
  - Consumption taxes are regressive
  #mosaic.components.figure(path("photo.jpg"), height: 50%)
][
  #mosaic.components.figure(path("chart.png"), caption: [Shares since 1980])
]
```

An explicit height sizes the picture area, and the caption follows directly beneath it rather than sitting at the foot of the cell. Such a figure takes only the height it was given, so it leaves whatever shares its cell where it was.

**Captions**

A `caption` composes a native Typst `figure`, so it takes the deck's own `show figure.caption` styling, figure numbering, and references. Switch the numbering off with an ordinary `set figure(numbering: none)`. Without a caption no `figure` is involved: the body is centered and sized, nothing more.

**Parameters**

- `body` (`content | str | path | bytes`): The figure's body: an image source, or finished content such as a table or a diagram. Use `path(...)` for an image asset in the calling project.
- `caption` (`content | none`, default `none`): Caption composed beneath the body.
- `fit` (`str`, default `"contain"`): How a picture fills its area. `"contain"` fits the whole picture inside it, which is what a chart or a screenshot needs; `"cover"` fills the area and crops the overhang. Rejected for a content body, which is scaled rather than fitted.
- `width` (`auto | length | relative`, default `100%`): Width of the figure's body.
- `height` (`auto | length | relative`, default `auto`): Height of the figure's body. `auto` takes the cell's height less the caption, which requires the figure to be the cell's own content.
- `scrim` (`none | color | gradient | tiling`, default `none`): Paint layered over a picture. Accepts whatever a native `fill` accepts, and is rejected for a content body.
- `..native` (`arguments`): Further arguments forwarded unchanged to the native element this is built from: `image` for a picture source, taking `alt`, `format`, `page`, and `scaling`; `figure` for a content body, taking `kind`, `supplement`, and `numbering`.
