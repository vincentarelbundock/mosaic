# Semantic layouts

Generated from the package sources, so it describes the development version (0.0.3) throughout; [the changelog](https://github.com/vincentarelbundock/mosaic/blob/main/CHANGELOG.md) lists what differs from the released one. Each entry shows the signature, a description, then the parameters with their types and defaults.

## layouts.author

Creates a validated author record for `setup(authors:)` and `layouts.title(authors:)`.

```typ
author(
  name,
  affiliations: (),
  email: none,
  orcid: none,
  corresponding: false
) -> dictionary
```

A name on its own needs no record at all. `authors:` takes content or a string wherever it takes a record, so `authors: [Ada Lovelace]` and `authors: ([Ada Lovelace], [Charles Babbage])` are both complete author lists. Reach for `author()` when a name carries more than itself:

```typ
#let ada = mosaic.layouts.author(
  [Ada Lovelace],
  affiliations: ([Analytical Society], [University of London]),
  email: "ada@example.org",
  orcid: "0000-0002-1825-0097",
  corresponding: true,
)
```

**Affiliations**

An affiliation is the institution itself: content or a non-empty string. Two authors share one legend number exactly when they give the same affiliation, so bind a shared institution once and reuse the binding:

```typ
#let lon = [University of London]
#let ada = mosaic.layouts.author([Ada Lovelace], affiliations: (lon,))
#let bab = mosaic.layouts.author([Charles Babbage], affiliations: (lon,))
```

Every title variant renders these the same way: superscript numbers beside the names over a numbered legend, exactly when the deck names more than one institution. A single shared institution needs no markers.

**Validation**

Values are checked at construction rather than at render time:

- `email` must look like an address.
- `orcid` must be a well-formed iD.
- `corresponding` requires at least one of `email` or `orcid`.

**Parameters**

- `name` (`content | str`): The author's name, as the sole positional argument.
- `affiliations` (`array`, default `()`): Array of institutions, as content or non-empty strings, in the order they should be listed for this author.
- `email` (`str | none`, default `none`): Contact address, shown on the `academic` title variant and linked as a `mailto:`. Independent of `orcid`.
- `orcid` (`str | none`, default `none`): ORCID iD in `0000-0000-0000-0000` form (the last group may end in `X`, the iD's check-digit form), rendered as a linked ORCID label beside the name on every title variant. Independent of `email`.
- `corresponding` (`bool`, default `false`): Whether to mark this author as the corresponding one, with an asterisk beside the name and on the contact line. Requires `email` or `orcid`.

## layouts.content

Creates a conventional header, body, and footer grid recipe.

```typ
content(variant: "header-body-footer", columns: 1, tracks: auto) -> dictionary
```

This is the ordinary slide layout, and the one automatic level-two headings resolve to. It builds a vertical Mosaic split whose body child is a horizontal split of plain cells.

```typ
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body", columns: 2),
  [== Two columns],
  [Left body],
  [Right body],
)
```

**Cells**

The layout builds these cells, in this order:

- `header`, when the variant includes one.
- `body`, or `body-1`, `body-2`, and so on when `columns` is above one.
- `footer`, when the variant includes one.

The surrounding `mosaic.slide` fills them in that order, one positional body per cell starting with the header. Cells left without a body keep their deck default, so a deck-wide `setup(cells: (footer: ..))` shows on every slide that stops before the footer. Use `cells:` on the slide to reach a cell by name instead.

**Variants**

- `body`: the body region alone, with no header or footer.
- `header-body`: a content-sized header above the body.
- `body-footer`: the body above a content-sized footer.
- `header-body-footer`: both. The default of this constructor; a theme's own `layouts.content` and its automatic headings may select another.

**Labels**

Every resolved cell carries a label, so appearance comes from native Typst rules:

- `mosaic-cell-header`: the header, in the variants that include one.
- `mosaic-cell-body`: the body, when `columns` is one.
- `mosaic-cell-body-1`, `mosaic-cell-body-2`, and so on: the body columns, when `columns` is above one.
- `mosaic-cell-footer`: the footer, in the variants that include one.

**Styling**

The layout is purely structural, so its looks come from rules on those labels.

```typ
#show label("mosaic-cell-header"): set block(fill: luma(240))
```

The header cell carries no special typography of its own. Put a native level-two heading in its content to style it as a heading and register it with outlines; alignment and paint are the theme's, through rules on the cell's label.

**Parameters**

- `variant` (`str`, default `"header-body-footer"`): Structural arrangement: `body`, `header-body`, `body-footer`, or `header-body-footer`.
- `columns` (`int`, default `1`): Number of body columns, and therefore the number of body blocks the slide must supply. Must be a positive integer.
- `tracks` (`auto | array`, default `auto`): Native Typst track sizes for the body columns, one per column. `auto` splits the body evenly.

  ```typ
  mosaic.layouts.content(columns: 2, tracks: (2fr, 1fr))
  ```

## layouts.image

Creates an image-first grid recipe.

```typ
image(
  image,
  variant: "figure",
  caption: none,
  fit: auto,
  tracks: auto
) -> dictionary
```

This is the image-first counterpart to `layouts.content`: the picture is the argument rather than slide content, and the text regions arrange around it. The surrounding `mosaic.slide` fills only the text cells, in order: the `figure` variant has one, the `header`; a directional variant has a `header` and then a `body`; `full` has one, the `body`.

```typ
#mosaic.slide(
  layout: mosaic.layouts.image(
    path("chart.webp"),
    caption: [Revenue by quarter],
  ),
  [== Results],
)
```

**Variants**

- `figure`: the picture in the body region under a `header` cell, with an optional `caption` below it. A picture given as a path is contained, so it is never cropped, and sits centered in the region. The conventional academic figure slide, and the default.
- `left`, `right`, `top`, `bottom`: a full-bleed picture paired with a text region of `header` and `body` cells, sized by `tracks`.
- `full`: the picture behind a single `body` cell, so text reads over the photograph. Open the body with a heading to title it, or give no body at all for a bare full-bleed slide.

**Captions**

A `caption` composes a native Typst `figure` around the picture, so it takes the deck's own `show figure.caption` styling and figure numbering. Switch the numbering off with an ordinary `set figure(numbering: none)`. Captions are accepted by the `figure` variant only.

**Labels**

Every resolved cell carries a label, so appearance comes from native Typst rules:

- `mosaic-cell-header`: the header, in the `figure` and directional variants.
- `mosaic-cell-body`: the text region, in the directional and `full` variants.
- `mosaic-cell-image`: the picture, in the `figure` and directional variants. The `full` variant paints the picture as the body cell's background instead, so it has no image cell of its own.

**Styling**

The layout is purely structural, so its looks come from rules on those labels. The `full` variant inherits the surrounding native text color, so quiet the photograph with the image dictionary's `scrim` key and override the cell's text fill.

```typ
#show label("mosaic-cell-body"): set text(fill: white)
#mosaic.slide(
  layout: mosaic.layouts.image(
    (path: path("photo.webp"), scrim: black.transparentize(55%)),
    variant: "full",
  ),
  [== Full bleed],
)
```

**Parameters**

- `image` (`content | path | dictionary`): The picture the slide is built around, as the sole positional argument. Give a native `path(..)` value, ready-made content, or a dictionary whose `path` key holds one and whose `scrim` key paints a layer over the picture and under any text composed on top of it; `alt` and `fit` are its other keys. A bare string is rejected: it would resolve inside the package rather than in the deck's project.
- `variant` (`str`, default `"figure"`): Structural arrangement of picture and text: `figure`, `full`, `left`, `right`, `top`, or `bottom`.
- `caption` (`content | str | none`, default `none`): Caption composed below a `figure` picture. Rejected by the other variants.
- `fit` (`auto | str`, default `auto`): How a picture given as a path or a dictionary fills its region.

  - `"contain"`: fit the whole picture inside the region. The `figure` default, since a chart must never be cropped.
  - `"cover"`: fill the region, cropping the overhang. The default for every other variant.

  `auto` picks the per-variant default above, unless the picture is a dictionary with a `fit` key of its own, which then applies. An explicit value here wins over that key. Rejected beside ready-made content, which states its own fit and cannot be rebuilt.
- `tracks` (`auto | length | ratio | relative | fraction | array`, default `auto`): Sizes the split of a directional variant, and is rejected by `figure` and `full`. One native Typst track size answers "how much room does the picture get" and is side-independent, so `left` and `right` stay mirror images without reordering anything; the text region takes the remaining `1fr`. An array of two is in visual order instead, and must be mirrored by hand when the variant flips.

## layouts.title

Creates a presentation title grid.

```typ
title(
  title: auto,
  subtitle: auto,
  date: auto,
  image: none,
  variant: "ruled",
  authors: auto,
  tracks: auto,
  rule: auto,
  accent: auto,
  ..removed
) -> dictionary
```

The layout supplies every cell's content itself, so the surrounding `mosaic.slide` consumes no slide bodies.

```typ
#show: mosaic.setup.with(
  title: [Tree-based slide grids],
  subtitle: [A layout model for Typst],
  authors: [Ada Lovelace],
  date: [2026-08-03],
)

#mosaic.slide(layout: "title", variant: "centered")
```

**Inheritance**

Each of `title`, `subtitle`, `authors`, and `date` defaults to `auto`, which takes the value configured on `setup`. To override an inherited value:

- Pass explicit content or a string to replace it.
- Pass `none` to suppress it. This works for all four fields; `authors` also accepts the empty array `()`, which means the same.

A slide with its title suppressed still composes: the details alone, or the picture alone. What fails is a title slide with no title to inherit, that is `title: auto` on a deck whose `setup` declares none, because that is an omission rather than a choice.

**Variants**

Text variants:

- `centered`: the heading stack at the slide's center, details anchored to the bottom edge. `rule: true` adds a short accent rule under the heading.
- `bordered`: a thin rule border inset from the slide edge with the centered stack inside it.
- `ruled`: the heading stack over a full-width accent rule with the details beneath, flush left at the slide's vertical center. The beamer-metropolis title page, and the default.
- `kicker`: the magazine masthead. A strong opening rule, the subtitle set as a small tracked-caps eyebrow in the accent color, the title below it, and the details anchored to the bottom edge.
- `panel`: a vertical side panel in the deck's text color carries the details, knocked out in the canvas color under a short accent rule; the heading stack takes the main field. A slide with no authors and no date has nothing to put in the panel and draws the heading stack alone.
- `academic`: the conference-poster arrangement. A short accent rule closes the heading stack, and author names carry superscript affiliation numbers over a numbered affiliation legend and a contact line. Requires at least one author.

Image variants, which set the compact title stack with a picture:

- `image-left`, `image-right`, `image-top`, `image-bottom`: a full-bleed picture beside or above the title stack, sized by `tracks`.
- `image-background`: the title stack at the lower left, directly over a full-slide picture. The type keeps the deck's text color, so quiet the photograph with a scrim and recolor the cell as shown under **Styling**.

Every image variant requires `image`, and only they take one: write the variant together with `image:`. They are the same five names the section layout uses.

Every variant states its own arrangement, as described above; unlike the `plain` section, none leaves the placement of its stack to the theme. The theme decides the type: the display size on `<mosaic-title-display>` and the typography of the cell.

**Long titles**

Title metadata cannot be cut, so no variant lets it collide. The details grow to a share of the slide and then scale down to hold it, and the heading stack scales down in turn once it outgrows the room the details leave, so a long title over a long author list shrinks rather than overprinting. A stack scaled to fit does fit, so `setup(overflow: ..)` does not report it.

To invert any of these, with the slide ground in the deck's text color and the type knocked out, pass `invert: true` on the slide rather than picking a variant; inversion is a polarity, not a structure.

**Authors**

Every variant accepts the same `authors`, written in whichever of three spellings fits the deck: one name as content or a string, an array of names, or an array of records built with `layouts.author` for the authors that carry affiliations, an ORCID iD, or an address. Names and records mix freely in one array. Every variant renders every author field through the same tiers: a byline of names with linked ORCID labels, superscript affiliation numbers, and the corresponding asterisk, then one fine-print line per kind of information: the numbered affiliation legend, the contact addresses, the date. Kinds never share a line, and the superscript markers appear exactly when the deck names more than one institution.

**Labels**

Every resolved cell carries a label, so appearance comes from native Typst rules:

- `mosaic-cell-title`: the title stack, in every variant. Most variants compose the subtitle and the details inside it too.
- `mosaic-cell-details`: the affiliation and date band, in the `panel` and `academic` variants, which set those tiers outside the title cell.
- `mosaic-cell-authors`: the byline, in the `academic` variant.
- `mosaic-cell-image`: the picture, in the four directional image variants. The `image-background` variant paints the picture as the title cell's background instead, so it has no image cell of its own.

One further label is not a cell: the display line of the title stack carries `mosaic-title-display`, which is where a theme states the title's display size.

**Styling**

The layout is structural. A rule on `<mosaic-cell-title>` reaches the whole composed stack: title, subtitle, and details alike. Recoloring it is what light-on-dark compositions over a photograph need.

```typ
#show label("mosaic-cell-title"): set text(fill: white)
#mosaic.slide(
  layout: "title",
  variant: "image-background",
  image: (path: path("cover.webp"), scrim: black.transparentize(55%)),
)
```

Sizing it works the same way, because the display line carries its own `<mosaic-title-display>` label and the theme's display size lands there rather than on the cell. The tiers below are ordinary ems of the cell, so one rule scales the stack as a unit and the proportions hold. That is how to ask for quiet type in the corner of a photograph.

```typ
#show label("mosaic-cell-title"): set text(size: 0.45em)
```

A theme states the display size on the inner label instead, which leaves the outer one free for the deck to scale:

```typ
#show label("mosaic-title-display"): set text(size: 2em, weight: "semibold")
```

**Parameters**

- `title` (`auto | content | str | none`, default `auto`): Title text. `auto` inherits `setup(title:)` and fails when there is none to inherit; `none` suppresses the title on this slide.
- `subtitle` (`auto | content | str | none`, default `auto`): Subtitle set tight below the title. `auto` inherits `setup(subtitle:)`; `none` suppresses it.
- `date` (`auto | content | str | none`, default `auto`): Display date joined into the fine-print details line. `auto` inherits `setup(date:)`; `none` suppresses it.
- `image` (`none | content | path | dictionary`, default `none`): The picture of the image variants, required there and rejected by the others. Give a native `path(..)` value, ready-made content, or a dictionary whose `path` key holds one and whose `scrim` key quiets the photograph enough to read text over it, as in `(path: path("cover.webp"), scrim: black.transparentize(55%))`; `alt` and `fit` are its other keys. A bare string is rejected: it would resolve inside the package rather than in the deck's project.
- `variant` (`str`, default `"ruled"`): The text design: `ruled`, `centered`, `bordered`, `kicker`, `panel`, `academic`, `image-left`, `image-right`, `image-top`, `image-bottom`, or `image-background`.
- `authors` (`auto | content | str | array | none`, default `auto`): One name, or an array of names and records created with `layouts.author`. `auto` inherits `setup(authors:)`; `none` or `()` suppresses an inherited list.
- `tracks` (`auto | length | ratio | relative | fraction | array`, default `auto`): Sizes the split of a directional image variant, and is rejected by the others. One native Typst track size sizes the picture and is side-independent, so `image-left` and `image-right` stay mirror images; the title region takes the remaining `1fr`. An array of two is in visual order instead, and must be mirrored by hand when the variant flips. `auto` gives the picture the smaller share.
- `rule` (`auto | bool`, default `auto`): Whether to draw the variant's mark: the `ruled` full-width rule, the `bordered` border, the `kicker` opening rule, or the short accent rule that closes the heading stack of the `academic`, `centered`, and image variants and opens the `panel`. `auto` draws the mark everywhere except on `centered` and the image variants, which stay bare unless asked: the first is the plain composition, and on the others the photograph already does that work. `false` removes the mark in every variant.
- `accent` (`color | auto`, default `auto`): Color of the variant's mark. `auto` uses the deck's text color for the `bordered` border and the `kicker` opening rule, and the semantic accent everywhere else: the `ruled` rule, the `panel` rule, the `kicker` eyebrow, and the short rule of `academic`, `centered`, and the image variants. The color belongs to the mark, so where `rule` leaves the mark undrawn there is nothing for it to reach.
- `..removed` (`arguments`): Catches the removed `position` argument so it fails with the variant that replaced it. Accepts nothing.

## layouts.section

Creates a section divider grid.

```typ
section(
  subtitle: none,
  number: none,
  image: none,
  variant: "plain",
  accent: auto,
  tracks: auto
) -> dictionary
```

The section cell's text is the slide's own content, so the surrounding `mosaic.slide` supplies one block. Automatic level-one headings resolve to this layout.

```typ
#mosaic.slide(
  layout: "section",
  number: [02],
  subtitle: [How the grid resolves],
)[Structure]
```

**Variants**

- `plain`: one `section` cell holding the optional number, the title, and the optional subtitle as a plain stack. The layout states no arrangement for it: where the stack sits in the cell, and the title's size and weight, are the theme's, through its rules on `<mosaic-cell-section>` (the default theme sets it flush left at the vertical center). The default of this constructor; a theme's own `layouts.section` and its automatic headings may select another.
- `rule`: a heavy full-width rule with the title hanging beneath it, flush left, the number above the rule.
- `numeral`: the section number set enormous in the line color, bleeding off the top-right edge behind a lower-left title stack.
- `baseline`: title flush left and number flush right sharing one baseline, tied together by a full-width hairline.
- `toc`: every section in the deck listed, the current one alive with its number, the others ghosted.
- `image-left`, `image-right`, `image-top`, `image-bottom`: the `plain` composition beside or above a full-bleed `image` cell, sized by `tracks`.
- `image-background`: the `plain` composition directly over a full-slide picture.

Every image variant requires `image`, and only they take one: write the variant together with `image:`.

The designed text variants (`rule`, `numeral`, `baseline`, `toc`) treat an omitted `number` as the automatic section counter, so they need no argument in the ordinary case. They are compositions of type alone and take no picture. Each one owns its arrangement, as described above, so a theme's alignment rule on the cell does not move it; the theme still decides the display size the composition scales from.

**Labels**

Every resolved cell carries a label, so appearance comes from native Typst rules:

- `mosaic-cell-section`: the section text, in every variant. The number and subtitle are composed inside it, so one rule reaches the whole stack.
- `mosaic-cell-image`: the picture, in the four directional image variants. The `image-background` variant paints the picture as the section cell's background instead, so it has no image cell of its own.

Three further labels are not cells. They mark the tiers composed inside the section cell, so one tier can be restyled without the others: `mosaic-section-title` on the title text, `mosaic-section-number` on the number, and `mosaic-section-subtitle` on the subtitle.

```typ
#show label("mosaic-section-title"): set text(style: "italic")
```

**Styling**

The layout is structural. The arrangement of `plain` and the image variants and the title typography come from the `<mosaic-cell-section>` label rules the theme states. Over a photograph the text inherits the surrounding native text color, so quiet the picture with the image dictionary's `scrim` key and override the cell's text fill.

```typ
#show label("mosaic-cell-section"): set text(fill: white)
#mosaic.slide(
  layout: "section",
  variant: "image-background",
  image: (path: path("cover.webp"), scrim: black.transparentize(55%)),
)[Structure]
```

**Parameters**

- `subtitle` (`content | str | none`, default `none`): Optional subtitle set below the section title.
- `number` (`content | str | none`, default `none`): Optional section number or label. `plain` and the image variants set it above the title and omit it when `none`; the designed text variants build their composition around it and read the automatic section counter when it is `none`.
- `image` (`none | content | path | dictionary`, default `none`): The picture of the image variants, required there and rejected by the others. Give a native `path(..)` value, ready-made content, or a dictionary whose `path` key holds one and whose `scrim` key quiets the photograph enough to read text over it; `alt` and `fit` are its other keys. A bare string is rejected: it would resolve inside the package rather than in the deck's project.
- `variant` (`str`, default `"plain"`): Structural arrangement: `plain`, `rule`, `numeral`, `baseline`, `toc`, `image-left`, `image-right`, `image-top`, `image-bottom`, or `image-background`.
- `accent` (`color | auto`, default `auto`): Color of the section number, in every variant that draws one. `auto` keeps the number subordinate to the title: the semantic muted color resolved by `setup`, or the line color for the `numeral` variant, whose number is texture rather than text. Pass a color to override either. The `baseline` variant ties its number to the title with a hairline, which takes the same color and defaults to the semantic accent. `plain` and the image variants draw a number only when `number` is given, so without one there is nothing for the color to reach.
- `tracks` (`auto | length | ratio | relative | fraction | array`, default `auto`): Sizes the split of a directional image variant, and is rejected by the others. One native Typst track size sizes the picture and is side-independent, so `image-left` and `image-right` stay mirror images; the section region takes the remaining `1fr`. An array of two is in visual order instead, and must be mirrored by hand when the variant flips. `auto` splits the slide evenly.
