# Calmly: Mosaic adaptation

A Mosaic/Typst re-creation of the **Calmly** presentation theme for Touying by Yichen Han ([github.com/YHan228/calmly-touying](https://github.com/YHan228/calmly-touying)), which is distributed under the [MIT License](https://github.com/YHan228/calmly-touying/blob/main/LICENSE). This deck reproduces the appearance of Calmly's default look (the "tomorrow" palette, light variant, Moloch-style header, footer progress bar); the original theme's source is not redistributed here.

Unlike the other example decks, this one does not import a bundled Mosaic theme. `preamble.typ` is a complete deck-local theme definition passed to `mosaic.themes.setup`, which is what a Mosaic port of an outside design looks like: a palette, one `apply` function holding every `set` and `show` rule, and a layout dictionary. It shows how Calmly's parts map onto Mosaic's:

| Calmly | This deck |
| --- | --- |
| `colortheme: "tomorrow"`, light variant | the theme's `colors` palette |
| Moloch header bar | a `show label("mosaic-cell-header")` rule painting the cell edge to edge |
| Footer progress bar and slide counter | a `footer` cell default holding two `components.progress` calls |
| `title-slide(layout: "moloch")` | `layouts.title(variant: "ruled")` |
| `section-slide()` | a small custom grid: the section cell over an accent rule |
| `highlight-box`, `alert-box`, `example-box`, `themed-block` | `components.callout` with role `accent`, `warning`, or `error` |
| `focus-slide` | a body-only slide with a gradient background plane |
| `standout-slide` | `slide(invert: true)` |
| `#pause` | `steps.pause` |

The theme states the palette and those few structural gestures, and leaves everything else to Mosaic's defaults: it is a design rather than a transcription, so it does not chase Calmly's spacing token by token. The same file closes with the two slide shapes Mosaic has no layout for; the boxes are called directly in `main.typ`.

Build the PDF (run from this directory):

```sh
make
```

Calmly recommends Source Sans 3 for text and JetBrains Mono for code; the theme falls back to Inter, Liberation Sans, and DejaVu Sans when they are missing.
