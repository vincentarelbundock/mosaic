// Metropolis-style technical deck built on the Mosaic slide framework.
//   - mosaic   : slide layout, grids, incremental reveals (`m.reduce`, `m.on`)
//   - fletcher : node/edge diagrams (the state machine)
//   - cetz     : general vector drawing (the Bloch sphere)
//   - calepin  : executes embedded R chunks at compile time and caches results
#import "@local/mosaic:0.0.1" as m
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.5.2"
#import "/.calepin/calepin.typ" as calepin

// ── Palette ──────────────────────────────────────────────────────────────
// Metropolis's signature ink/orange scheme, plus a few accent colors used to
// tint individual terms in the Bellman equation.
#let ink = rgb("#23373b")
#let orange = rgb("#f28e2b")
#let paper = rgb("#fafafa")
#let soft = rgb("#dddddd")
#let blue = rgb("#2563eb")
#let green = rgb("#15803d")
#let red = rgb("#c2410c")
#let sans = "Fira Sans"
#let mono = "Fira Mono"

// ═══════════════════════════════════════════════════════════════════════════
//  Slide constructors
//
//  `slide` is the ordinary content slide. It is registered as `auto-slide` in
//  the setup below, so plain `== Title` markup renders through it — no explicit
//  `#slide(...)` call needed. These definitions must precede `#show: m.setup`
//  because setup captures `slide`. `slide-title` and `slide-section` are
//  defined after setup and called explicitly.
// ═══════════════════════════════════════════════════════════════════════════

// Bottom-right slide-number / progress dot, shown on ordinary frames and
// suppressed (number: false) on the reference and backup slides.
#let footer(number: true) = [
  #if number {
    place(bottom + right, dx: -0.9em, dy: -0.7em)[
      #text(size: 0.48em)[
        #m.components.progress(variant: "1", color: rgb("#667477"))
      ]
    ]
  }
]

// Shared "header-body" layout for ordinary content slides: an inverted
// (dark) title bar above a left-aligned, vertically centered body.
#let slide-grid = m.templates.default(
  variant: "header-body",
  // Invert the header (dark bar, light text); the medium weight is the only
  // typographic tweak — size and color come from the theme. Insets are left at
  // Mosaic's standard spacing.inset.
  inverted: ("header",),
  text: (header: (weight: "medium")),
  align: (body: left + horizon),
)

// A standard content slide: `slide(title, body)`. The two content blocks map
// to the header and body cells of `slide-grid`. The body is left-aligned by
// default; use `#set align(center)` in the body when a slide needs its content
// centered (e.g. a single diagram).
#let slide(title, body, number: true) = m.slide(
  grid: slide-grid,
  foreground: footer(number: number),
)[#title][#body]

// ── Theme ────────────────────────────────────────────────────────────────
// Register the palette with Mosaic and set document-wide typography. `setup`
// wires the colors into every built-in cell (title, section, questions, ...).
#show: m.setup.with(
  paper: "16-9",
  colors: (
    canvas: paper,
    surface: paper,
    accent: orange,
    text: ink,
    inverse-text: paper,
    muted: rgb("#657377"),
    line: soft,
  ),
  // Route every `== Title` heading through the `slide` helper above, so
  // ordinary content is written as headings yet keeps the inverted header bar
  // and footer dot. Mosaic's standard inset (1.25em) is left in place.
  auto-slide: slide,
)
// The base font size is the single pt anchor; every other size below is
// expressed as a multiple of it (em) so the deck scales as a unit.
#set text(font: sans, size: 21.5pt, fill: ink)
#show raw: set text(font: mono, size: 0.65em)

// ═══════════════════════════════════════════════════════════════════════════
//  Explicit slide constructors (title and section dividers)
// ═══════════════════════════════════════════════════════════════════════════

// Section-divider slide: large centered title over a progress bar that fills
// as we advance through the deck's sections.
#let slide-section(title) = {
  m.slide(
    grid: m.grid.cell("section"),
    section: true,
    cell-styles: (section: (fill: paper, align: left + horizon)),
  )[
    #text(size: 1.6em, weight: "medium")[#title]
    #v(0.4em)
    #m.components.progress(
      variant: "line",
      count: "sections",
      width: 100%,
      thickness: 3.01pt,
      track: rgb("#b8b1a8"),
      color: orange,
    )
  ]
}

// Opening slide built on Mosaic's `title` template (the "left-aligned"
// variant): a bottom-anchored title mass, the subtitle, an accent rule, then
// an author byline and date — the classic Metropolis title layout. The title
// text is the single body block; subtitle/author/date are template fields.
// `calepin.setup` runs once here to enable the R chunks used later in the deck.
#let slide-title(title, subtitle, author, date) = m.slide(
  grid: m.templates.title(
    variant: "left-aligned",
    subtitle: subtitle,
    authors: (m.author(author),),
    date: date,
  ),
)[
  #calepin.setup(echo: true, eval: true, results: "render")
  #title
]

// ── Inline content helpers ─────────────────────────────────────────────────
// Small building blocks used *inside* a slide body rather than whole slides.
#let code(body) = text(font: mono, size: 0.65em, body)
#let alert(body) = text(fill: orange, body)
#let finding(title, body) = block(
  width: 100%,
  fill: soft.lighten(55%),
  inset: 0.5em,
)[
  #text(size: 0.74em, weight: "medium", fill: orange)[#title]
  #linebreak()
  #body
]

// Fixed-footprint annotations prevent incremental underbraces from moving
// neighboring terms or changing the equation's baseline.
#let dstrut = context { hide($j$) + h(-measure($j$).width) }
#let explained(color, term, label) = context {
  let braced = text(fill: color, $underbrace(#term #dstrut, #label)$)
  box(height: measure(text(fill: color, $#term$)).height, braced)
}

// `m.reduce` wraps a drawing package so that elements guarded by `m.on("2-",
// ...)` appear across successive reveals. `hide` keeps hidden elements in the
// layout (reserving their space) so nothing shifts as the diagram is built up.
#let state-diagram = m.reduce.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

#let canvas = m.reduce.with(
  render: cetz.canvas,
  hide: cetz.draw.hide.with(bounds: true),
)

// ═══════════════════════════════════════════════════════════════════════════
//  Content
//
//  From here down, each slide is one call to a constructor defined above.
// ═══════════════════════════════════════════════════════════════════════════

#m.deck()

#slide-title(
  [Technical talk],
  [Math, Diagrams, and Executable Code],
  [Vincent Arel-Bundock],
  [July 30, 2026],
)

== Roadmap

#set enum(numbering: "1.", spacing: 1.15em)
#enum(
  [Formalize the decision problem],
  [Expose the computation],
  [Explain system structure],
  [Connect results to evidence],
)

#slide-section([Model])

== Sequential decisions under uncertainty

We consider an agent that repeatedly observes a state, chooses an action,
and receives a reward.
#v(18pt)
- *State:* $s in cal(S)$ summarizes the information available now.
- *Action:* $a in cal(A)$ changes both reward and the next-state distribution.
- *Objective:* maximize expected discounted return over an indefinite horizon.
#v(18pt)
#finding([Modeling assumption])[
  The current state is sufficient: conditional on $s_t$ and $a_t$, the
  future is independent of the earlier history.
]

// `m.replace` swaps the same slot's content across reveals: each argument is
// the version shown on successive steps. Here we annotate one term of the
// equation at a time (reward, then discount, then future value) without
// re-flowing the rest of the formula.
== Bellman optimality equation

#show math.equation.where(block: true): set text(size: 1.35em)
$
  V^star(s) = max_a
      #m.replace(
        align: top + center,
        [$R(s, a)$],
        [#explained(red, $R(s, a)$, [immediate reward])],
        [#explained(red, $R(s, a)$, [immediate reward])],
        [#explained(red, $R(s, a)$, [immediate reward])],
      )
      + #m.replace(
        align: top + center,
        [$gamma$],
        [$gamma$],
        [#explained(blue, $gamma$, [discount factor])],
        [#explained(blue, $gamma$, [discount factor])],
      )
      #m.replace(
        align: top + center,
        [$sum_(s') P(s' | s, a) V^star(s')$],
        [$sum_(s') P(s' | s, a) V^star(s')$],
        [$sum_(s') P(s' | s, a) V^star(s')$],
        [#explained(
          green,
          $sum_(s') P(s' | s, a) V^star(s')$,
          [optimal future value],
        )],
      )
$
#v(31pt)
The recursion separates immediate utility from the expected value of all
subsequent decisions #cite(<bellman1957>).

== Value iteration

#grid(
    columns: (1.15fr, 1fr),
    gutter: 30pt,
    align: top,
    [
      ```text
      initialize V(s) ← 0
      repeat
        for each state s
          V′(s) ← maxₐ [
            R(s,a) + γ Σₛ′
            P(s′|s,a)V(s′)
          ]
        δ ← ‖V′ − V‖∞
        V ← V′
      until δ < ε
      ```
    ],
    [
      *Convergence conditions*
      #v(8pt)
      - finite state and action spaces
      - $0 <= gamma < 1$
      - bounded rewards
      #v(13pt)
      The contraction factor is $gamma$, so the stopping tolerance has a direct
      interpretation.
    ],
  )

#slide-section([Computation])

// `calepin.chunk` runs R at compile time. The first chunk evaluates the code
// and saves the plot under label "fig-efficiency" (retrieved on the next
// slide with `calepin.results`); the second is eval:false, shown only as code.
== An executable analysis

The source below is executed during compilation. Its figure is cached by
Calepin and placed on the following slide.
#v(10pt)
#calepin.chunk(
    "r",
    label: "fig-efficiency",
    echo: false,
    message: false,
    results: "hide",
    fig-width: 92%,
    fig-device-width: 6.5,
    fig-device-height: 4.2,
    fig-alt-text: "Fuel efficiency versus horsepower by transmission type",
  )[
    ```r
    suppressPackageStartupMessages(library(ggplot2))

    fit <- lm(mpg ~ hp + factor(am), data = mtcars)

    ggplot(mtcars, aes(hp, mpg, color = factor(am))) +
      geom_point(size = 2.6, alpha = 0.85) +
      geom_smooth(method = "lm", se = FALSE, linewidth = 0.9) +
      scale_color_manual(
        values = c("0" = "#657377", "1" = "#f28e2b"),
        labels = c("Automatic", "Manual")
      ) +
      labs(x = "Horsepower", y = "Fuel efficiency (mpg)",
           color = "Transmission") +
      theme_minimal(base_family = "Fira Sans", base_size = 13) +
      theme(legend.position = "top",
            panel.grid.minor = element_blank())
    ```
  ]
#calepin.chunk("r", eval: false)[
    ```r
    suppressPackageStartupMessages(library(ggplot2))

    fit <- lm(mpg ~ hp + factor(am), data = mtcars)

    ggplot(mtcars, aes(hp, mpg, color = factor(am))) +
      geom_point(size = 2.6, alpha = 0.85) +
      geom_smooth(method = "lm", se = FALSE, linewidth = 0.9) +
      scale_color_manual(
        values = c("0" = "#657377", "1" = "#f28e2b"),
        labels = c("Automatic", "Manual")
      ) +
      labs(x = "Horsepower", y = "Fuel efficiency (mpg)",
           color = "Transmission") +
      theme_minimal(base_family = "Fira Sans", base_size = 13) +
      theme(legend.position = "top",
            panel.grid.minor = element_blank())
    ```
  ]

== Horsepower predicts lower efficiency

#grid(
  columns: (1.65fr, 1fr),
  gutter: 25pt,
  align: top,
  [#calepin.results("fig-efficiency")],
  [
    #set text(size: 0.79em)
    - Fuel efficiency declines as horsepower increases.
    - Transmission groups occupy different regions of the sample.
    - The fitted lines summarize association, not causation.
    #v(14pt)
    #text(size: 0.6em, fill: rgb("#657377"))[
      Data: `mtcars`, 32 model-year 1973–74 automobiles.
    ]
  ],
)

== Computed model summary

The same R session retains `fit`, so numerical claims can be generated rather
than copied into the deck.
#v(18pt)
#calepin.chunk("r", echo: false, results: "typst")[
    ```r
    b <- coef(summary(fit))
    r2 <- summary(fit)$r.squared
    cat(sprintf(
      "#block(width: 100%%, fill: rgb(\"#eeeeee\"), inset: 10pt)[
      #strong[Estimated association] \
      Holding transmission fixed, an additional 10 horsepower is associated
      with *%.2f fewer mpg*. The model explains *%.1f%%* of the observed
      variation in fuel efficiency.
      ]",
      -10 * b["hp", "Estimate"], 100 * r2
    ))
    ```
]

#slide-section([Structure])

== File-reader state machine

// `set align` centers the diagram without wrapping it, so `m.slide` can
// still see the reveal steps inside `state-diagram`.
#set align(center)
#state-diagram(
    node-stroke: 0.1em,
    node-fill: orange.lighten(75%),
    spacing: 4em,
    fletcher.edge((-1, 0), "r", "-|>", `open(path)`,
      label-pos: 0, label-side: center),
    fletcher.node((0, 0), `reading`, radius: 2em),
    m.on("2-", (
      fletcher.edge(`read()`, "-|>"),
      fletcher.node((1, 0), `eof`, radius: 2em),
      fletcher.edge((0, 0), (0, 0), `read()`, "--|>", bend: 130deg),
    )),
    m.on("3-", (
      fletcher.edge(`close()`, "-|>"),
      fletcher.node((2, 0), `closed`, radius: 2em, extrude: (-2.5, 0)),
      fletcher.edge((0, 0), (2, 0), `close()`, "-|>", bend: -40deg),
    )),
)

#slide-section([Geometry])

== A qubit as a Bloch vector

#set align(center)
#canvas(length: 2.15cm, {
    import cetz.draw: circle, content, line
    let rad = 2.5
    let vec-a = (rad / 3, rad / 2)
    let phi-point = (rad / 3, -rad / 5)
    let mark = (end: "stealth", fill: ink)

    circle((0, 0), radius: rad)
    circle((0, 0), radius: (rad, rad / 3),
      stroke: (dash: "dashed"), fill: gray.transparentize(70%))

    (
      m.on("2-", (
        line((0, 0), (-rad / 5 * 1.2, -rad / 3 * 1.2),
          mark: mark, name: "x1"),
        content("x1.end", [$x_1$], anchor: "north"),
        line((0, 0), (1.15 * rad, 0), mark: mark, name: "x2"),
        content("x2.end", [$x_2$], anchor: "west"),
        line((0, 0), (0, 1.15 * rad), mark: mark, name: "x3"),
        content("x3.end", [$x_3$], anchor: "south"),
      )),
    )

    (
      m.on("3-", (
        line((0, 0), vec-a,
          mark: (start: "circle", end: "circle", fill: ink,
            scale: 0.5, anchor: "center")),
        content((rel: (0.08, 0.08), to: vec-a), $arrow(a)$,
          anchor: "south-west"),
        line((0, 0), phi-point, style: "dashed"),
        line(phi-point, vec-a, style: "dashed"),
      )),
    )

    (
      m.on("4-", (
        cetz.angle.angle((0, 0), (-1, -calc.tan(60deg)),
          (1, -calc.tan(30deg)), label: [$phi$],
          stroke: (paint: gray, thickness: 0.5pt),
          mark: (end: "stealth", fill: gray, scale: 0.7)),
        cetz.angle.angle((0, 0), (1, calc.tan(60deg)),
          (1, calc.tan(90deg)), label: [$theta$],
          stroke: (paint: gray, thickness: 0.5pt),
          mark: (start: "stealth", fill: gray, scale: 0.7),
          label-radius: 0.75),
      )),
    )
})

#slide-section([Evidence])

== What makes a technical slide?

#grid(
  columns: (1fr, 1fr),
  gutter: 35pt,
  align: top,
  [
    *Include*
    - a question or claim
    - units and definitions
    - reproducible computation
    - a stated interpretation
  ],
  [
    *Avoid*
    - unlabelled decorative plots
    - numbers copied by hand
    - animation without exposition
    - citations disconnected from claims
  ],
)

// One-off closing slide: a full ink-filled cell with centered white text.
#m.slide(
  grid: m.grid.cell("questions"),
  cell-styles: (questions: (fill: ink, align: center + horizon)),
)[
  #text(size: 1.6em, weight: "medium", fill: white)[Questions?]
]

#slide([References], number: false)[
  #set text(size: 0.63em)
  #bibliography("/references.bib", title: none, style: "ieee")
]
