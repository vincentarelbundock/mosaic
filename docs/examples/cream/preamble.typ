#import "@local/mosaic:0.0.1" as m

// ── Palette ────────────────────────────────────────────────────────────────
#let sage = rgb("#aebdb3")
#let sage-dark = rgb("#93a69b")
#let cream = rgb("#f2eee5")
#let ink = rgb("#111111")
#let white = rgb("#f9f8f3")
#let sans = "Inter"

// ── Helpers ────────────────────────────────────────────────────────────────
#let c = m.grid.cell
#let surface(..overrides) = (
  (fill: sage, inset: 0pt, align: top + left) + overrides.named()
)
#let photo(name, fit: "cover") = m.image(path("assets/" + name), fit: fit)
#let lorem = [Elaborate on your topic here. Lorem ipsum dolor sit amet,
consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco
laboris nisi ut aliquip ex ea commodo consequat.]
#let frame = [
  #place(top + left, dx: 14pt, dy: 14pt)[
    #rect(width: 814pt, height: 446pt, stroke: 0.8pt + white)
  ]
]

#let slide = m.slide

// ── Theme ──────────────────────────────────────────────────────────────────
// Applied in main.typ via `#show: deck-theme`. Show/set rules cannot cross an
// `#import`, so the document-wide styling lives in this wrapper rather than at
// the top level of the preamble.
//
// Deck typography is defined once here and driven entirely by heading level.
// `base` is the single source of truth; heading sizes are `base * factor` in
// absolute units so they scale from the base without depending on any Mosaic
// style role (and without compounding with Mosaic's own em-based heading rules).
// Titles are ordinary headings (`= ...` / `== ...`); bodies are plain text.
// Cream surfaces switch the text fill to `ink`; sage surfaces keep white.
#let base = 18pt
#let deck-theme(body) = {
  show: m.setup.with(
    colors: (
      canvas: sage,
      surface: sage,
      accent: cream,
      text: white,
      inverse-text: ink,
      muted: cream,
      line: white,
    ),
    spacing: (inset: 0pt),
  )
  set text(font: sans, size: base)
  show heading.where(level: 1): set text(size: base * 1.9, weight: "bold")
  show heading.where(level: 2): set text(size: base * 1.25, weight: "bold")
  show heading: set block(below: 0.5em)
  body
}
