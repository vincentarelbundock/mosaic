# Images

An image can sit in a cell, in a layout that is built around one, or on a [background](../slides/background.md) or [foreground](../slides/foreground.md) plane. Image loading, fitting, figures, captions, and references remain native Typst. This page is where pictures are explained once: what a picture is, where a layout can put one, and how to fit, quiet, and caption it.

> **Requires Mosaic 0.0.3.** The title layout's five `image-*` variants are new; the released version writes `variant: "image"` with a `position:` there. Everything else on this page, the section and image layouts included, is the same in both versions. This is the development version, which is not on Typst Universe yet: a deck that uses it imports `@local/mosaic:0.0.3` rather than the released `@preview/mosaic:0.0.1`. See [Install](../start/install.md).

## Asset paths

An image or other asset named inside a layout or component argument crosses the package boundary: the function runs inside the installed Mosaic package, so a bare string like `"cover.webp"` is looked up in the package's own files rather than in your project, and the asset is not found. Wrap every asset path in Typst's `path()` so its location stays anchored to the calling document:

```typ
#m.slide(layout: "image", image: path("fig/gdp.png"))[== Growth since 1950]
```

This applies wherever a layout or component takes a path: the `image:` argument of the [title](../slides/title.md), [section](../slides/section.md), and [image](../slides/image.md) layouts, and the source of `m.components.image()` and `m.components.figure()`.

## Pictures in layouts

Three layouts are built around a picture: [image](../slides/image.md), [title](../slides/title.md), and [section](../slides/section.md). All three take the picture itself the same way, as `image:`. It is one of three things:

- A `path(..)`, for the common case where the file is all there is to say. The layout sizes and fits it to its region.
- A dictionary, when the picture needs a scrim, a fit, or alt text: `(path: path(..), alt: .., fit: .., scrim: ..)`. The keys are described in the sections below.
- Content, when you already have a picture element: the result of `m.components.image(..)`, or a drawing made in code.

Where the picture goes is chosen by the layout's `variant:`, the same argument that selects every other arrangement a layout offers:

|  |  |
| --- | --- |
| Image layout | `figure` (the default: a contained picture under a header, where a chart or a screenshot goes), `left`, `right`, `top`, `bottom` (a full-bleed picture on that side, with the text in the rest), and `full` (the picture behind the text). |
| Title and section layouts | `image-left`, `image-right`, `image-top`, `image-bottom`, and `image-background`. The same five names in both. |

For a picture on one side, `tracks:` sizes it: one track size such as `40%` is the picture's share whichever side it is on, so left and right stay mirror images.

```typ
// A file, placed.
#m.slide(layout: "image", variant: "right", image: path("fig/book.jpg"))[== Readings][]

// A picture that needs a scrim and a description is a dictionary.
#m.slide(
  layout: "image",
  variant: "full",
  image: (
    path: path("fig/auditorium.jpg"),
    scrim: black.transparentize(45%),
    alt: "A full lecture hall seen from the stage",
  ),
)[
  #set text(fill: white)
  == Who are you?
]
```

## Slide-sized images

Typst's standard `image()` works perfectly well in Mosaic and remains useful when its native sizing defaults are what you want. `m.components.image()` is a small convenience for the common slide case: it defaults both `width` and `height` to `100%` and `fit` to `"cover"`. Other native arguments, including `alt`, pass straight through.

```typ
#m.components.image(
  path("photo.webp"),
  alt: "A mountain landscape",
)
```

When one picture is the whole point of a slide, use the [image layout](../slides/image.md) instead of placing it in a cell yourself.

## Figures in a cell

Place images in cells when they share the slide with other content, and reach for `m.components.figure()` there. Its defaults are the ones a chart or a photograph in a cell wants rather than the ones a full-bleed background wants: `fit` is `"contain"`, so nothing is cropped, and the picture is centred and sized to its cell. The most common case is two figures side by side on a two-column content slide:

```typ
#m.slide(layout: "content", columns: 2)[== Before and after][
  #m.components.figure(path("fig/equilibrium_0.png"))
][
  #m.components.figure(path("fig/equilibrium_1.png"))
]
```

A `caption:` composes a native Typst `figure` around the picture, and the picture gives up exactly the height the caption and its gap consume. Nothing has to be measured by hand: each picture is as large as its own aspect ratio allows, and the two captions share one baseline at the foot of the cells whether the pictures are portrait, landscape, or one of each.

```typ
#m.slide(layout: "content", columns: 2)[== Two failure modes][
  #m.components.figure(
    path("fig/first.jpg"),
    caption: [Ineffective donations],
  )
][
  #m.components.figure(
    path("fig/second.jpg"),
    caption: [Ineffective cooperation],
  )
]
```

The default `height: auto` reads the size of the cell, not the space left over inside it. A figure that follows prose in the same cell therefore needs an explicit height, and captions directly beneath itself rather than at the foot of the cell:

```typ
#m.slide(layout: "content", columns: 2)[== Two revenues][
  - Payroll taxes carry the system
  - Consumption taxes are regressive
  #m.components.figure(path("fig/photo.jpg"), height: 50%)
][
  #m.components.figure(path("fig/chart.png"), caption: [Shares since 1980])
]
```

`m.components.image()` stays the right call for a background plane, or for a cell that should be filled edge to edge and where cropping is the point.

### Tables, diagrams, and other bodies

A figure's body does not have to be a picture. Pass content instead of a source and the same caption sizing applies, which is the way to caption a table or a diagram drawn in code:

```typ
#m.components.figure(
  table(columns: 3, ..cells),
  caption: [Estimates by specification],
  kind: table,
)
```

Such a body cannot be re-fitted the way a picture can, so it keeps its own size and is scaled as a whole only when it is too large for the cell, exactly as [`m.fit`](../presenting/overflow.md#fitting-a-block-to-its-cell) does. A body that already fits is left untouched, and it is never magnified past its natural size. The caption keeps the size the deck gave it either way: only the body is scaled.

Two details follow from that. A content body that does not fill its cell sits at the top of it and captions directly beneath itself, rather than stretching and captioning at the foot of the cell as a picture does. And scaling costs a table the `kind` a native `figure` would have detected on its own, so state `kind: table` when you want table numbering and the "Table" supplement. Further named arguments reach the native `figure` here, where they reach the native `image` for a picture source.

## Scrims

A photograph rarely makes a good backdrop for text on its own: the picture is bright in some places and dark in others, so the same text is legible in one corner and lost in the next. A *scrim* is the standard fix. It is a translucent layer painted over the picture and under the text, which compresses the photograph's tonal range and leaves the text with something predictable to sit on.

In Mosaic a scrim is an ordinary Typst paint. It accepts exactly what a `fill` accepts, and there is no separate vocabulary to learn:

```typ
#m.components.image(
  path("photo.webp"),
  scrim: black.transparentize(65%),
  alt: "A mountain landscape",
)
```

The paint's own transparency is the strength of the scrim. Typst spells that as the amount of transparency rather than the amount of coverage, so `black.transparentize(65%)` is black at 35% opacity: a light touch. `black.transparentize(20%)` is nearly opaque.

Three kinds of paint cover almost every case:

- A *flat dark color* such as `black.transparentize(45%)` darkens the whole picture evenly. Pair it with a text color rule for light text on a dark picture.
- A *gradient* such as `gradient.linear(black.transparentize(100%), black.transparentize(10%), angle: 90deg)` darkens only the area the text occupies and leaves the rest of the picture untouched. This is the most common choice when the photograph is the point of the slide.
- A *flat light color* such as `white.transparentize(25%)` washes the picture out instead, which keeps the deck's ordinary dark text readable and needs no color rule at all.

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup

#let river = "/docs-src/assets/images/title-river.webp"
#let describe = "Autumn wetlands under a pale overcast sky"

// The same white text runs across the first three frames, so the scrim is the
// only thing that changes between them.
#let light-text = it => {
  show label("mosaic-cell-body"): set text(fill: white)
  it
}

// No scrim. White text disappears into the pale sky.
#[
  #show: light-text
  #m.slide(
    layout: m.layouts.image(
      (path: path(river), alt: describe),
      variant: "full",
    ),
    cells: (body: [
      == Without a scrim

      The picture is unmodified, so light text survives over the dark reeds
      and vanishes against the sky.
    ],
    ),
  )
]

// A flat color quiets the whole frame by the same amount.
#[
  #show: light-text
  #m.slide(
    layout: m.layouts.image(
      (
        path: path(river),
        scrim: black.transparentize(45%),
        alt: describe,
      ),
      variant: "full",
    ),
    cells: (body: [
      == A flat scrim

      `scrim: black.transparentize(45%)` covers the picture with black at 55%
      opacity. The text is now readable anywhere on the slide.
    ],
    ),
  )
]

// A gradient darkens the band the text occupies and releases the rest.
#[
  #show: light-text
  #m.slide(
    layout: m.layouts.image(
      (
        path: path(river),
        scrim: gradient.linear(
          black.transparentize(100%),
          black.transparentize(10%),
          angle: 90deg,
        ),
        alt: describe,
      ),
      variant: "full",
    ),
    cells: (body: [
      #v(1fr)

      == A gradient scrim

      A scrim accepts any Typst paint, so `gradient.linear(..)` protects the
      text along the bottom edge and leaves the horizon at full strength.
    ],
    ),
  )
]

// A scrim is not always dark: a white wash lifts the picture behind the
// deck's ordinary text color.
#m.slide(
  layout: m.layouts.image(
    (
      path: path(river),
      scrim: white.transparentize(25%),
      alt: describe,
    ),
    variant: "full",
  ),
  cells: (body: [
    == A light scrim

    `scrim: white.transparentize(25%)` washes the picture out instead, which
    keeps the deck's ordinary dark text readable and needs no color rule.
  ],
  ),
)
```

The scrim is a property of the picture, not of the cell around it, so it covers exactly the image area whether that area is a full-bleed background or an inset figure.

Not every photograph needs a scrim. Many already contain a quiet region: a sky, a wall, a shadow. Put the text there and no scrim is needed. Over a pale region, the deck's ordinary dark text is easier to read than white lettering over a scrim. Use a scrim when the photograph is busy or mid-toned exactly where the text must sit.

### Where a scrim can be specified

One spelling covers every place an image can appear.

On `m.components.image()`, pass it as an argument, as above. That is the form to use for images in cells and for the planes described on the [Background](../slides/background.md) and [Foreground](../slides/foreground.md) pages.

In the `title`, `section`, and `image` layouts, `scrim` is one of the keys of the picture dictionary, alongside `path`, `alt`, and `fit`:

```typ
#m.slide(
  layout: "section",
  variant: "image-background",
  image: (
    path: path("cover.webp"),
    scrim: black.transparentize(45%),
    alt: "Coastal city lights at night",
  ),
)[Cities after dark]
```

A scrim changes the picture, never the text. Light-on-dark compositions still recolor the text, with a `set text` rule in the slide body or through the cell's label, as [Styling a whole slide](../appearance/styling.md#styling-a-whole-slide) shows.

## Image fitting

The orange lines frame the full area of each cell. On the left, the white space between the frame and the picture is the cell's inset. The right cell shows more of the original picture because `contain` keeps the whole image visible, whereas `cover` crops it to fill the available image area.

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup

// Frame both image cells by targeting their labels with a native stroke.
#let framed(id) = it => {
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    height: 100%,
    stroke: 3pt + rgb("#e69f00"),
    body,
  )
  it
}
#show: framed("a")
#show: framed("b")

#m.slide(layout: 
  m.grids.columns(
    m.grids.cell("a"),
    m.grids.cell("b"),
  ),
)[
  #m.components.image(
    path("/docs-src/assets/images/dog.webp"),
    alt: "A brown dog",
  )
][
  #m.components.image(
    path("/docs-src/assets/images/dog.webp"),
    fit: "contain",
    alt: "A brown dog",
  )
]
```

## Full-bleed cells

Cells have an `inset` by default. To make an image cover the full cell, including that content margin, set the inset to `0pt`. The defaults of `m.components.image()` then cover the complete cell. Declare that fixed image content and the zero inset directly with `cell`.

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup

// The text cell centers its content vertically through its label.
#show label("mosaic-cell-b"): set align(left + horizon)

#m.slide(layout: m.grids.columns(
  m.grids.track(
    1fr,
    m.grids.cell(
      id: "a",
      inset: 0pt,
      content: m.components.image(
        path("/docs-src/assets/images/dog.webp"),
        alt: "A brown dog",
      ),
    ),
  ),
  m.grids.track(
    2fr,
    m.grids.cell("b"),
  ),
))[
  == A full-bleed image cell

  Cells have an `inset` by default. To cover the entire cell, set it to `0pt`;
  `m.components.image()` supplies the full-size cover defaults.

  The first child receives one third of the width through
  `m.grids.track(1fr, ...)`.
]
```

## Native figures

`m.components.figure()` composes a native Typst `figure`, so captions take the deck's own `show figure.caption` styling, and numbering and references work as usual. Switch numbering off with an ordinary `set figure(numbering: none)`. Writing the `figure` out yourself works too, and is the way in when the body is a table, a diagram, or anything else that is not a picture.

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set page(fill: rgb("#f4f1ea"))
#set text(size: 22pt, fill: rgb("#172033"))

#m.slide(layout: m.grids.columns("a", "b"))[
  #m.components.figure(
    path("/docs-src/assets/images/bonsai.webp"),
    caption: [Figure in a cell.],
    alt: "A pine bonsai",
  )
][
  == Figures fit their cell

  `m.components.figure(..)` contains the picture, centres it, and leaves the caption exactly the height it needs.
]
```
