// The reusable Cream, Green, and Black look (sage and cream, Inter) ships
// inside Mosaic itself: `m.themes.cream` exports `apply`, the `default`,
// `title`, and `section` layout factories, `colors`, and `palette`. To
// customize a bundled theme beyond its `apply.with(...)` knobs, copy
// mosaic/src/themes/cream.typ next to your deck and import that copy
// instead.
//
// This file adapts the bundled theme to this deck: it re-exports Mosaic,
// the theme module, and the palette tokens the deck's content references
// directly.
#import "@local/mosaic:0.0.1" as m

#let theme = m.themes.cream
#let sage = theme.palette.sage
#let sage-dark = theme.palette.sage-dark
#let cream = theme.palette.cream
#let ink = theme.palette.ink
#let white = theme.palette.white
