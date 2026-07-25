#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Images])
#metadata((title: "Images")) <website-metadata>

#title()

Images bring together the placement concepts from #link("grids.html")[Grids],
#link("background.html")[Background], and
#link("foreground.html")[Foreground]. Mosaic decides whether an image belongs to a
cell, the background, or the foreground; image loading, fitting, figures,
captions, and references remain native Typst.

= Slide-sized images

Typst's standard `image()` works perfectly well in Mosaic and remains useful
when its native sizing defaults are what you want. `m.image()` is a small
convenience for the common slide case: it defaults both `width` and `height` to
`100%` and `fit` to `"cover"`. Other native arguments, including `alt`, pass
straight through. Use Typst's native `path()` for an image in your project so
its location remains anchored to the calling document across the package
boundary.

```typ
#m.image(
  path("photo.webp"),
  alt: "A mountain landscape",
)
```

The optional, mutually exclusive `lighten` and `darken` arguments add a white
or black wash. Their ratio is the opacity of the wash:

```typ
#m.image(
  path("photo.webp"),
  darken: 35%,
  alt: "A mountain landscape",
)
```

= Backgrounds

Pass a slide-sized image through the slide's background. A light wash can
quiet the photograph and improve contrast with dark foreground text.

#verbatim-example("images/background.typ")

#slideshow(
  calepin.elements.gallery,
  "images/background",
  1,
  "Full-slide background image",
)

= Image fitting

The orange lines frame the full area of each cell. On the left, the white
space between the frame and the picture is the cell's inset. The right cell
shows more of the original picture because `contain` keeps the whole image
visible, whereas `cover` crops it to fill the available image area.

#verbatim-example("images/fit.typ")

#slideshow(calepin.elements.gallery, "images/fit", 1, "Image fit modes")

= Full-bleed cells

Cells have an `inset` by default. To make an image cover the full cell,
including that content margin, set the inset to `0pt`. The defaults of
`m.image()` then cover the complete cell. Declare that fixed image
content and the zero inset directly with `cell`.

#verbatim-example("images/cell.typ")

#slideshow(
  calepin.elements.gallery,
  "images/cell",
  1,
  "Full-bleed image cell",
)

= Figures

Native `figure` semantics, captions, numbering, and references continue to
work inside cells.

#verbatim-example("images/figure.typ")

#slideshow(
  calepin.elements.gallery,
  "images/figure",
  1,
  "Semantic figure in a cell",
)

= Foregrounds

Foreground content overlays the slide without affecting grid measurements.

== Logos

Put the logo image inside `place` and pass the result to `foreground`.
The alignment selects an anchor such as `top + left`, `center`, or
`bottom + right`; `dx` and `dy` provide precise offsets from that anchor.
Together, they can position a logo anywhere on the slide.

#verbatim-example("images/foreground.typ")

#slideshow(
  calepin.elements.gallery,
  "images/foreground",
  1,
  "Logo in the foreground",
)
