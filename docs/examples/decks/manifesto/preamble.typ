// Deck-specific preamble for the Manifesto deck. The reusable look is the
// bundled Manifesto theme, a complete Mosaic facade, re-exported here as `m`
// together with this deck's visual constants; importing this file with `*`
// re-exports everything to main.typ. The helpers below belong to this deck's
// content rather than to the theme.
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.manifesto as m

// ── Colors ─────────────────────────────────────────────────────────────────
#let cream = rgb("#fffcf9")
#let red = rgb("#c83224")

// ── Copy ───────────────────────────────────────────────────────────────────
#let copy = [Presentations turn ideas into clear stories for an audience.
They can inform, persuade, teach, or spark discussion.]

// ── Helpers ────────────────────────────────────────────────────────────────
#let photo(name, fit: "cover") = m.components.image(path("assets/" + name), fit: fit)

// Cells are structural. This deck paints them by hand, so every cell starts
// with a zero inset; `surface()` carries the padding, which `styled()` applies
// through the cell's <mosaic-cell-ID> label alongside the fill and alignment.
#let c(..args) = m.grids.cell(..args, inset: 0pt)
#let surface(..overrides) = (
  (fill: cream, inset: 0pt, align: top + left) + overrides.named()
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

// Font and fill are set once via `#set text(font: serif, fill: red)` in the
// theme; these helpers inherit both and only vary size (and weight for
// titles).
#let title(body, size: 2.21em) = text(size: size, weight: "bold", body)
#let body-text(body, size: 1em) = text(size: size, body)

// This deck builds every slide by hand, so `slide` is rebound to `m.slide`.
// The theme's `default` layout still backs `==` headings.
#let slide = m.slide
