// ═══════════════════════════════════════════════════════════════════════════
//  Content
//
//  The reusable look is the bundled Metropolis theme (m.themes.metropolis),
//  re-exported as `theme` by theme.typ; deck-specific helpers live in
//  preamble.typ. `*` re-exports Mosaic (`m`), fletcher, cetz, calepin, and
//  every helper used below. From here down, each slide is a `== Heading`
//  routed through the theme's default layout or one call to a theme layout
//  factory (`theme.title`, `theme.section`, `theme.default`).
// ═══════════════════════════════════════════════════════════════════════════
// Root-absolute import: Calepin compiles main.typ from a generated wrapper
// directory, so a relative "preamble.typ" would not resolve. The Calepin root
// is this example directory (cf. the "/references.bib" bibliography below).
#import "/preamble.typ": *
#show: theme.apply

#m.deck()

#let ccp = (id: "ccp", name: [Centre for Comparative Politics])
#let eis = (id: "eis", name: [European Institute for Social Data])

#theme.title(
  [
    // `calepin.setup` runs once inside the title content to enable the R
    // chunks used later in the deck.
    #calepin.setup(echo: true, eval: true, results: "render")
    Technical talk
  ],
  subtitle: [Math, Diagrams, and Executable Code],
  authors: (
    m.author(
      [Priya Nair],
      affiliations: (ccp, eis),
      email: "priya.nair@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    m.author([Elena García], affiliations: (eis,)),
    m.author([Noah Williams], affiliations: (ccp,)),
  ),
  date: [July 30, 2026],
)

== Roadmap

#set enum(numbering: "1.", spacing: 1.15em)
#enum(
  [Formalize the decision problem],
  [Expose the computation],
  [Explain system structure],
  [Connect results to evidence],
)

#theme.section([Model])

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

#theme.section([Computation])

// `calepin.chunk` runs R at compile time. The first chunk evaluates the code
// and saves the plot under label "fig-efficiency" (retrieved on the next
// slide with `calepin.results`); the second is eval:false, shown only as code.
== An executable analysis

The source below is executed during compilation. Its figure is cached by
Calepin and placed on the following slide.

#v(10pt)

```r
#| label: "fig-efficiency"
#| echo: true
#| eval: true
#| message: false
#| results: "hide"
#| fig-width: 92%
#| fig-device-width: 6.5
#| fig-device-height: 4.2
#| fig-alt-text: "Fuel efficiency versus horsepower by transmission type"
library(ggplot2)
fit <- lm(mpg ~ hp + factor(am), data = mtcars)

ggplot(mtcars, aes(hp, mpg, color = factor(am))) +
  geom_point(size = 2.6, alpha = 0.85) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.9) +
  scale_color_manual(
    values = c("0" = "#657377", "1" = "#f28e2b"),
    labels = c("Automatic", "Manual")) +
  labs(x = "Horsepower", y = "Fuel efficiency (mpg)", color = "Transmission") +
  theme_minimal(base_family = "Fira Sans", base_size = 13) +
  theme(legend.position = "top", panel.grid.minor = element_blank())
```

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

#theme.section([Structure])

== File-reader state machine

// The scoped `set align` centers the diagram without leaking to later
// slides. A content block stays transparent to Mosaic's step discovery, so
// `m.slide` still sees the reveal steps inside `state-diagram`.
#[
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
]

#theme.section([Geometry])

== A qubit as a Bloch vector

#[
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
]

#theme.section([Evidence])

== What makes a technical slide?

#grid(
  columns: (1fr, 1fr),
  gutter: 35pt,
  align: top + left,
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
// Cells are structural, so the fill and centering are native rules on the
// cell's <mosaic-cell-questions> label, scoped to this slide.
#[
  #show label("mosaic-cell-questions"): set align(center + horizon)
  #show label("mosaic-cell-questions"): it => block(
    width: 100%,
    height: 100%,
    fill: ink,
    it,
  )
  #m.slide(grid: m.grid.cell("questions"))[
    #text(size: 1.6em, weight: "medium", fill: white)[Questions?]
  ]
]

// A real `==` heading in the header block keeps the same heading show rules
// (and therefore the same size) as the automatic slide headers.
#theme.default([
== References
], number: false)[
  #set text(size: 0.63em)
  #bibliography("/references.bib", title: none, style: "ieee")
]
