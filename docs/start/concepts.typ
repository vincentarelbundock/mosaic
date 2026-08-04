#import "/diagrams/grid-anatomy.typ": diagram as grid-anatomy
#import "/diagrams/slide-planes.typ": diagram as slide-planes

#set document(title: [Concepts])
#metadata((title: "Concepts")) <website-metadata>

#title()

= Vocabulary

On this website, we will refer to the different components of a slide deck in these terms:

- *Slide*: one unit of a presentation.
- *Deck*: a sequence of slides.
- *Cell*: a named area that holds content.
- *Grid*: named cells arranged with horizontal and vertical splits.
- *Split*: a horizontal or vertical division between cells.
- *Track*: the width or height assigned to one child of a split.
- *Inset*: space between a cell's edge and its content.
- *Background*: content drawn behind the content grid across the full slide.
- *Foreground*: content drawn over the content grid across the full slide.
- *Layout*: a ready-made slide arrangement with a grid and, when needed, built-in content or decoration.
- *Variant*: a named alternative arrangement offered by a layout.
- *Theme*: a coordinated set of colors, text styles, and layouts.
- *Frame*: one page of the compiled document; a slide with timed content spans several frames.

= Anatomy of a slide deck

#html.elem("div", attrs: (class: "mosaic-diagram"), html.frame(grid-anatomy))\
#v(1em)

The grid is sandwiched between two full-slide planes. The *background* plane is painted behind the cells. It typically holds a full-slide image, a color wash, or a watermark. The *foreground* plane is painted over the cells. It typically holds a slide number, a logo, or a progress indicator. Neither plane takes space away from the grid.

#v(1em)\
#html.elem("div", attrs: (class: "mosaic-diagram"), html.frame(slide-planes))
#v(1em)\

A *layout* is a ready-made slide design for a familiar slide kind such as a title or section. A layout provides a structural grid and may supply fixed content or limited structural decoration for that design. Each layout offers several named *variants*.

Every cell, the background, and the foreground is a native Typst layer, and each one carries a *label*: `<mosaic-cell-ID>`, `<mosaic-background>`, and `<mosaic-foreground>`. Ordinary Typst `show` and `set` rules can therefore style every part of a slide. See #link("../appearance/styling.html")[Styling cells] for a detailed tutorial.
