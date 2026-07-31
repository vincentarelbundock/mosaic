#import "@local/mosaic:0.0.1" as m

// ── Palette ────────────────────────────────────────────────────────────────
#let ink = rgb("#111111")
#let paper = rgb("#f7f7f5")
#let gray = rgb("#d9d9d9")
#let small-copy = 11pt
#let body-copy = 13pt

// ── Copy ───────────────────────────────────────────────────────────────────
#let lorem = [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.]

// ── Helpers ────────────────────────────────────────────────────────────────
#let photo(name, fit: "cover") = m.image(path("assets/" + name), fit: fit)

#let cell = m.grid.cell
#let surface(..overrides) = (
  (fill: none, inset: 0pt, align: top + left) + overrides.named()
)

#let black-panel(body, inset: 20pt) = block(
  width: 100%,
  fill: ink,
  inset: inset,
  text(fill: white, body),
)

#let project-card(number, body) = grid(
  columns: (62pt, 1fr),
  gutter: 15pt,
  align: top,
  rect(fill: white, inset: 8pt, text(size: 30pt, weight: "bold", number)),
  text(size: 11pt, fill: white, body),
)

// ── Theme ──────────────────────────────────────────────────────────────────
// Applied in main.typ via `#show: deck-theme`. Show/set rules cannot cross an
// `#import`, so the document-wide styling lives in this wrapper rather than at
// the top level of the preamble.
#let deck-theme(body) = {
  show: m.setup.with(
    colors: (
      canvas: paper,
      surface: paper,
      accent: ink,
      text: ink,
      inverse-text: white,
      muted: rgb("#666666"),
      line: gray,
    ),
    spacing: (inset: 0pt),
  )
  set text(font: "Inter", size: body-copy, fill: ink)
  show heading: set text(weight: "bold")
  body
}
