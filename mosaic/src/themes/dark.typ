// Exact public Dark facade: shared Mosaic API plus dark setup and layouts.
#import "../shared-api.typ": slide, note, pause, surface, grid, steps, theme
#import "dark/definition.typ": definition as _definition
#import "dark/layouts.typ" as layouts
#import "dark/components.typ" as components
#let setup = theme.setup(_definition)
