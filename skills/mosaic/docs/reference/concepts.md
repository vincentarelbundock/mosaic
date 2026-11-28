# Concepts

## Vocabulary

On this website, we will refer to the different components of a slide deck in these terms:

- **Slide**: one unit of a presentation.
- **Deck**: a sequence of slides.
- **Cell**: a named area that holds content.
- **Grid**: the arrangement of cells you build yourself, with horizontal and vertical splits.
- **Split**: a horizontal or vertical division between cells, built with `columns` or `rows`.
- **Track**: the width or height assigned to one child of a split.
- **Inset**: space between a cell's edge and its content.
- **Plane**: a full-slide layer drawn outside the grid. Every slide has two.
- **Background**: the plane drawn behind the grid.
- **Foreground**: the plane drawn over the grid.
- **Layout**: a grid Mosaic already built for a familiar slide kind, supplying fixed content or decoration when that kind needs it.
- **Variant**: a named alternative arrangement offered by a layout.
- **Component**: a reusable piece of slide content such as a callout, quote, or badge.
- **Theme**: a coordinated set of colors, text styles, and layouts.
- **Step**: one stage of a slide that reveals or replaces content incrementally. Each step renders as its own frame.
- **Frame**: one page of the compiled document; a slide built from several steps spans several frames.

## Anatomy of a slide deck

The grid is sandwiched between two full-slide planes. The **background** plane is painted behind the cells. It typically holds a full-slide image, a color wash, or a watermark. The **foreground** plane is painted over the cells. It typically holds a slide number, a logo, or a progress indicator. Neither plane takes space away from the grid. The [Background](../slides/background.md) and [Foreground](../slides/foreground.md) pages show how to use them.

Where a grid is the structure you build, a **layout** is one Mosaic has already built for a familiar slide kind. Mosaic ships layouts for [content](../slides/content.md), [titles](../slides/title.md), [sections](../slides/section.md), and [images](../slides/image.md); each offers several named **variants** of its arrangement. [Custom slides](../slides/custom.md) build a grid instead.

Every cell, the background, and the foreground is a native Typst layer, and each one carries a **label**: `<mosaic-cell-ID>`, `<mosaic-background>`, and `<mosaic-foreground>`. Ordinary Typst `show` and `set` rules can therefore style every part of a slide. See [Styling cells](../appearance/styling.md) for a detailed tutorial.
