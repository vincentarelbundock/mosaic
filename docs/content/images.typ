#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Images])
#metadata((title: "Images")) <website-metadata>

#title()

An image can sit in a cell or on a
#link("../furniture/planes.html")[background or foreground plane]. Image loading,
fitting, figures, captions, and references remain native Typst. Full-slide photographic backgrounds are documented on the #link("../furniture/planes.html")[Background and foreground] page.

= Slide-sized images

Typst's standard `image()` works perfectly well in Mosaic and remains useful when its native sizing defaults are what you want. `m.components.image()` is a small convenience for the common slide case: it defaults both `width` and `height` to `100%` and `fit` to `"cover"`. Other native arguments, including `alt`, pass straight through. Use Typst's native `path()` for an image in your project so its location remains anchored to the calling document across the package boundary.

```typ
#m.components.image(
  path("photo.webp"),
  alt: "A mountain landscape",
)
```

When one picture is the whole point of a slide, use the #link("../slides/layouts.html#image")[image layout] instead of placing it in a cell yourself.

= Figures in a cell

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

== Tables, diagrams, and other bodies

A figure's body does not have to be a picture. Pass content instead of a source and the same caption sizing applies, which is the way to caption a table or a diagram drawn in code:

```typ
#m.components.figure(
  table(columns: 3, ..cells),
  caption: [Estimates by specification],
  kind: table,
)
```

Such a body cannot be re-fitted the way a picture can, so it keeps its own size and is scaled as a whole only when it is too large for the cell, exactly as #link("../slides/cells.html")[`m.fit`] does. A body that already fits is left untouched, and it is never magnified past its natural size. The caption keeps the size the deck gave it either way: only the body is scaled.

Two details follow from that. A content body that does not fill its cell sits at the top of it and captions directly beneath itself, rather than stretching and captioning at the foot of the cell as a picture does. And scaling costs a table the `kind` a native `figure` would have detected on its own, so state `kind: table` when you want table numbering and the "Table" supplement. Further named arguments reach the native `figure` here, where they reach the native `image` for a picture source.

= Scrims

A photograph rarely makes a good backdrop for text on its own: the picture is bright in some places and dark in others, so the same text is legible in one corner and lost in the next. A #emph[scrim] is the standard fix. It is a translucent layer painted over the picture and under the text, which compresses the photograph's tonal range and leaves the text with something predictable to sit on.

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

- A #emph[flat dark color] such as `black.transparentize(45%)` darkens the whole picture evenly. Pair it with a text color rule for light text on a dark picture.
- A #emph[gradient] such as `gradient.linear(black.transparentize(100%), black.transparentize(10%), angle: 90deg)` darkens only the area the text occupies and leaves the rest of the picture untouched. This is the most common choice when the photograph is the point of the slide.
- A #emph[flat light color] such as `white.transparentize(25%)` washes the picture out instead, which keeps the deck's ordinary dark text readable and needs no color rule at all.

#embedded-example(
  calepin.elements.gallery,
  "blocks/image-scrim",
  frames: 4,
  title: "The same photograph with no scrim, a flat scrim, a gradient scrim, and a light scrim",
)

The scrim is a property of the picture, not of the cell around it, so it covers exactly the image area whether that area is a full-bleed background or an inset figure.

Not every photograph needs a scrim. Many already contain a quiet region: a sky, a wall, a shadow. Put the text there and no scrim is needed. Over a pale region, the deck's ordinary dark text is easier to read than white lettering over a scrim. Use a scrim when the photograph is busy or mid-toned exactly where the text must sit.

== Where a scrim can be specified

One spelling covers every place an image can appear.

On `m.components.image()`, pass it as an argument, as above. That is the form to use for images in cells and for the `background` and `foreground` planes described on the #link("../furniture/planes.html")[Background and foreground] page.

In the `title`, `section`, and `image` layouts, the image is given as a specification dictionary, and `scrim` is one of its keys alongside `path`, `alt`, and `fit`:

```typ
#m.slide(layout: m.layouts.title(
  title: [Cities after dark],
  variant: "image-background",
  image: (
    path: path("cover.webp"),
    scrim: black.transparentize(45%),
    alt: "Coastal city lights at night",
  ),
))
```

A scrim changes the picture, never the text. Light-on-dark compositions still recolor the text through the cell's label, as the #link("../slides/layouts.html")[Layouts] page shows for the title and section layouts.

= Image fitting

The orange lines frame the full area of each cell. On the left, the white space between the frame and the picture is the cell's inset. The right cell shows more of the original picture because `contain` keeps the whole image visible, whereas `cover` crops it to fill the available image area.

#embedded-example(
  calepin.elements.gallery,
  "blocks/image-fit",
  frames: 1,
  title: "Image fit modes",
)

= Full-bleed cells

Cells have an `inset` by default. To make an image cover the full cell, including that content margin, set the inset to `0pt`. The defaults of `m.components.image()` then cover the complete cell. Declare that fixed image content and the zero inset directly with `cell`.

#embedded-example(
  calepin.elements.gallery,
  "blocks/full-bleed-image",
  frames: 1,
  title: "Full-bleed image cell",
)

= Native figures

`m.components.figure()` composes a native Typst `figure`, so captions take the deck's own `show figure.caption` styling, and numbering and references work as usual. Switch numbering off with an ordinary `set figure(numbering: none)`. Writing the `figure` out yourself works too, and is the way in when the body is a table, a diagram, or anything else that is not a picture.

#embedded-example(
  calepin.elements.gallery,
  "blocks/figure",
  frames: 1,
  title: "A captioned figure sized to its cell",
)
