// Every built-in theme exports its palette under one schema, so a derived theme
// can extend `colors` instead of depending on private token names.
#import "../mosaic/src/palettes.typ": light, dark
#import "../mosaic/src/component/style.typ": role-colors, role-names
#import "../mosaic/src/themes/editorial/tokens.typ" as editorial
#import "../mosaic/src/themes/metropolis/tokens.typ" as metropolis
#import "../mosaic/src/themes/manifesto/tokens.typ" as manifesto
#import "../mosaic/src/themes/mono/tokens.typ" as mono

// One flat palette per theme: six deck colors and two status colors. There is
// no parallel role record, so this list is the whole color surface of a theme.
#let palette-keys = (
  "accent", "canvas", "error", "line", "muted", "surface", "text", "warning",
)
#assert(light.keys().sorted() == palette-keys)

#for palette in (editorial.colors, dark, manifesto.colors, metropolis.colors, mono.colors) {
  assert(palette.keys().sorted() == palette-keys)
  assert(palette.values().all(value => type(value) == color))
}

// A component role is a palette key, not a record of its own. `neutral` is the
// one name that is not: it means the deck's own surface.
#assert(role-names == ("neutral", "accent", "warning", "error"))
#for name in role-names {
  assert(name == "neutral" or name in light)
}

// Outside a deck the roles resolve against the library's light palette, and all
// three paints come from it rather than from stored per-role values.
#assert(role-colors("warning").accent == light.warning)
#assert(role-colors("warning").text == light.text)
#assert(role-colors("neutral").fill == light.surface)
#assert(role-colors("neutral").accent == light.line)

Theme palettes share one schema.
