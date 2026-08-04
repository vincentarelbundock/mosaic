// Every built-in theme exports its palette under one schema, so a derived theme
// can extend `colors` instead of depending on private token names.
#import "../mosaic/src/color-defaults.typ": light-palette
#import "../mosaic/src/role-defaults.typ": (
  default-roles, role-fields, role-names, validate-roles,
)
#import "../mosaic/src/themes/cream/tokens.typ" as cream
#import "../mosaic/src/themes/dark/tokens.typ" as dark
#import "../mosaic/src/themes/metropolis/tokens.typ" as metropolis
#import "../mosaic/src/themes/minimalist/tokens.typ" as minimalist

#let palette-keys = ("accent", "canvas", "line", "muted", "surface", "text")
#assert(light-palette.keys().sorted() == palette-keys)

#for palette in (cream.colors, dark.colors, metropolis.colors, minimalist.colors) {
  assert(palette.keys().sorted() == palette-keys)
  assert(palette.values().all(value => type(value) == color))
}

// The semantic role palette has its own schema, and Dark is the theme that
// states a complete one rather than deriving it from the deck colors.
#assert(role-names == default-roles.keys().sorted())
#assert(role-fields == ("accent", "fill", "text"))
#assert(validate-roles(dark.roles) == dark.roles)
#assert(validate-roles(default-roles) == default-roles)
// `auto` is the other legal value: derive the roles from the deck's colors.
#assert(validate-roles(auto) == auto)

Theme palettes share one schema.
