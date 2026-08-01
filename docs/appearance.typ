#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": (
  slideshow,
  thumbnail-gallery-items,
  verbatim-example,
)
#import "/api/modules/color.typ": palette-record

#set document(title: [Appearance])
#metadata((title: "Appearance")) <website-metadata>

#title()

Mosaic has one styling idea, and it is the thing that sets Mosaic apart: it
labels every element it draws, and you style all of it with native Typst rules.
A slide is a stack of native layers, a background plane, a grid of cells, and a
foreground plane. The planes are content you supply directly; each cell is a
single block labeled `<mosaic-cell-ID>`. Style any of it with the ordinary
`set` and `show` rules you already know. `m.setup` establishes the baseline
(font, colors, and the canonical cell vocabulary), and every rule you add layers
on top. There is no styling dictionary, no theme object, and no dozen styling
functions to learn.

= Styling cells

Target a cell by its label. Font, size, color, and alignment are `set text`,
`set par`, and `set align`; fills, strokes, rounded corners, and images behind
content are the `block` you wrap the cell in:

```typ
#show label("mosaic-cell-copy"): set align(left + horizon)
#show label("mosaic-cell-copy"): set text(fill: black, size: 1.1em)
#show label("mosaic-cell-copy"): it => block(
  width: 100%,
  height: 100%,
  fill: white,
  it,
)

#m.slide(m.grid.h("copy", "image"))[Copy][Image]
```

A full-height cell (`1fr` or a fixed track) fills its region when the wrapping
block asks for `height: 100%`; a content-sized cell (an `auto` track) should
omit the height so its fill hugs the content. The one structural knob that lives
on the cell itself is `inset`, because padding affects layout measurement:

```typ
#m.grid.cell("image", inset: 0pt)
```

Precedence is ordinary rule nesting. `m.setup` and any theme establish baseline
cell rules; a rule you write after `#show: m.setup` overrides them deck-wide;
and a rule scoped inside a block around a single `m.slide` call overrides them
for that slide only:

```typ
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide[Centered for this slide only]
]
```

== Reusable looks

Bundle cell rules in a transformer and apply it once with `#show:`. Every
following slide that uses those cell IDs picks the rules up:

```typ
#let styled(body) = {
  show label("mosaic-cell-b"): it => block(
    width: 100%,
    height: 100%,
    fill: blue,
    it,
  )
  body
}

#show: styled
#m.slide(m.grid.h("a", "b"))[Left][Right]
```

#verbatim-example("grids/reusable.typ")

#slideshow(
  calepin.elements.gallery,
  "grids/reusable",
  2,
  "One grid and one set of reusable cell rules shared by two slides",
)

A *theme* (see #link("appearance.html#themes")[Themes], below) is exactly this
pattern at deck scale: an `apply` wrapper that calls `m.setup` and adds the
deck's cell rules.

= Typography

Style type with Typst's native `text`, `heading`, `par`, and `list` rules,
placed after the `m.setup` show rule so they apply throughout the deck. A
document-wide `set text` sets the base font, size, and fill, reaching every
slide including layout bodies and hand-built cells:

```typ
#show: m.setup
#set text(font: "EB Garamond", size: 26pt)
```

Level-1 headings are section titles and level-2 headings are slide titles.
Style them with show rules keyed on `heading`; anything `text` accepts works,
including `fill`, `tracking`, and `style`:

```typ
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
#show heading.where(depth: 2): set text(size: 1.4em)
```

A `heading` is semantic: it feeds the outline, PDF bookmarks, and
`m.current-heading`, and drives automatic section slides. For large type that
should *not* appear in navigation (a cover word, a pull quote, a number), use
`text` directly, or exclude the heading:

```typ
#text(size: 60pt, weight: "black")[BOLD]
#heading(outlined: false, bookmarked: false)[Aside]
```

Leading, spacing, and list markers belong to `par`, `list`, `enum`, and
`terms`; figure captions to `figure.caption`. Mosaic sets sensible list spacing
by default; override where a slide needs it:

```typ
#set par(leading: 0.8em)
#set list(marker: [→])
#show figure.caption: set text(size: 0.8em, style: "italic")
```

A heading cannot be placed inside an incremental grid node (`m.grid.on`,
`m.reveal`, and related reducers); keep it structurally stable across a slide's
frames.

= Color schemes

Mosaic separates semantic color schemes from categorical palettes. A scheme is
a complete dictionary of named roles consumed by `m.setup(colors: ...)`; a
palette is an ordered array for charts, diagrams, and independently styled
cells. Both live in the `m.color` namespace.

`m.color.scheme(name)` returns every semantic role Mosaic uses:

- `canvas`: the overall slide background.
- `surface`: a raised or grouped content surface.
- `accent`: the single attention-directing color.
- `text`: ordinary titles, headings, and body text.
- `inverse-text`: text placed on strongly contrasting fills.
- `muted`: supporting text and lower-emphasis content.
- `line`: borders, rules, and other quiet separators.

The unbranded `"light"` (default, warm white) and `"dark"` (slate) schemes are
neutral foundations. Six presentation schemes give distinct directions:
`"gallery"` (understated, architectural), `"editorial"` (warm page, red accent),
`"botanical"` (research and teaching), `"studio"` (restrained plum),
`"conference"` (crisp, institutional), and `"spotlight"` (dark auditorium).
Exact role values are listed in the #link("api/color.html")[Color API].

Each preview below uses the same slide (a titled body beside a card, over an
inverted footer), so the repeated structure exposes every role at once.

#thumbnail-gallery-items(
  calepin.elements.gallery,
  (
    ("/assets/tutorials/color/schemes-1.svg", "Light semantic color scheme"),
    ("/assets/tutorials/color/schemes-2.svg", "Dark semantic color scheme"),
    ("/assets/tutorials/color/schemes-3.svg", "Gallery semantic color scheme"),
    ("/assets/tutorials/color/schemes-4.svg", "Editorial semantic color scheme"),
    ("/assets/tutorials/color/schemes-5.svg", "Botanical semantic color scheme"),
    ("/assets/tutorials/color/schemes-6.svg", "Studio semantic color scheme"),
    ("/assets/tutorials/color/schemes-7.svg", "Conference semantic color scheme"),
    ("/assets/tutorials/color/schemes-8.svg", "Spotlight semantic color scheme"),
  ),
  columns: 2,
  max-width: 46em,
  show-captions: false,
)

Apply a scheme in `setup`; schemes are ordinary dictionaries, so dictionary
addition gives selective overrides. Pass a complete scheme (or a partial
dictionary) to `m.slide(colors: ...)` to change one logical slide, after which
the next slide restores the inherited scheme:

```typ
#show: m.setup.with(colors: m.color.scheme("dark") + (accent: rgb("#ffb703")))

#m.slide(colors: m.color.scheme("editorial"))[Only this slide is Editorial.]
#m.slide(colors: (accent: rgb("#d97706")))[Inherit every role except accent.]
```

= Palettes

`m.color.palette(name)` returns an ordered color array of established
qualitative palettes for charts, diagrams, and categorical distinctions.
Hover a band for each color's zero-based index, stable name, and Typst
expression; click to copy the `m.color.palette(...)` call.

#let general-palette-names = (
  "okabe-ito",
  "tol-bright",
  "tol-muted",
  "brewer-dark2",
  "brewer-set2",
  "brewer-paired",
)

#let carto-qualitative-names = (
  "carto-antique",
  "carto-bold",
  "carto-pastel",
  "carto-prism",
  "carto-safe",
  "carto-vivid",
)

#let palette-band(name) = {
  let record = palette-record(name)
  let copy-value = "m.color.palette(" + repr(name) + ")"
  html.elem(
    "section",
    attrs: (
      class: "palette-swatch",
      "data-palette": name,
      "data-copy": copy-value,
      "aria-label": name + " color palette",
    ),
  )[
    #html.elem("div", attrs: (class: "palette-swatch__header"))[
      #html.elem("code", attrs: (class: "palette-swatch__title"))[#name]
      #html.elem(
        "span",
        attrs: (
          class: "palette-swatch__status",
          "aria-live": "polite",
        ),
      )
    ]
    #html.elem(
      "button",
      attrs: (
        class: "palette-swatch__band",
        type: "button",
        "data-palette-copy": "",
        "aria-label": "Copy " + name + " palette expression",
      ),
    )[
      #let index = 0
      #for (key, value) in record {
        let color-value = repr(value)
        let color-hex = color-value.slice(5, 12)
        let description = str(index) + ": " + key + ", " + color-value
        html.elem(
          "span",
          attrs: (
            class: "palette-swatch__segment",
            "data-index": str(index),
            "data-color": key,
            style: "--swatch-color: " + color-hex,
            title: description,
          ),
        )[
          #html.elem(
            "span",
            attrs: (class: "palette-swatch__visually-hidden"),
          )[#description]
        ]
        index += 1
      }
    ]
  ]
}

#for name in general-palette-names + carto-qualitative-names {
  palette-band(name)
}

Call `palette()` without `color` for the ordinary array; pass a zero-based
integer or stable string name to extract one value, and `lighten` or `darken`
to transform the whole palette first (which no longer guarantees the source's
accessibility properties):

```typ
#let colors = m.color.palette("tol-bright")
#let blue = m.color.palette("tol-bright", color: "blue")
#let fills = m.color.palette("brewer-set2", lighten: 20%)
```

Palettes are sourced from
#link("https://jfly.uni-koeln.de/color/")[Okabe-Ito],
#link("https://sronpersonalpages.nl/~pault/")[Paul Tol],
#link("https://colorbrewer2.org/")[ColorBrewer], and
#link("https://carto.com/carto-colors/")[CARTOColors]; provenance and licensing
are recorded in `THIRD_PARTY_LICENSES.md`. The
#link("api/color.html")[Color API] lists exact signatures and diagnostics.

= Themes

A theme packages a deck's whole look. In Mosaic it is a module, not an object:
one ordinary Typst file exporting a palette, an `apply` wrapper for `#show`, and
a few layout factories that return `m.slide(...)`. There is no framework
machinery, no `self`, and no configuration API to learn. Deck-wide colors,
spacing, and features flow through `m.setup`, and everything else is the `set`
and `show` rules from the sections above, saved in one place.

The file below is a complete theme followed by the deck that uses it: a palette
of `#let` bindings, three factories, and an `apply` wrapper that hands settings
to `setup` and paints the cells with native rules. Copy it as a starting point.

#verbatim-example("themes/starter.typ")

#slideshow(
  calepin.elements.gallery,
  "themes/starter",
  5,
  "The starter theme deck",
)

Two conventions are worth naming. The `apply` wrapper exists because `set` and
`show` rules cannot cross an `#import`, so document-wide styling lives inside a
function applied with `#show: apply`. And the `default` layout is defined before
the wrapper because `m.setup` captures it as the `auto-slide` handler; after
that, plain `== Title` markup renders through the theme with no explicit call.

Three polished themes ship inside the package under `m.themes`
(`metropolis`, `cream`, and `minimalist`), each a single readable module. Import
Mosaic and pick one:

```typ
#import "@local/mosaic:0.0.1" as m
#let theme = m.themes.metropolis
#show: theme.apply

#theme.title([My talk], subtitle: [With a borrowed look])
== First slide
#theme.section([A new chapter])
```

Each bundled `apply` exposes a few knobs through `.with(...)` (for example
`#show: theme.apply.with(base-size: 24pt)`). Beyond those, there is no
configuration API, and that is deliberate: to change anything else, copy the
theme file from `mosaic/src/themes/` next to your deck, import the copy, and
edit any line. You own it, with no version coupling. The Grayscale theme in
`docs/examples/portfolio/` shows the same convention vendored beside its deck.
See #link("examples.html")[Examples] for complete decks rendered under each
theme.
