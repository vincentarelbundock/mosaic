// A deck's partial `spacing:` merges into the theme's preset instead of
// replacing it. Regression: editorial presets `inset: 42pt`, and a deck that
// set only `gap` silently reset `inset` to the library default.
#import "@local/mosaic:0.0.3" as mosaic
#import mosaic.themes.editorial as m
#import "../mosaic/src/deck-state.typ": deck-settings

#show: m.setup.with(spacing: (gap: 1em))

#m.slide[== Merge][Body]

#context {
  let spacing = deck-settings().spacing
  assert(spacing.inset == 42pt, message: repr(spacing))
  assert(spacing.gap == 1em, message: repr(spacing))
}
