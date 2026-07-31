#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": thumbnail-gallery-items
#import "/api/modules/color.typ": palette-record

#set document(title: [Colors])
#metadata((title: "Colors")) <website-metadata>

#title()

Mosaic separates semantic color schemes from categorical palettes. A scheme is
a complete dictionary of named roles consumed by `m.setup(colors: ...)`; a
palette is an ordered array for charts, diagrams, and independently styled
cells. Both live in the `m.color` namespace.

= Schemes

`m.color.scheme(name)` returns every semantic role used by Mosaic:
`canvas`, `surface`, `accent`, `text`, `inverse-text`, `muted`, and `line`.
The unbranded `"light"` and `"dark"` schemes provide neutral defaults; light is
the default. Presentation schemes provide distinct visual directions for
different kinds of talks. Every scheme uses one accent color.

== Built-ins

Mosaic provides two unbranded foundations:

- `"light"` is the default warm-white foundation.
- `"dark"` is a slate foundation rather than pure black.

It also provides six presentation-focused directions:

- `"gallery"` is understated and architectural.
- `"editorial"` uses a warm page and assertive red accent.
- `"botanical"` suits research, environment, health, and teaching.
- `"studio"` brings a restrained plum direction to cultural and design work.
- `"conference"` is crisp and institutional.
- `"spotlight"` is a dark auditorium scheme with warm emphasis.

== Vocabulary

Every scheme contains the same seven roles:

- `canvas`: the overall slide background.
- `surface`: a raised or grouped content surface.
- `accent`: the single attention-directing color.
- `text`: ordinary titles, headings, and body text.
- `inverse-text`: text placed on strongly contrasting fills.
- `muted`: supporting text and lower-emphasis content.
- `line`: borders, rules, and other quiet separators.

== Light

The light scheme currently resolves to:

```typ
(
  canvas: rgb("#fafaf9"),
  surface: white,
  accent: rgb("#2563eb"),
  text: rgb("#1c1917"),
  inverse-text: white,
  muted: rgb("#78716c"),
  line: rgb("#e7e5e4"),
)
```

== Dark

The dark scheme currently resolves to:

```typ
(
  canvas: rgb("#111827"),
  surface: rgb("#1f2937"),
  accent: rgb("#60a5fa"),
  text: rgb("#f3f4f6"),
  inverse-text: rgb("#111827"),
  muted: rgb("#9ca3af"),
  line: rgb("#374151"),
)
```

== Gallery

Every preview uses the same structure and content. The title is the exact
scheme name; the body pairs lorem text at two-thirds width with the same dog
image at one-third width; and the footer is identical. The header and footer
use the normal scheme colors except that the footer is inverted through
`templates.default(inverted: ("footer",))`.

Together, the repeated structure exposes every semantic role without a separate
swatch chart. The slide canvas, title, and prose show `canvas` and `text`. The
inverted footer shows `text` with `inverse-text`. Around the dog image,
`surface` fills the card, `line` draws its border, `accent` marks its top edge,
and `muted` styles its label.

All eight previews are visible as one Calepin gallery. Select any thumbnail to
open the full-size lightbox.

#thumbnail-gallery-items(
  calepin.elements.gallery,
  (
    (
      "/assets/tutorials/color/schemes-1.svg",
      "Light semantic color scheme",
    ),
    (
      "/assets/tutorials/color/schemes-2.svg",
      "Dark semantic color scheme",
    ),
    (
      "/assets/tutorials/color/schemes-3.svg",
      "Gallery semantic color scheme",
    ),
    (
      "/assets/tutorials/color/schemes-4.svg",
      "Editorial semantic color scheme",
    ),
    (
      "/assets/tutorials/color/schemes-5.svg",
      "Botanical semantic color scheme",
    ),
    (
      "/assets/tutorials/color/schemes-6.svg",
      "Studio semantic color scheme",
    ),
    (
      "/assets/tutorials/color/schemes-7.svg",
      "Conference semantic color scheme",
    ),
    (
      "/assets/tutorials/color/schemes-8.svg",
      "Spotlight semantic color scheme",
    ),
  ),
  columns: 2,
  max-width: 46em,
  show-captions: false,
)

== Slide overrides

Pass a complete scheme to the `colors` argument on `m.slide` to change
only that logical slide:

```typ
#show: m.setup.with(
  colors: m.color.scheme("light"),
)

#m.slide[
  This slide uses the inherited light scheme.
]

#m.slide(
  colors: m.color.scheme("editorial"),
)[
  Only this slide uses Editorial.
]

#m.slide[
  This slide returns to the inherited light scheme.
]
```

The default value is `auto`, which inherits the presentation colors. A partial
dictionary overrides only the listed roles:

```typ
#m.slide(
  colors: (accent: rgb("#d97706")),
)[
  Inherit every role except accent.
]
```

Slide-local colors apply to the canvas, ordinary text, templates, and
presentation furniture. Every frame belonging to the logical slide
uses the same colors; the following slide automatically restores the inherited
scheme.

== Customize

Apply a scheme through the existing `colors` setup argument. Schemes are
ordinary dictionaries, so normal dictionary addition provides selective
overrides. This creates reusable project schemes:

```typ
#show: m.setup.with(
  colors: m.color.scheme("dark") + (
    accent: rgb("#ffb703"),
  ),
)
```

= Palettes

`m.color.palette(name)` returns an ordered color array. Mosaic includes
established qualitative palettes for charts, diagrams, and other categorical
distinctions. Sequential and diverging maps are not yet available.

Each palette below is rendered as a compact semantic HTML color band by
this documentation page, rather than by the Mosaic package or as a slide image.
Hover a color for its zero-based index, stable Mosaic name, and exact Typst
expression. Click a band to copy the corresponding
`m.color.palette(...)` call.

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
        let description = str(index) + ": " + key + " — " + color-value
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

== Qualitative

CARTO palettes use their complete 12-color variants.

#for name in general-palette-names + carto-qualitative-names {
  palette-band(name)
}

== Select

Calling `palette()` without `color` preserves the ordinary array API. Pass a
zero-based integer or stable string name to extract one value directly:

```typ
#let colors = m.color.palette("tol-bright")
#let first = colors.at(0)

#let same-by-index = m.color.palette("tol-bright", color: 0)
#let same-by-name = m.color.palette("tol-bright", color: "blue")
```

Names from the original specification are retained for Okabe–Ito and Paul Tol
where available. ColorBrewer and CARTO do not publish individual swatch names,
so Mosaic uses stable descriptive or positional aliases shown in the gallery.
The palette remains ordered even when aliases are used.

== Transform

Use `lighten` or `darken` to transform the complete palette before returning an
array or selected color:

```typ
#let fills = m.color.palette("brewer-set2", lighten: 20%)
#let dark-teal = m.color.palette(
  "brewer-set2",
  color: "teal",
  darken: 15%,
)
```

A transformed palette no longer necessarily retains the accessibility or
perceptual properties of its published source values.

= Sources

== Palettes

The palettes are sourced from established visualization systems:

- #link("https://jfly.uni-koeln.de/color/")[Okabe–Ito Color Universal Design]
- #link("https://sronpersonalpages.nl/~pault/")[Paul Tol colour schemes]
- #link("https://colorbrewer2.org/")[ColorBrewer]
- #link("https://carto.com/carto-colors/")[CARTOColors]

Paletteer was used as a discovery catalogue; Mosaic's values and attribution
refer to the original specifications. Licensing and provenance details are
recorded in `THIRD_PARTY_LICENSES.md`.

The generated #link("api/color.html")[Color API reference] lists exact
signatures, parameter types, defaults, and diagnostics.

== Presentation schemes

The six presentation schemes are original Mosaic color directions. They use
warm or gently tinted canvases, quiet surfaces and rules, high-contrast body
text, and a single purposeful accent. Use `"gallery"` as the understated
general-purpose option, or select a stronger identity to match the setting and
subject of the talk.
