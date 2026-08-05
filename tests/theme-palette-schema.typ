// Every built-in theme exports its palette under one schema, so a derived theme
// can extend `colors` instead of depending on private token names.
#import "../mosaic/src/color-defaults.typ": light-palette
#import "../mosaic/src/component/style.typ": role-colors, role-names
#import "../mosaic/src/themes/cream/tokens.typ" as cream
#import "../mosaic/src/themes/dark/tokens.typ" as dark
#import "../mosaic/src/themes/metropolis/tokens.typ" as metropolis
#import "../mosaic/src/themes/minimalist/tokens.typ" as minimalist

// One flat palette per theme: six deck colors and two status colors. There is
// no parallel role record, so this list is the whole color surface of a theme.
#let palette-keys = (
  "accent", "canvas", "error", "line", "muted", "surface", "text", "warning",
)
#assert(light-palette.keys().sorted() == palette-keys)

#for palette in (cream.colors, dark.colors, metropolis.colors, minimalist.colors) {
  assert(palette.keys().sorted() == palette-keys)
  assert(palette.values().all(value => type(value) == color))
}

// A component role is a palette key, not a record of its own. `neutral` is the
// one name that is not: it means the deck's own surface.
#assert(role-names == ("neutral", "accent", "warning", "error"))
#for name in role-names {
  assert(name == "neutral" or name in light-palette)
}

// Outside a deck the roles resolve against the library's light palette, and all
// three paints come from it rather than from stored per-role values.
#assert(role-colors("warning").accent == light-palette.warning)
#assert(role-colors("warning").text == light-palette.text)
#assert(role-colors("neutral").fill == light-palette.surface)
#assert(role-colors("neutral").accent == light-palette.line)

Theme palettes share one schema.
