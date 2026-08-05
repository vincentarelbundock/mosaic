// Deck-specific preamble for the Editorial deck. The reusable look is the
// bundled Editorial theme (m.themes.editorial); theme.typ re-exports it as `m`
// together with this deck's visual constants; importing with `*` re-exports
// everything to main.typ. The helpers below belong to this deck's content
// rather than to the theme.
#import "theme.typ": *

// ── Helpers ────────────────────────────────────────────────────────────────
// Cells are structural. This deck paints them by hand, so every cell starts
// with a zero inset; `surface()` carries the padding, which `styled()` applies
// through the cell's <mosaic-cell-ID> label alongside the fill and alignment.
#let c(..args) = m.grids.cell(..args, inset: 0pt)
#let surface(..overrides) = (
  (fill: sage, inset: 0pt, align: top + left) + overrides.named()
)

// Ink on the pale cream panels, paper on the darker sage ones, so every cell
// carries the readable pairing of its own fill.
#let text-on(fill) = if fill == cream { ink } else { white }

// Apply a map of cell id -> surface() as native rules around a slide:
//   #styled((id: surface(...)), m.slide(layout: ...)[...])
#let styled(styles, body) = {
  let out = body
  for (id, s) in styles {
    let name = label("mosaic-cell-" + id)
    out = {
      show name: set text(fill: text-on(s.fill))
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
#let photo(name, fit: "cover") = m.components.image(path("assets/" + name), fit: fit)
#let lorem = [Elaborate on your topic here. Lorem ipsum dolor sit amet,
consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco
laboris nisi ut aliquip ex ea commodo consequat.]
#let frame = [
  #place(top + left, dx: 14pt, dy: 14pt)[
    #rect(width: 814pt, height: 446pt, stroke: 0.8pt + white)
  ]
]

// This deck builds every slide by hand, so `slide` is rebound to `m.slide`.
// The theme's `default` layout still backs `==` headings.
#let slide = m.slide
