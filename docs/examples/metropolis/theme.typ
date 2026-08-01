// The reusable Metropolis look (ink and orange, Fira Sans) ships inside
// Mosaic itself: `m.themes.metropolis` exports `apply`, the `default`,
// `title`, and `section` layout factories, `colors`, and `palette`. To
// customize a bundled theme beyond its `apply.with(...)` knobs, copy
// mosaic/src/themes/metropolis.typ next to your deck and import that copy
// instead.
//
// This file adapts the bundled theme to this deck: it re-exports Mosaic,
// the theme module, and the palette and font tokens the deck's content
// references directly.
#import "@local/mosaic:0.0.1" as m

#let theme = m.themes.metropolis
#let ink = theme.palette.ink
#let orange = theme.palette.orange
#let paper = theme.palette.paper
#let soft = theme.palette.soft
#let sans = "Fira Sans"
#let mono = "Fira Mono"
