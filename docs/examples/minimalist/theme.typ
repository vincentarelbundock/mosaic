// The reusable Minimalist White look (cream and red, Source Serif 4) ships
// inside Mosaic itself: `m.themes.minimalist` exports `apply`, the
// `default`, `title`, and `section` layout factories, `colors`, and
// `palette`. To customize a bundled theme beyond its `apply.with(...)`
// knobs, copy mosaic/src/themes/minimalist.typ next to your deck and import
// that copy instead.
//
// This file adapts the bundled theme to this deck: it re-exports Mosaic,
// the theme module, and the palette tokens the deck's content references
// directly.
#import "@local/mosaic:0.0.1" as m

#let theme = m.themes.minimalist
#let cream = theme.palette.cream
#let red = theme.palette.red
