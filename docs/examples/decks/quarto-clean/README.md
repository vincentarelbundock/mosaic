# Clean: Mosaic adaptation

A Mosaic/Typst re-creation of the **Clean** theme for Touying and Quarto by Kazuharu Yanagimoto ([github.com/kazuyanagimoto/quarto-clean-typst](https://github.com/kazuyanagimoto/quarto-clean-typst)), which is distributed under the [MIT License](https://github.com/kazuyanagimoto/quarto-clean-typst/blob/main/LICENSE). Clean is itself inspired by Grant McDermott's [Clean theme](https://github.com/grantmcdermott/quarto-revealjs-clean) for Quarto and Reveal.js. The original theme's source is not redistributed here.

The `calmly/` and `simpres/` decks each write a whole theme definition. This one does not, because it does not need to: Clean is quiet, Mosaic's bundled Default theme is quiet, and the distance between them is small. `preamble.typ` starts from `mosaic.themes.default.definition` and merges over it, so the file states the *difference* rather than a look:

| Clean | This deck |
| --- | --- |
| `color-accent`, `color-accent2`, `color-jet` | three keys merged over Default's light palette |
| Roboto Light at 20pt | two keys merged over Default's `options` |
| `title-slide` | `layouts.title(variant: "ruled", rule: false)` |
| `new-section-slide` | `layouts.section(variant: "plain")` |
| Slide header from the level-2 heading | Default's `header` cell, unchanged |
| Level-3 heading as an italic accent standfirst | one `show heading.where(depth: 3)` rule |
| Triangle and arrow list markers, accent enum numbering | `set list(marker: ..)` and `set enum(numbering: ..)` |
| `alert()`, `fg()` | `text(fill: ..)` |
| `bg()` | native `highlight()` |
| `.button` | `components.badge(role: "accent")` |

Links, tables, captions, the section cell's alignment, and the corner position indicator are all inherited from Default and never mentioned. Clean's rules are declared after Default's and therefore win, because a rule declared later takes precedence and everything in `apply` after the `show: base.apply` line sits inside the body Default styles.

Four things are deliberately not chased, all in exchange for code that stays this short:

- Clean's slide counter reads `3 / 8` in the footer; this deck inherits Default's corner progress ring instead, which costs no lines and hides itself on title and section slides.
- Clean's title-page subtitle is italic in the accent color. Mosaic composes the subtitle inside the title cell, where no label reaches it, so `main.typ` styles the subtitle where it declares it.
- Clean lays its authors out one per column; Mosaic's title layout sets them as a byline over an affiliation legend and a contact line. Same information, its own arrangement.
- Clean numbers nested lists `1.` / `i.` / `a.`; this deck accents the numbers and leaves the pattern alone.

The deck is two files: there is no preamble, because nothing in it needed a helper.

Build the PDF (run from this directory):

```sh
make
```

Clean sets Roboto for text; the theme falls back to Source Sans 3, Liberation Sans, and DejaVu Sans. Code keeps Typst's own monospace, since this deck shows no code blocks.
