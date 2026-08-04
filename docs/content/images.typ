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

When one picture is the whole point of a slide, use the #link("../slides/layouts.html#image")[image layout] instead of placing it in a cell yourself. Place images in cells when they share the slide with other content. The most common case is two figures side by side on a two-column content slide, each with `fit: "contain"` so neither is cropped:

```typ
#m.slide(layout: "content", columns: 2)[== Before and after][
  #m.components.image(path("fig/equilibrium_0.png"), fit: "contain")
][
  #m.components.image(path("fig/equilibrium_1.png"), fit: "contain")
]
```

When each picture needs its own caption, wrap it in a native `figure` and give both images the same explicit height so the captions line up:

```typ
#m.slide(layout: "content", columns: 2)[== Two failure modes][
  #figure(
    m.components.image(path("fig/first.jpg"), fit: "contain", height: 75%),
    caption: [Ineffective donations],
  )
][
  #figure(
    m.components.image(path("fig/second.jpg"), fit: "contain", height: 75%),
    caption: [Ineffective cooperation],
  )
]
```

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

= Figures

Native `figure` semantics, captions, numbering, and references continue to work inside cells.

#embedded-example(
  calepin.elements.gallery,
  "blocks/figure",
  frames: 1,
  title: "Semantic figure in a cell",
)
