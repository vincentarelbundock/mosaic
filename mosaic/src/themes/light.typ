// Canonical public Light facade; root Mosaic re-exports it exactly.
#import "../shared-api.typ": slide, note, pause, surface, grid, steps, components, theme
#import "light/definition.typ": definition as _definition
#import "light/layouts.typ" as layouts
#let setup = theme.setup(_definition)
