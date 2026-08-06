#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  example-source, slideshow, slideshow-grid,
)
#import "/_includes/site.typ": repo-file

#set document(title: [Colors])
#metadata((title: "Colors")) <website-metadata>

#title()

Every color in a Mosaic deck flows from one palette: a flat dictionary of eight colors that the theme supplies, `setup(colors: ..)` overrides, and every layout and component reads. This page covers the three ways to work with it: override individual entries, swap in one of the bundled palettes, or invert a single slide.

= Overriding colors

Each theme supplies a complete color palette. Override only the deck-wide colors that need to change; omitted colors keep the theme defaults:

```typ
#show: m.setup.with(colors: (
  canvas: rgb("#f4f8f7"),
  accent: rgb("#007f73"),
))
```

The palette holds eight entries: six name the deck's own surfaces and text, two name the status colors that components paint with:

#table(
  columns: (auto, 1fr),
  [`canvas`], [The page fill behind every slide.],
  [`surface`], [Raised panels: the fill a neutral card or badge sits on.],
  [`text`], [Body text.],
  [`muted`], [Secondary text: captions, footers, fine print.],
  [`line`], [Drawn rules, borders, and dividers.],
  [`accent`], [The deck's emphasis color.],
  [`warning`], [A remark that qualifies what is on the slide.],
  [`error`], [A remark that contradicts it.],
)

Unknown names and non-color values are errors. The canvas, typography, components, and layouts all use the resolved values. Explicit component colors remain local overrides:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body"),
  foreground: [
    #place(bottom + left)[
      #m.components.progress(
        variant: "line",
        width: 100%,
        accent: rgb("#e69f00"),
      )
    ]
  ],
)[Title][Body]
```

Native rules after `m.setup` are still the right tool for typography or a special local composition:

```typ
#[
  #show label("mosaic-cell-body"): set text(fill: white)
  #m.slide(
    background: block(width: 100%, height: 100%, fill: rgb("#111827")),
  )[Dark for this slide only]
]
```

Color collections remain ordinary Typst arrays. Define them near the chart or diagram that uses them, or import a color package. A component's `role:` names one palette entry, so recoloring the palette recolors every `card`, `badge`, and `quote` that uses it.

To recolor an entire slide at once, use the `<mosaic-slide>` label described under #link("styling.html#styling-a-whole-slide")[Styling a whole slide].

= Bundled palettes

Beyond per-entry overrides, every facade exports `palettes`, a curated collection of complete color schemes in one Japandi voice: oat and greige grounds, wood-tone and dried-plant accents, and status colors that whisper. Each entry is the same flat eight-color dictionary `colors:` accepts, so any of them repaints any theme with one line:

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup.with(colors: m.palettes.espresso)
```

#table(
  columns: (auto, 1fr),
  [`light`], [The default light palette, applied when a deck names no colors.],
  [`dark`], [The bundled dark polarity twin of `light`.],
  [`parchment`], [Barely-oat paper with espresso ink and a walnut accent.],
  [`sage`], [Cool daylight with the faintest green cast and a dried-sage accent.],
  [`stone`], [Faintly warm greige with a muted indigo accent.],
  [`espresso`], [Roasted brown-black with a pale wood accent.],
  [`forest`], [Moss night with a dried-sage accent.],
  [`slate`], [Blue-gray charcoal warmed by a wood accent.],
)

Every bundled palette is held to a tested contrast contract: body and muted text stay readable on the canvas, the accent and status colors stay legible on both the canvas and on an inverted slide's swapped ground, and rules stay visible without turning into ink. Your own palettes face no such gate. Whatever dictionary you pass to `colors:` is applied as given, and the bundled entries are ordinary dictionaries, so `m.palettes.espresso + (accent: ..)` extends one exactly like the partial overrides above.

= One deck, every palette

The galleries below all render the same five-slide deck under the default theme: a title slide, a content slide with a list, a code block, and a warning callout, a section slide, a components slide with a table, badges, and a card, and one inverted slide. Only the `colors:` line changes between them, so anything that shifts from gallery to gallery is the palette's doing rather than the theme's or the content's.

The deck lives in one #repo-file("docs/examples/embedded/appearance/_palette-deck.typ")[shared file] exporting a single `deck` function, exactly like the running example on the #link("themes.html")[Themes] page. Each wrapper imports it, names one bundled palette, and renders:

#example-source("appearance/palette-espresso")

The dark schemes swap in the dark syntax highlighting theme on their own; polarity is read off the canvas each palette supplies, never declared. Component panels tint their role colors into whichever canvas the palette brings, so the callout and badges stay quiet washes in every scheme.

#slideshow-grid[
  #slideshow(calepin.elements.gallery, "appearance/palette-light", 5, "The palette deck on the default light palette", caption: [`light`])
  #slideshow(calepin.elements.gallery, "appearance/palette-dark", 5, "The palette deck on the bundled dark palette", caption: [`dark`])
  #slideshow(calepin.elements.gallery, "appearance/palette-parchment", 5, "The palette deck on the parchment palette", caption: [`parchment`])
  #slideshow(calepin.elements.gallery, "appearance/palette-sage", 5, "The palette deck on the sage palette", caption: [`sage`])
  #slideshow(calepin.elements.gallery, "appearance/palette-stone", 5, "The palette deck on the stone palette", caption: [`stone`])
  #slideshow(calepin.elements.gallery, "appearance/palette-espresso", 5, "The palette deck on the espresso palette", caption: [`espresso`])
  #slideshow(calepin.elements.gallery, "appearance/palette-forest", 5, "The palette deck on the forest palette", caption: [`forest`])
  #slideshow(calepin.elements.gallery, "appearance/palette-slate", 5, "The palette deck on the slate palette", caption: [`slate`])
]

= Inverting one slide

The last slide of every gallery above is the same command:

```typ
#m.slide(invert: true)[
  One inverted slide for the headline number.
]
```

`invert: true` swaps ground and ink within the active palette for that slide only: the canvas becomes the palette's text color, the text becomes its canvas, and muted, line, and surface are derived to match. The accent and status colors carry over unchanged, which is why a badge or callout keeps its color on the swapped ground. That survival is part of the bundled palettes' tested contract, so `invert:` composes with every scheme in the collection; a custom palette whose accent only reads on its own canvas will look washed out here, and passing a hand-picked palette to that one slide's components is the escape hatch.
