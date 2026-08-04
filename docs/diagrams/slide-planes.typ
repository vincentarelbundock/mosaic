#import "@preview/cetz:0.5.2"

// Colors double as theme tokens on the website: `docs/theme/css/mosaic.css`
// rewrites these exact values inside `.mosaic-diagram` frames, so labels and
// leader arrows follow the page text color and the surfaces adapt to dark
// mode. Keep the literals here in sync with that stylesheet.
#let ink = rgb("#1f2933")

// Exploded view of a slide's three depth layers: the background plane, the
// grid, and the foreground plane. Each plane is drawn as a sheared parallelogram
// so the stack reads as parallel layers seen at an angle. The planes cover the
// full slide and never affect grid measurement (see the Depth axis in Concepts).
#let diagram = {
  set text(fill: ink)
  cetz.canvas(length: 0.62cm, {
    import cetz.draw: line, content, circle

    let blue = rgb("#176b87")
    let pale-blue = rgb("#e8f1fb")
    let pale-gold = rgb("#fff4cf")
    let pale-green = rgb("#e5f5ee")
    let arrow = (end: "stealth", fill: ink, scale: 0.8)

    // Plane geometry: local (u, v) in [0, W] x [0, H] sheared by (sx, sy) so the
    // back edge (v = H) sits up and to the right of the front edge (v = 0).
    let W = 10
    let H = 4.4
    let sx = 3.1
    let sy = 1.85
    let map = (base, u, v) => (u + v / H * sx, base + v / H * sy)
    let plane = (base, fill) => line(
      map(base, 0, 0),
      map(base, W, 0),
      map(base, W, H),
      map(base, 0, H),
      close: true,
      fill: fill,
      stroke: 0.8pt + blue,
    )

    // Front-edge height of each plane, back (bottom) to front (top).
    let bg = 0
    let gr = 2.9
    let fg = 5.8

    // ── Background plane ──────────────────────────────────────────────────
    plane(bg, pale-green)
    // A placed shape suggesting a background image or banner.
    line(
      map(bg, 0.6, 0.5), map(bg, 3.4, 0.5), map(bg, 3.4, 3.7), map(bg, 0.6, 3.7),
      close: true, fill: pale-gold, stroke: 0.5pt + blue,
    )

    // ── Grid ──────────────────────────────────────────────────────────────
    plane(gr, white)
    let hy = H * 0.62
    // Header/body split and a vertical split in the body: the same three-cell
    // shape as the flat "Anatomy of a slide" figure.
    line(map(gr, 0, hy), map(gr, W, hy), stroke: 0.7pt + blue)
    line(map(gr, 6, 0), map(gr, 6, hy), stroke: 0.7pt + blue)
    // Abstract content lines in the header cell.
    line(map(gr, 0.6, hy + 1.05), map(gr, 5.2, hy + 1.05), stroke: 1.4pt + blue)
    line(map(gr, 0.6, hy + 0.5), map(gr, 3.6, hy + 0.5), stroke: 1pt + blue)

    // ── Foreground plane ────────────────────────────────────────────────────
    // Transparent so the grid below shows through: the foreground floats over the
    // body without hiding it.
    plane(fg, pale-blue.transparentize(30%))
    // A page-number dot near the front-right corner.
    circle(map(fg, W - 0.7, 0.65), radius: 0.24, fill: blue, stroke: none)

    // ── Labels ────────────────────────────────────────────────────────────
    content((13.3, fg + 0.95), [*Foreground plane*], anchor: "west")
    line((13.1, fg + 0.9), map(fg, W, H * 0.5), stroke: ink, mark: arrow)

    content((13.3, gr + 0.95), [*Grid*], anchor: "west")
    line((13.1, gr + 0.9), map(gr, W, H * 0.5), stroke: ink, mark: arrow)

    content((13.3, bg + 0.95), [*Background plane*], anchor: "west")
    line((13.1, bg + 0.9), map(bg, W, H * 0.5), stroke: ink, mark: arrow)
  })
}
