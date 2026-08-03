// Exact public Minimalist facade: shared Mosaic API plus themed setup/layouts.
#import "../shared-api.typ": slide, note, pause, surface, grid, steps, components, theme
#import "minimalist/definition.typ": definition as _definition
#import "minimalist/layouts.typ" as layouts
#let setup = theme.setup(_definition)
