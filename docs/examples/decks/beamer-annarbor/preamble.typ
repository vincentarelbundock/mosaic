// Everything main.typ imports: the shared Mosaic API and a deck-local Mosaic
// theme that re-creates the look of Beamer's built-in AnnArbor theme: the
// wolverine palette (Michigan blue and maize), an infolines headline and
// footline banding the slide top and bottom, and a full-bleed frametitle bar.
//
// This is a design, not a transcription of the LaTeX sources, and it leans on
// Mosaic wherever Mosaic already has the gesture: all three layouts are
// built-in variants, the chrome rides the foreground plane, and the panels are
// components. What is left here is only what beamer has and Mosaic does not.
// There are no slide helpers: every beamer construction this deck needs is a
// Mosaic layout variant or a Mosaic component, and the theme states the rest.
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic: slide, note, fit, surface, grids, layouts, steps, components, info

// Beamer's wolverine color theme, resolved from its LaTeX mixes. `darkblue`
// there is rgb(0, 0, 0.8) and `orange` is rgb(1, 0.5, 0), so every `!` mix
// below is the arithmetic those two definitions produce.
#let structure = rgb("#00008f") // darkblue!70!black: titles, bullets, links
#let bar-blue = rgb("#0000a3") // darkblue!80!black: the dark banding
#let bar-amber = rgb("#ffbf00") // yellow!50!orange: type on the dark banding
#let bar-maize = rgb("#ffcc00") // yellow!60!orange: the middle banding
#let bar-light = rgb("#ffec00") // yellow!85!orange: the bright banding
#let frametitle-fill = rgb("#fff200") // yellow!90!orange: the frametitle bar
#let alert = rgb("#33339d") // darkblue!80!yellow: beamer's alerted text
#let example = rgb("#2f6b2f") // beamer's example green

// The palette Mosaic's own machinery reads. Beamer sets body copy in black and
// reserves the structure color for headings, markers, and chrome, so `accent`
// is the structure blue rather than any of the banding colors. `line` is a
// working color here, not a hairline: the toc section divider ghosts the
// sections you are not in with it.
#let colors = (
  canvas: rgb("#ffffff"),
  surface: rgb("#fff8dc"),
  text: rgb("#0d0d0d"),
  muted: rgb("#4a4a5e"),
  line: rgb("#a8a8bb"),
  accent: structure,
  warning: rgb("#b06000"),
  error: rgb("#a80000"),
)

// Vertical rhythm of the chrome, and the one measurement everything else is
// pinned to. The deck inset has to clear both bars, because the chrome rides
// the foreground plane and a plane reserves no space of its own: every cell's
// own padding is what keeps content off the banding. The header cell's inset is
// 0.55 of the deck inset, which is what the frametitle bar needs to clear the
// headline above it.
#let chrome-inset = 1.6em
#let chrome-size = 0.4em
#let nav-height = 0.62em
#let foot-height = 0.8em

// One segment of the headline or footline: a colored band of fixed height with
// small type sitting on its horizon. Mosaic has no banding component, so this
// is the deck's own.
#let bar-segment(body, fill: none, ink: black, to: center, height: foot-height) = block(
  width: 100%,
  height: height,
  fill: fill,
  inset: (x: chrome-inset),
  align(to + horizon, text(size: chrome-size, fill: ink, body)),
)

// Beamer's infolines headline: the current section right-aligned on the dark
// half, the current subsection left-aligned on the bright one. Mosaic has no
// subsection level, so the bright half stays clear, exactly as it does in a
// beamer deck that declares sections only.
//
// The section is read from the deck itself: `info().section` names the section
// the slide is in, so the headline states beamer's navigation without counting
// or querying anything of its own.
#let nav-bar = context {
  let section = info().section.title
  grid(
    columns: (1fr, 1fr),
    bar-segment(section, fill: bar-blue, ink: bar-amber, to: right, height: nav-height),
    bar-segment(none, fill: bar-light, to: left, height: nav-height),
  )
}

// Beamer's infolines footline: three equal segments carrying the author, the
// deck title, and the date with the frame counter. Every part of it is read
// back from `info()`, so the deck states them once on `setup` and never counts
// its own frames.
#let footline = context {
  let record = info()
  grid(
    columns: (1fr, 1fr, 1fr),
    bar-segment(
      record.authors.map(author => author.name).join([, ]),
      fill: bar-blue,
      ink: bar-amber,
    ),
    bar-segment(record.title, fill: bar-maize, ink: structure),
    bar-segment(
      fill: bar-light,
      ink: structure,
      grid(
        columns: (1fr, auto),
        align: horizon,
        align(center, record.date),
        // Beamer's `totalframenumber` counter, from the same record. The
        // title page precedes the count, so the slot stays clear there rather
        // than printing a zero; a section divider keeps showing the number it
        // is standing on, as beamer's does.
        if record.slide.number > 0 [#record.slide.number\/#record.slide.total],
      ),
    ),
  )
}

// Both bars on every slide, in one foreground plane. Beamer bands the title
// page and the section dividers exactly as it bands a content frame, and a
// plane is the one place a theme can say that once for every layout.
#let chrome = {
  place(top, nav-bar)
  place(bottom, footline)
}

#let apply(body, colors: (:), options: (:)) = {
  set text(
    font: options.font,
    size: options.base-size,
    fill: colors.text,
    fallback: true,
  )
  // Beamer marks list items with a small structure-colored triangle and
  // numbers them in the same color.
  set list(marker: text(fill: structure)[#sym.triangle.filled.small.r])
  set enum(numbering: n => text(fill: structure)[#n.])
  set table(stroke: 0.6pt + colors.line)
  show link: set text(fill: alert)
  show strong: set text(fill: structure)
  show figure.caption: set text(size: 0.7em, fill: colors.muted)

  // Stated absolutely: the native level-one heading scale and the section
  // cell's scale are both em multipliers, so an em size here would compound
  // and a `= Heading` section would outgrow an explicit section slide.
  let section-size = options.base-size * 1.2
  show heading: set text(fill: structure, weight: "bold")
  show heading.where(depth: 1): set text(size: section-size)
  show heading.where(depth: 2): set text(size: 1.15em)

  show raw: set text(font: options.font-mono)
  show raw.where(block: false): set text(fill: alert)
  show raw.where(block: true): set text(size: 0.68em)
  show raw.where(block: true): block.with(
    width: 100%,
    fill: colors.surface,
    stroke: 0.6pt + bar-maize,
    radius: 5pt,
    inset: 0.8em,
  )

  // The frametitle: the header cell painted edge to edge. `surface` is the
  // native spelling of a painted cell, and the cell's own inset (0.55 of the
  // deck inset) is what holds the title clear of the headline above it.
  show label("mosaic-cell-header"): surface(fill: frametitle-fill, height: auto)

  // Beamer's `titlelike` panel, on the display line of the title stack rather
  // than on the whole cell, so it hugs the title instead of the slide.
  show label("mosaic-title-display"): set text(size: 1.5em, weight: "bold", fill: structure)
  show label("mosaic-title-display"): it => block(
    width: 100%,
    fill: bar-light,
    radius: 5pt,
    inset: (x: 0.5em, y: 0.35em),
    align(center, it),
  )
  show label("mosaic-cell-title"): set align(center)

  show label("mosaic-cell-section"): set text(size: section-size, weight: "bold")
  body
}

#let definition = (
  name: "AnnArbor",
  colors: colors,
  defaults: (
    foreground: chrome,
    spacing: (inset: chrome-inset, gap: 0.7em),
  ),
  options: (
    // Beamer's default font theme is sans: Computer Modern Sans, which Latin
    // Modern Sans continues.
    font: ("Latin Modern Sans", "CMU Sans Serif", "DejaVu Sans"),
    font-mono: ("Latin Modern Mono", "DejaVu Sans Mono"),
    base-size: 22pt,
  ),
  // Three built-in variants, no hand-built grid. The toc divider is beamer's
  // own `\AtBeginSection` habit: the whole outline, the section you are
  // entering alive and the rest ghosted.
  layouts: (
    content: layouts.content(variant: "header-body"),
    title: layouts.title(variant: "centered"),
    section: layouts.section(variant: "toc"),
  ),
  apply: apply,
)

// Beamer decks are 4:3 unless told otherwise, and AnnArbor's banding was drawn
// for that shape.
#let setup = mosaic.themes.setup(definition).with(paper: "4-3")
