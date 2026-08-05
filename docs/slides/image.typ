#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  thumbnail-gallery,
)

#set document(title: [Image slides])
#metadata((title: "Image")) <website-metadata>

#title()

Use `layout: "image"` for any slide whose main content is a picture. In many decks this is the most common explicit slide.

= A figure with a caption

The default `figure` variant places a header above a contained picture, with an optional `caption:` beneath. It never crops, which is what a chart or screenshot needs:

```typ
#m.slide(layout: "image", image: path("fig/gdp.png"))[== Growth since 1950]

#m.slide(
  layout: "image",
  image: path("fig/pie.png"),
  caption: [Teaching, research, admin],
)[== My job]
```

The `figure` variant has header, image, and caption cells but no body, so a single line of commentary belongs in `caption:`. The caption produces a native Typst `figure`, so it follows the deck's `show figure.caption` rules.

= A picture beside text

The directional variants `left`, `right`, `top`, and `bottom` pair a full-bleed picture cell with header and body cells, filled by two positional blocks. Pass `[]` as the second block when the picture needs a title but no body:

```typ
#m.slide(
  layout: "image",
  variant: "right",
  image: path("fig/book.jpg"),
)[== Readings][
  - Almost every week.
  - PDFs on the course site.
]
```

Two arguments control the picture cell:

- `tracks:` sizes it. The value is independent of the side, so `tracks: 40%` means the same thing under `left` and `right`, and the two stay mirror images.
- `fit:` controls cropping. The directional variants default to `"cover"`, which fills the cell by cropping the picture. Pass `fit: "contain"` for a chart, a book cover, or any picture whose edges carry meaning.

= A full-bleed picture

The `full` variant puts the picture behind a single body cell that covers the whole slide. The cell inherits the deck's ordinary text color, so text over a photograph needs two things: a `scrim:` in the image specification to darken the picture, and a text fill override in the body:

```typ
#m.slide(
  layout: "image",
  variant: "full",
  image: (
    path: path("fig/auditorium.jpg"),
    scrim: black.transparentize(45%),
  ),
)[
  #set text(fill: white)
  == Who are you?
]
```

Omit the body entirely for a bare picture slide with no text at all. The `full` variant also works for a custom opening slide: when no #link("title.html")[title variant] fits, write the title as ordinary text over a full-bleed picture.

#embedded-example(
  calepin.elements.gallery,
  "structure/image-layout",
  frames: 4,
  title: "The figure, right, bottom, and full variants of the image layout",
  renderer: thumbnail-gallery,
)

Image paths inside layout arguments cross the package boundary, so wrap every asset path in Typst's `path()`; a bare string is searched for inside the installed Mosaic package.

Named arguments on an image slide refine the configured layout rather than replacing it; see #link("content.html#layout-fields-on-a-slide")[Layout fields on a slide]. For image loading, fitting, scrims, and figures in ordinary cells, see #link("../content/images.html")[Images]; for a picture on a plane behind the whole grid, see #link("../furniture/planes.html")[Background and foreground].
