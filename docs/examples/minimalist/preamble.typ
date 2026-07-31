#import "@local/mosaic:0.0.1" as m

// ── Palette ────────────────────────────────────────────────────────────────
#let cream = rgb("#fffcf9")
#let red = rgb("#c83224")
#let serif = "Source Serif 4"

// ── Copy ───────────────────────────────────────────────────────────────────
#let copy = [Presentations turn ideas into clear stories for an audience.
They can inform, persuade, teach, or spark discussion.]

// ── Helpers ────────────────────────────────────────────────────────────────
#let photo(name, fit: "cover") = m.image(path("assets/" + name), fit: fit)

#let c = m.grid.cell
#let surface(..overrides) = (
  (fill: cream, inset: 0pt, align: top + left) + overrides.named()
)

// Font and fill are set once via `#set text(font: serif, fill: red)` in the
// theme below; these helpers inherit both and only vary size (and weight for
// titles).
#let title(body, size: 2.21em) = text(size: size, weight: "bold", body)
#let body-text(body, size: 1em) = text(size: size, body)

#let slide = m.slide

// ── Theme ──────────────────────────────────────────────────────────────────
// Applied in main.typ via `#show: deck-theme`. Show/set rules cannot cross an
// `#import`, so the document-wide styling lives in this wrapper rather than at
// the top level of the preamble.
#let deck-theme(body) = {
  show: m.setup.with(
    colors: (
      canvas: cream,
      surface: cream,
      accent: red,
      text: red,
      inverse-text: cream,
      muted: red,
      line: red,
    ),
    spacing: (inset: 0pt),
  )
  set text(font: serif, fill: red, size: 14pt)
  body
}
