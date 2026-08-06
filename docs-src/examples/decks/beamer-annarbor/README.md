# Ann Arbor: Mosaic adaptation

A Mosaic/Typst re-creation of **AnnArbor**, one of the themes built into [Beamer](https://ctan.org/pkg/beamer) for LaTeX (see the [theme gallery](https://latex-beamer.com/tutorials/beamer-themes/)). Beamer's `AnnArbor` is an assembly of three parts: the `rounded` inner theme, the `infolines` outer theme, and the `wolverine` color theme, whose Michigan blue and maize give the deck its voice. None of beamer's source is redistributed here; this is a design read off those three files and restated in Mosaic's vocabulary.

Like the Calmly deck, and unlike the decks built on Mosaic's bundled themes, this one imports no theme at all. `preamble.typ` is a complete deck-local theme definition passed to `mosaic.themes.setup`. It is deliberately thin: every part of AnnArbor that Mosaic already has a gesture for is spelled with that gesture, and what remains is only what beamer has and Mosaic does not.

| Beamer AnnArbor | This deck |
| --- | --- |
| `\usecolortheme{wolverine}` | the theme's `colors` palette plus the banding colors above it |
| `infolines` headline and footline | one `foreground` plane holding both bars, so every layout is banded alike |
| `frametitle` bar | `show label("mosaic-cell-header"): surface(fill: ..)` |
| `\titlepage` | `layouts.title(variant: "centered")`, with the `titlelike` panel painted on `<mosaic-title-display>` |
| `\AtBeginSection` outline | `layouts.section(variant: "toc")`: the whole outline, the section you are entering alive and the rest ghosted |
| content frames | `layouts.content(variant: "header-body")`, including `columns: 2` for a two-column frame |
| `block`, `alertblock`, `exampleblock` | `components.callout`, by role |
| `\tableofcontents` frame | native Typst `outline()` with an entry rule that drops the page numbers |
| `\pause` | `steps.pause` |
| frame number | `components.progress` with a renderer that holds the slot clear on the unnumbered title page |

Three things are worth calling out.

The chrome rides the foreground plane, which is the one place a theme can state something once for every layout, and it is why all three layouts here are stock variants rather than hand-built grids. The cost is that a plane reserves no space: the deck's `spacing.inset` is what keeps content off the banding, and it is sized against the bars rather than chosen for looks. The header cell's own inset is 0.55 of that value (`layout/support.typ`), which is what holds the frametitle clear of the headline above it, so the three measurements at the top of `preamble.typ` move together.

Nothing in the chrome is restated by the deck. Both bars are one reader: `mosaic.info()` returns the author, title, and date the deck declared on `setup`, the current section for the headline, and the frame number and total for the footline, so `main.typ` states the deck once and the bars follow. The bright half of the headline is beamer's subsection slot; Mosaic has no subsection level, so it stays clear, as it does in a beamer deck that declares sections only.

Fidelity was traded in three places, all to stay on Mosaic's own vocabulary: blocks are single stripe-and-title callouts rather than beamer's two-part title bar over a pale body, nothing carries beamer's drop shadow (`\usetheme[shadow=false]{AnnArbor}` turns those off in beamer too), and the alert block takes the palette's `error` red rather than wolverine's dark blue.

The deck is 4:3. Beamer's default frame size is 128mm by 96mm, and AnnArbor's banding was drawn for that shape, so `preamble.typ` binds `setup` to `paper: "4-3"`.

Build the PDF (run from this directory):

```sh
make
```

Beamer's default font theme is sans, meaning Computer Modern Sans; the theme asks for Latin Modern Sans and CMU Sans Serif and falls back to DejaVu Sans when neither is installed. Math renders in Typst's bundled New Computer Modern Math, which is the same design LaTeX sets equations in.
