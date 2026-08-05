// Deck-specific preamble. The vendored Greyscale theme is the active Mosaic
// facade, imported as `m`; the helpers below belong only to this deck.
#import "theme.typ" as m
#import "theme-tokens.typ" as _tokens
#let ink = _tokens.ink
#let paper = _tokens.paper
#let gray = _tokens.gray

#let black-panel(body, inset: 20pt) = block(
  width: 100%,
  fill: ink,
  inset: inset,
  text(fill: white, body),
)

// ── Copy ───────────────────────────────────────────────────────────────────
#let lorem = [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.]

// ── Helpers ────────────────────────────────────────────────────────────────
#let photo(name, fit: "cover") = m.components.image(path("assets/" + name), fit: fit)

// Cells are structural. This deck paints them by hand, so every cell starts
// with a zero inset; `surface()` carries the padding, which `styled()` applies
// through the cell's <mosaic-cell-ID> label alongside the fill and alignment.
#let cell(..args) = m.grids.cell(..args, inset: 0pt)
#let surface(..overrides) = (
  (fill: none, inset: 0pt, align: top + left) + overrides.named()
)

// Apply a map of cell id -> surface() as native rules around a slide:
//   #styled((id: surface(...)), m.slide(layout: ...)[...])
#let styled(styles, body) = {
  let out = body
  for (id, s) in styles {
    let name = label("mosaic-cell-" + id)
    out = {
      show name: set align(s.align)
      show name: it => block(
        width: 100%,
        height: 100%,
        fill: s.fill,
        inset: s.inset,
        it,
      )
      out
    }
  }
  out
}

#let project-card(number, body) = grid(
  columns: (62pt, 1fr),
  gutter: 15pt,
  align: top,
  rect(fill: white, inset: 8pt, text(size: 30pt, weight: "bold", number)),
  text(size: 11pt, fill: white, body),
)

// This deck builds every slide by hand, so `slide` is rebound to `m.slide`.
// The theme's `default` layout still backs `==` headings.
#let slide = m.slide
