#import "@local/mosaic:0.0.1" as m
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.5.2"
#import "/.calepin/calepin.typ" as calepin

#let ink = rgb("#23373b")
#let orange = rgb("#f28e2b")
#let paper = rgb("#fafafa")
#let soft = rgb("#dddddd")
#let blue = rgb("#2563eb")
#let green = rgb("#15803d")
#let red = rgb("#c2410c")
#let sans = "Fira Sans"
#let mono = "Fira Mono"

#show: m.setup.with(
  paper: "4-3",
  colors: (
    canvas: paper,
    surface: paper,
    accent: orange,
    text: ink,
    inverse-text: paper,
    muted: rgb("#657377"),
    line: soft,
  ),
  spacing: (inset: 0pt),
)
#set text(font: sans, size: 21.5pt, fill: ink)
#set par(leading: 0.65em)
#set list(marker: [–], indent: 1.15em, body-indent: 0.55em, spacing: 0.42em)
#set enum(indent: 1.15em, body-indent: 0.55em, spacing: 0.42em)
#show raw: set text(font: mono, size: 14pt)

#let cell = m.grid.cell
#let base-cell-style = (fill: paper, inset: 0pt, align: top + left)

#let footer(number: true) = [
  #if number {
    place(bottom + right, dx: -19.35pt, dy: -15.05pt)[
      #text(size: 10.32pt)[
        #m.components.progress(variant: "1", color: rgb("#667477"))
      ]
    ]
  }
]

#let frame-grid = m.templates.default(
  variant: "header-body",
  inverted: ("header",),
  text: (header: (size: 18.27pt, weight: "medium", fill: white)),
  align: (body: left + horizon),
  inset: (
    header: (left: 17.2pt, right: 17.2pt, top: 10.75pt, bottom: 10.75pt),
    body: (left: 52pt, right: 52pt, top: 25pt, bottom: 42pt),
  ),
)

#let frame(title, body, number: true) = m.slide(
  grid: frame-grid,
  foreground: footer(number: number),
)[#title][#body]

#let centered-frame(title, body, number: true) = m.slide(
  grid: frame-grid,
  foreground: footer(number: number),
  cell-styles: (body: (align: center + horizon)),
)[#title][#body]

#let section-slide(title) = {
  m.slide(
    grid: cell("section"),
    section: true,
    cell-styles: (section: base-cell-style + (
      inset: (left: 156.95pt, right: 156.95pt),
      align: left + horizon,
    )),
  )[
    #text(size: 34.4pt, weight: "medium")[#title]
    #v(8.6pt)
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

#let code(body) = text(font: mono, size: 14pt, body)
#let alert(body) = text(fill: orange, body)
#let finding(title, body) = block(
  width: 100%,
  fill: soft.lighten(55%),
  inset: 10pt,
)[
  #text(size: 16pt, weight: "medium", fill: orange)[#title]
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

#let state-diagram = m.reduce.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

#let canvas = m.reduce.with(
  render: cetz.canvas,
  hide: cetz.draw.hide.with(bounds: true),
)

#m.deck()

// Title
#m.slide(
  grid: cell("title"),
  cell-styles: (title: base-cell-style + (
    inset: (left: 64.5pt, right: 64.5pt),
    align: left + horizon,
  )),
)[
  #calepin.setup(echo: true, eval: true, results: "render")
  #text(size: 34.4pt, weight: "medium")[Executable technical talks]
  #v(8.6pt)
  #text(size: 23.65pt)[Models, computation, and evidence with Mosaic]
  #v(19.35pt)
  #line(length: 100%, stroke: 3.01pt + orange)
  #v(30.1pt)
  #text(size: 15.05pt)[A Metropolis technical showcase]
  #linebreak()
  #text(size: 15.05pt)[July 30, 2026]
]

#frame([Roadmap])[
  #set enum(numbering: "1.", spacing: 1.15em)
  #enum(
    [Formalize the decision problem],
    [Expose the computation],
    [Explain system structure],
    [Connect results to evidence],
  )
]

#section-slide([Model])

#frame([Sequential decisions under uncertainty])[
  We consider an agent that repeatedly observes a state, chooses an action,
  and receives a reward.
  #v(18pt)
  #list(
    [*State:* $s in cal(S)$ summarizes the information available now.],
    [*Action:* $a in cal(A)$ changes both reward and the next-state distribution.],
    [*Objective:* maximize expected discounted return over an indefinite horizon.],
  )
  #v(18pt)
  #finding([Modeling assumption])[
    The current state is sufficient: conditional on $s_t$ and $a_t$, the
    future is independent of the earlier history.
  ]
]

#frame([Bellman optimality equation])[
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
]

#frame([Value iteration])[
  #grid(
    columns: (1.15fr, 1fr),
    gutter: 30pt,
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
      #list(
        [finite state and action spaces],
        [$0 <= gamma < 1$],
        [bounded rewards],
      )
      #v(13pt)
      The contraction factor is $gamma$, so the stopping tolerance has a direct
      interpretation.
    ],
  )
]

#section-slide([Computation])

#frame([An executable analysis])[
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
]

#frame([Horsepower predicts lower efficiency])[
  #grid(
    columns: (1.65fr, 1fr),
    gutter: 25pt,
    [#calepin.results("fig-efficiency")],
    [
      #set text(size: 17pt)
      #list(
        [Fuel efficiency declines as horsepower increases.],
        [Transmission groups occupy different regions of the sample.],
        [The fitted lines summarize association, not causation.],
      )
      #v(14pt)
      #text(size: 13pt, fill: rgb("#657377"))[
        Data: `mtcars`, 32 model-year 1973–74 automobiles.
      ]
    ],
  )
]

#frame([Computed model summary])[
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
]

#section-slide([Structure])

#centered-frame([File-reader state machine])[
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

#frame([State-machine invariants])[
  #list(
    [`read()` is valid only while the resource is open.],
    [End-of-file is a state, not an exceptional transition.],
    [`close()` is terminal: no outgoing transition leaves `closed`.],
  )
  #v(20pt)
  #finding([Why show the graph incrementally?])[
    Each reveal introduces one behavioral rule. The final frame then exposes
    the complete transition system without moving previously drawn nodes.
  ]
]

#section-slide([Geometry])

#centered-frame([A qubit as a Bloch vector])[
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

#frame([Bloch-sphere coordinates])[
  A pure qubit state can be written as
  #v(18pt)
  #align(center)[
    $
      |psi ⟩ =
      cos(theta / 2) |0 ⟩ +
      e^(i phi) sin(theta / 2) |1 ⟩.
    $
  ]
  #v(20pt)
  #list(
    [$theta$ controls latitude.],
    [$phi$ controls relative phase.],
    [Global phase is not observable.],
  )
]

#section-slide([Evidence])

#frame([What makes a technical slide?])[
  #grid(
    columns: (1fr, 1fr),
    gutter: 35pt,
    [
      *Include*
      #list(
        [a question or claim],
        [units and definitions],
        [reproducible computation],
        [a stated interpretation],
      )
    ],
    [
      *Avoid*
      #list(
        [unlabelled decorative plots],
        [numbers copied by hand],
        [animation without exposition],
        [citations disconnected from claims],
      )
    ],
  )
]

#frame([Takeaways])[
  #list(
    [Use incremental structure to explain equations and diagrams, not merely to
      decorate them.],
    [Compile analysis code with the talk so figures and numerical claims share
      one reproducible source.],
    [Keep citations next to the claims they support; reserve the full
      bibliography for the end #cite(<sutton2018>) #cite(<wickham2016>).],
  )
]

#m.slide(
  grid: cell("questions"),
  cell-styles: (questions: base-cell-style + (fill: ink, align: center + horizon)),
)[
  #text(size: 34.4pt, weight: "medium", fill: white)[Questions?]
]

#frame([References], number: false)[
  #set text(size: 13.5pt)
  #bibliography("/references.bib", title: none, style: "ieee")
]

#frame([Backup: reproducible build], number: false)[
  The deck is an executable document:
  #v(15pt)
  ```sh
  calepin compile main.typ metropolis-mosaic.pdf -- \
    --font-path "$FIRA_FONT_DIR"
  ```
  #v(15pt)
  Calepin executes the R chunks, stores their results, and then invokes Typst.
  The generated plot is therefore part of the build rather than a hand-managed
  asset.
]
