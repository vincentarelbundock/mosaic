#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example
#import "/examples/cream/theme.typ" as cream-theme
#import "/examples/metropolis/theme.typ" as metropolis-theme
#import "/examples/minimalist/theme.typ" as minimalist-theme
#import "/examples/portfolio/theme.typ" as grayscale-theme

#set document(title: [Themes])
#metadata((
  title: "Themes",
  description: "Polished themes bundled with Mosaic, each a single readable module: use one with an import, or copy it and own every line.",
)) <website-metadata>

// Palette chips rendered from the theme modules themselves, so the page can
// never drift from the code.
#let swatches(..colors) = {
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    html.elem("div", attrs: (
      style: "display:flex;gap:0.35rem;margin:0.5rem 0 1rem;",
    ))[
      #for value in colors.pos() {
        html.elem("span", attrs: (
          style: "display:inline-block;width:2.2rem;height:1.3rem;"
            + "border-radius:4px;border:1px solid rgba(0,0,0,0.18);"
            + "background:" + value.to-hex() + ";",
          title: value.to-hex(),
        ))[]
      }
    ]
  } else {
    stack(
      dir: ltr,
      spacing: 0.4em,
      ..colors
        .pos()
        .map(value => box(
          fill: value,
          width: 2em,
          height: 1em,
          radius: 3pt,
          stroke: 0.5pt + luma(120),
        )),
    )
  }
}

#let bundled-source(slug) = link(
  "https://github.com/vincentarelbundock/mosaic/blob/main/mosaic/src/themes/"
    + slug + ".typ",
)[theme source]

#let vendored-source(slug) = link(
  "https://github.com/vincentarelbundock/mosaic/blob/main/docs/examples/"
    + slug + "/theme.typ",
)[`theme.typ` source]

#title()

In Mosaic, a theme is a module, not an object. Each theme is one ordinary
Typst file that exports a palette, an `apply` wrapper for `#show`, and a few
layout factories that return `m.slide(...)`. Nothing in it is framework
machinery: you can read the whole file in a few minutes and change any line
without asking Mosaic's permission.

Three polished themes ship inside the package under `m.themes`, ready to use
with a single import. Every one of them is still a single readable file: to go
beyond the knobs its `apply` accepts, copy the file next to your deck and own
it. This page shows the same content rendered under each theme and walks
through the anatomy of a theme so you can write your own.

= One deck, four themes

Every theme on this page follows the same convention. It imports only Mosaic
and exports:

- `apply`, the document wrapper applied with `#show: theme.apply`,
- `default`, the ordinary content slide, registered as `auto-slide` so plain
  `== Title` markup renders through it,
- `title` and `section`, layout factories whose `authors` argument takes
  `m.author(...)` records,
- `colors`, the semantic Mosaic color roles, and `palette`, the theme's raw
  design tokens.

Because the surface is shared, switching themes is a one-line change. The four
decks below render identical content. Each source file pairs the shared
content with one theme, and only the theme selection differs:

#verbatim-example("themes/cream.typ")

== Cream, Green, and Black

Sage and cream fields, Inter, ink accents. Full-bleed color and generous
insets. Bundled as `m.themes.cream`; see the #bundled-source("cream") and the
#link("examples.html")[complete deck].

#swatches(
  cream-theme.sage,
  cream-theme.cream,
  cream-theme.ink,
  cream-theme.white,
)

#slideshow(
  calepin.elements.gallery,
  "themes/cream",
  5,
  "The shared demo deck under the Cream theme",
)

== Metropolis

The classic ink and orange conference look, Fira Sans, an inverted header bar,
and section progress lines. Bundled as `m.themes.metropolis`; see the
#bundled-source("metropolis") and the #link("examples.html")[complete deck].

#swatches(
  metropolis-theme.ink,
  metropolis-theme.orange,
  metropolis-theme.paper,
  metropolis-theme.soft,
)

#slideshow(
  calepin.elements.gallery,
  "themes/metropolis",
  5,
  "The shared demo deck under the Metropolis theme",
)

== Minimalist White

A quiet cream page, a single red, and Source Serif 4. Almost nothing but
typography. Bundled as `m.themes.minimalist`; see the
#bundled-source("minimalist") and the #link("examples.html")[complete deck].

#swatches(
  minimalist-theme.cream,
  minimalist-theme.red,
)

#slideshow(
  calepin.elements.gallery,
  "themes/minimalist",
  5,
  "The shared demo deck under the Minimalist White theme",
)

== Grayscale

Black, white, and gray in Inter, with solid ink bands. This theme powers the
Photojournalist Portfolio example, and it is not bundled: it lives next to its
deck as a copy-me file, showing the vendored side of the convention. See the
#vendored-source("portfolio") and the #link("examples.html")[complete deck].

#swatches(
  grayscale-theme.ink,
  grayscale-theme.paper,
  grayscale-theme.gray,
)

#slideshow(
  calepin.elements.gallery,
  "themes/grayscale",
  5,
  "The shared demo deck under the Grayscale theme",
)

= Anatomy of a theme

What Mosaic deliberately lacks is a theme _object_. Where Beamer routes every
choice through a theme's configuration keys, Mosaic themes contain no
framework machinery. Deck-wide colors, spacing, and features flow through
`m.setup`, and a reusable configuration is an ordinary Typst value built with
`.with(...)`; such a value is called a preset:

```typ
#let brand = m.setup.with(
  colors: m.color.scheme("dark") + (
    accent: rgb("#e69f00"),
  ),
  features: (slide-number: true, progress: true),
)

#show: brand
```

Everything else, such as typography, headings, captions, and lists, is styled
with ordinary `set` and `show` rules after setup. A theme file is nothing more
than a preset, those rules, and a few slide constructors saved in one place.

There is no framework to learn, so a theme fits on one screen. The file below
is a complete theme followed by the deck that uses it: a palette of `#let`
bindings, three layout factories that return `m.slide(...)`, and an `apply`
wrapper that hands deck-wide settings to `setup` and styles everything else
with native `set` and `show` rules. Copy it as a starting point for your own
look.

#verbatim-example("themes/starter.typ")

#slideshow(
  calepin.elements.gallery,
  "themes/starter",
  5,
  "The starter theme deck",
)

Two conventions in the file are worth naming. First, the `apply` wrapper
exists because `set` and `show` rules cannot cross an `#import`;
document-wide styling therefore lives inside a function applied with
`#show: apply` rather than at the top level of the theme file. Second, the
`default` layout is defined before the wrapper because `m.setup` captures it
as the `auto-slide` handler; after that, plain `== Title` markup renders
through the theme with no explicit call.

= Using and sharing themes

To use a bundled theme, import Mosaic and pick one:

```typ
#import "@local/mosaic:0.0.1" as m
#let theme = m.themes.metropolis

#show: theme.apply

#theme.title([My talk], subtitle: [With a borrowed look])

== First slide

Ordinary content.

#theme.section([A new chapter])
```

Each bundled `apply` exposes a few knobs through Typst's native `.with(...)`,
for example `#show: theme.apply.with(base-size: 24pt)`. Beyond those knobs
there is no configuration API, and that is deliberate: to change the accent
color or the cover layout, copy the theme file next to your deck, import the
copy instead of `m.themes`, and edit any line. You own the copy, with no
version coupling and no upgrade treadmill.

A theme is also easy to publish. Because it is a self-contained Typst module
that imports only Mosaic, you can share it as a gist, vendor it in a project
template, or wrap it in a small package on
#link("https://typst.app/universe/")[Typst Universe]. If you build one you
like, please share it.

The convention documented above is exactly that, a convention. Mosaic itself
never inspects or dispatches on a theme: `setup`, presets, and native Typst
rules remain the only styling machinery. One Typst detail shapes the
convention: Typst cannot call dictionary entries as functions, so the layout
factories are exported at the module's top level (`theme.title`, not
`theme.layouts.title`). Each theme also exports a `layouts` dictionary
grouping the same factories for programmatic use.
