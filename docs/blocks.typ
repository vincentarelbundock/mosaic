#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Content blocks])
#metadata((title: "Content blocks")) <website-metadata>

#title()

Cells hold ordinary Typst content. This page collects the content you most often
place inside them: images, the reusable `m.components` library, and math. None
of these create slides or grids on their own; they are values you drop into a
cell, a background, a foreground, or any native Typst composition.

= Images

Mosaic decides whether an image belongs to a cell, the
#link("furniture.html")[background, or the foreground]; image loading, fitting,
figures, captions, and references remain native Typst.

== Slide-sized images

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

== Backgrounds

Pass a slide-sized image through the slide's background. A light wash can
quiet the photograph and improve contrast with dark foreground text.

#verbatim-example("images/background.typ")

#slideshow(
  calepin.elements.gallery,
  "images/background",
  1,
  "Full-slide background image",
)

== Image fitting

The orange lines frame the full area of each cell. On the left, the white
space between the frame and the picture is the cell's inset. The right cell
shows more of the original picture because `contain` keeps the whole image
visible, whereas `cover` crops it to fill the available image area.

#verbatim-example("images/fit.typ")

#slideshow(calepin.elements.gallery, "images/fit", 1, "Image fit modes")

== Full-bleed cells

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

== Figures

Native `figure` semantics, captions, numbering, and references continue to
work inside cells.

#verbatim-example("images/figure.typ")

#slideshow(
  calepin.elements.gallery,
  "images/figure",
  1,
  "Semantic figure in a cell",
)

= Components

`m.components` provides reusable Typst content to place inside cells, or inside
any native Typst composition. Each function has an independent example and
gallery.

== `frame()`

Wrap arbitrary content in a clipped semantic frame.

#verbatim-example("libraries/components/frame.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/frame",
  2,
  "components.frame()",
)

== `callout()`

Emphasize content with a semantic side stripe and optional title.

#verbatim-example("libraries/components/callout.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/callout",
  1,
  "components.callout()",
)

== `label()`

Create a compact inline label with configurable corners and text styling.

#verbatim-example("libraries/components/label.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/label",
  1,
  "components.label()",
)

== `quote()`

Create a borderless quotation treatment with optional attribution.

#verbatim-example("libraries/components/quote.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/quote",
  1,
  "components.quote()",
)

== `divider()`

Separate content with an unlabeled or labeled horizontal divider.

#verbatim-example("libraries/components/divider.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/divider",
  1,
  "components.divider()",
)

== `progress()`

Show the current position in a deck. Progress follows Mosaic's logical slide
counter automatically, including when a slide has multiple incremental frames.
Use `"1/1"` or `"1"` for numbers, `"circle"` for a compact corner indicator, and
`"line"` for an edge-to-edge bar. Each variant below sits on the slide
foreground, but the component can be used in any cell or native container.

#verbatim-example("libraries/components/progress-numbers.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/progress-numbers",
  3,
  "layouts.default(progress: \"1/1\")",
)

#slideshow(
  calepin.elements.gallery,
  "libraries/components/progress-line",
  3,
  "layouts.default(progress: \"line\")",
)

Add a progress indicator to any layout, or to a custom grid, through the
`foreground` argument. Here `slide-progress()` builds a two-column slide with a
foreground bar:

#verbatim-example("libraries/components/custom-slide.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/custom-slide",
  3,
  "A reusable custom-grid slide function with foreground progress",
)

= Math

Typst's native math notation works inside Mosaic slides. Incremental commands
can then focus attention on one part of an equation at a time without changing
its layout.

== Incremental

Start with the complete equation so the audience can see its overall
structure. On later frames, replace each plain term with a colored underbrace
and a short explanation. Keeping earlier annotations visible makes the
interpretation accumulate across the sequence. This example breaks a Bellman
optimality equation into its immediate reward, discount factor, and expected
optimal future value.

#verbatim-example("incremental/math.typ")

#slideshow(
  calepin.elements.gallery,
  "incremental/math",
  4,
  "Annotate a Bellman equation component by component",
)

== LaTeX

The #link("https://typst.app/universe/package/mitex/")[MiTeX package] converts
LaTeX math source into Typst content. Import `mi` for inline equations and
`mitex` for display equations, useful when reusing existing equations or
collaborating with LaTeX authors.

#verbatim-example("math/mitex.typ")

#slideshow(
  calepin.elements.gallery,
  "math/mitex",
  1,
  "Render LaTeX equations with MiTeX",
)

== Theorem

The #link("https://typst.app/universe/package/ctheorems/")[ctheorems package]
provides numbered, referenceable theorem and proof environments. Define the
environments once, install its `thmrules` show rule, and use them normally
inside a Mosaic slide.

#verbatim-example("math/theorem.typ")

#slideshow(
  calepin.elements.gallery,
  "math/theorem",
  1,
  "Typeset a theorem and proof",
)
