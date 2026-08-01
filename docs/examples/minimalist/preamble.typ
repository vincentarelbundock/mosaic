// Deck-specific preamble for the Minimalist White deck. The reusable look is
// the bundled Minimalist White theme (m.themes.minimalist); theme.typ
// re-exports it as `theme` together with its palette tokens, and importing
// that with `*` re-exports everything to main.typ. The helpers below belong
// to this deck's content rather than to the theme.
#import "theme.typ": *

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
// theme; these helpers inherit both and only vary size (and weight for
// titles).
#let title(body, size: 2.21em) = text(size: size, weight: "bold", body)
#let body-text(body, size: 1em) = text(size: size, body)

// This deck builds every slide by hand, so `slide` is rebound to `m.slide`.
// The theme's `default` layout still backs `==` headings.
#let slide = m.slide
