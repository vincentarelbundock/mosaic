#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example, thumbnail-gallery

#set document(title: [Writing a theme])
#metadata((title: "Writing a theme")) <website-metadata>

#title()

A theme is a plain dictionary. It holds the same three things the #link("themes.html")[themes] page changed one at a time, a palette, a set of rules, and a choice of layouts, with names attached so several decks can share them. Nothing new is introduced here; the material is only relocated.

= A theme is a dictionary

Bind one in the deck itself to see the whole shape at once. Only `colors` is required:

```typ
#import "@local/mosaic:0.0.1" as mosaic

#let mine = (
  name: "Mine",
  colors: mosaic.themes.light-palette + (accent: rgb("#a23b72")),
  apply: (body, colors: (:), options: (:)) => {
    set text(font: "EB Garamond", size: 26pt)
    show heading: set text(fill: colors.accent)
    body
  },
)

#show: mosaic.themes.setup(mine)
```

`mosaic.themes.setup` is worth reading carefully, because two different things on this site are called `setup`. `mosaic.setup` is the document show rule you apply to a deck. `mosaic.themes.setup` sets up nothing on its own: it takes a definition and *returns* a show rule of that kind. So the three keys map exactly onto the previous page:

#table(
  columns: (auto, 1fr),
  [`colors`], [The palette. The same flat dictionary `setup` takes.],
  [`apply`], [The rules. The same `set` and `show` rules, in a function.],
  [`layouts`], [The layout choice. The same dictionary `setup` takes.],
)

Three further keys carry the rest of a theme:

#table(
  columns: (auto, 1fr),
  [`name`], [The theme's display name, used in its error messages. Defaults to `"Custom"`.],
  [`defaults`], [Ordinary `setup` options the theme presets, such as `spacing` or `overflow`. A deck can still override any of them.],
  [`options`], [The theme's own options and their defaults, described below.],
)

= What `apply` owns

Mosaic's engine emits no slide typography of its own. It fills the canvas, sets the text color from the palette, and composes the grid; every rule a slide renders with comes from the active theme. So `apply` is not a place for adjustments, it is where a theme states its whole look.

That includes rules on the labels a slide emits. The #link("../reference/labels.html")[label reference] is the checklist: a theme that styles `mosaic-cell-title` but forgets `mosaic-cell-section` will render section slides in the engine's bare defaults, and nothing will warn about it.

The engine keeps two rules of its own, on `<mosaic-note-heading>` and `<mosaic-note-body>`. They style the printed speaker and notes pages, whose furniture must read black on white whatever the theme does. A theme or deck rule on the same label overrides them.

`apply` receives the resolved palette and the resolved theme options, so it never reads a global:

```typ
apply: (body, colors: (:), options: (:)) => {
  set text(font: options.font, size: options.base-size, fill: colors.text)
  show heading: set text(fill: colors.accent)
  show label("mosaic-cell-section"): set align(center + horizon)
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  body
}
```

= Starting from a bundled theme

Every theme facade exports the `definition` its own `setup` was built from, so a variation on a bundled look is an ordinary dictionary merge:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as base

#let mine = base.definition + (
  name: "Mine",
  colors: base.definition.colors + (accent: rgb("#7cc4ff")),
)

#show: mosaic.themes.setup(mine)
```

Two details decide whether that merge does what you meant.

The merge replaces a key outright. Writing `colors: (accent: ..)` would hand the engine a palette of one color rather than a recolored one, which is why the example merges into `base.definition.colors` instead. The same applies to `layouts` and `options`.

Replacing `apply` discards the base theme's entire look, since `apply` is the look. To add rules on top of an inherited one, run the base callback first:

```typ
apply: (body, colors: (:), options: (:)) => {
  show: (base.definition.apply).with(colors: colors, options: options)
  show heading: set text(weight: "black")
  body
}
```

Note that `mosaic.themes` is exported by the root facade. A bundled theme facade such as `mosaic.themes.dark` exports `setup`, `layouts`, `components`, and `definition`, but not the `themes` namespace itself, so deriving from one means importing the root package as well, as above.

= Theme options

`options` declares choices Mosaic itself knows nothing about. Each name becomes a named argument of the setup the definition produces, and the resolved values are handed to both `layouts` and `apply`:

#embedded-example(
  calepin.elements.gallery,
  "appearance/theme-options",
  frames: 1,
  title: "A theme option feeding both the layout choice and the type scale",
  renderer: thumbnail-gallery,
  columns: 1,
)

Because the option reaches `layouts` as well as `apply`, `layouts` may be a function of the resolved options rather than a fixed dictionary. That is what lets one theme offer genuinely different compositions rather than only a different type size.

An option name that collides with a built-in `setup` option is an error, caught where the theme is bound. Every other named argument a deck passes falls through to `setup` as usual.

= Shipping it

Once a theme is worth reusing, give it a facade: one file that re-exports the shared Mosaic API alongside the theme's own `setup` and `layouts`. Decks then import it exactly as they would a bundled theme, and never learn that it is not one.

```typ
// mytheme.typ
#import "@local/mosaic:0.0.1": slide, note, fit, surface, grids, steps, components, themes
#import "definition.typ": definition
#import "layouts.typ" as layouts
#let setup = themes.setup(definition)
```

The definition is validated where `themes.setup` is called, so a malformed theme fails on that line in the facade rather than somewhere inside a deck that imports it.

The example below is a complete theme in that shape: a facade, a passive definition, and a layout namespace.

#embedded-example(
  calepin.elements.gallery,
  "appearance/starter-theme",
  frames: 5,
  title: "The starter theme deck",
)

The #link("../api/theme.html")[theme authoring API] documents every definition key in full.
