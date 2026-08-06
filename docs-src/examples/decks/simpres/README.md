# Simpres: Mosaic adaptation

A Mosaic/Typst re-creation of the **Simpres** presentation template for Touying by thy0s ([github.com/thy0s/touying-simpres](https://github.com/thy0s/touying-simpres)), which is distributed under the [MIT License](https://github.com/thy0s/touying-simpres/blob/main/LICENSE). The original template's source is not redistributed here.

Like the `calmly/` deck, this one does not import a bundled Mosaic theme: `preamble.typ` is a complete deck-local theme definition passed to `mosaic.themes.setup`. Simpres is a small theme, so the mapping is short:

| Simpres | This deck |
| --- | --- |
| `primary`, `secondary`, `neutral-*` colors | the theme's `colors` palette |
| Navy header band with the section name over the slide title | a `show label("mosaic-cell-header")` rule painting the cell edge to edge, plus a level-2 heading rule that prepends the enclosing section |
| Footer with date and slide counter | a `footer` cell default reading `info().date` beside `components.progress` |
| `title-slide` | `layouts.title(variant: "ruled")` |
| `new-section-slide` | `layouts.section(variant: "baseline")` |
| `outline-slide` | a slide whose body is a native `outline()` |
| `focus-slide` | a body-only slide with a navy `background:` plane, written inline |

The theme states the palette and those few structural gestures, and leaves everything else to Mosaic's defaults: it is a design rather than a transcription, so it does not chase Simpres's spacing token by token. The deck is two files: there is no preamble, because nothing in it needed a helper.

Build the PDF (run from this directory):

```sh
make
```

The build uses CeTZ for the figure and a native Typst bibliography over `references.bib`. Simpres sets Source Sans 3 for text and Source Code Pro for code; the theme falls back to Liberation Sans and DejaVu Sans Mono when they are missing.
