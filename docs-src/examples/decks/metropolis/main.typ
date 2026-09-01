// ═══════════════════════════════════════════════════════════════════════════
//  Content
//
//  This deck is deliberately bare: it imports the bundled Metropolis theme
//  and writes almost every slide as a `=` or `==` heading. The theme supplies
//  the ruled title page, the section progress bars, the bottom progress line,
//  and all typography. preamble.typ adds Fletcher, CeTZ, and the
//  equation-annotation helpers used below.
// ═══════════════════════════════════════════════════════════════════════════
#import "preamble.typ": *

#let ccp = [Centre for Comparative Politics]
#let eis = [European Institute for Social Data]

#show: m.setup.with(
  title: [Technical talk],
  subtitle: [Math and Diagrams],
  authors: (
    m.layouts.author(
      [Priya Nair],
      affiliations: (ccp, eis),
      email: "priya.nair@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    m.layouts.author([Elena García], affiliations: (eis,)),
    m.layouts.author([Noah Williams], affiliations: (ccp,)),
  ),
  date: [July 30, 2026],
)

#m.slide(layout: "title")

== Roadmap

#set enum(numbering: "1.", spacing: 1.15em)
#enum(
  [Formalize the decision problem],
  [Explain system structure],
  [Connect results to evidence],
)

= Model

== Sequential decisions under uncertainty

We consider an agent that repeatedly observes a state, chooses an action,
and receives a reward.
#v(18pt)
- *State:* #math.equation(alt: "s in the state space S", $s in cal(S)$) summarizes the information available now.
- *Action:* #math.equation(alt: "a in the action space A", $a in cal(A)$) changes both reward and the next-state distribution.
- *Objective:* maximize expected discounted return over an indefinite horizon.
#v(18pt)
#m.components.callout(title: [Modeling assumption])[
  The current state is sufficient: conditional on #math.equation(alt: "s sub t", $s_t$) and #math.equation(alt: "a sub t", $a_t$), the
  future is independent of the earlier history.
]

// `m.steps.replace` swaps the same slot's content across reveals: each argument is
// the version shown on successive steps. Here we annotate one term of the
// equation at a time (reward, then discount, then future value) without
// re-flowing the rest of the formula.
== Bellman optimality equation

#show math.equation.where(block: true): set text(size: 1.35em)
#math.equation(
  block: true,
  alt: "V star of s equals the maximum over a of: the immediate reward for state s and action a, plus the discount factor gamma times the sum over next states s prime of the transition probability times the optimal value of s prime.",
  $
    V^star(s) = max_a
        #m.steps.replace(
          align: top + center,
          [$R(s, a)$],
          [#explained(red, $R(s, a)$, [immediate reward])],
          [#explained(red, $R(s, a)$, [immediate reward])],
          [#explained(red, $R(s, a)$, [immediate reward])],
        )
        + #m.steps.replace(
          align: top + center,
          [$gamma$],
          [$gamma$],
          [#explained(blue, $gamma$, [discount factor])],
          [#explained(blue, $gamma$, [discount factor])],
        )
        #m.steps.replace(
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
  $,
)
#v(31pt)
The recursion separates immediate utility from the expected value of all
subsequent decisions #cite(<bellman1957>).

= Structure

== File-reader state machine

// The scoped `set align` centers the diagram without leaking to later
// slides. A content block stays transparent to Mosaic's step discovery, so
// `m.slide` still sees the reveal steps inside `state-diagram`.
#[
#set align(center)
#state-diagram(
    node-stroke: 0.1em,
    node-fill: rgb("#f28e2b").lighten(75%),
    spacing: 4em,
    fletcher.edge((-1, 0), "r", "-|>", `open(path)`,
      label-pos: 0, label-side: center),
    fletcher.node((0, 0), `reading`, radius: 2em),
    m.steps.on("2-", (
      fletcher.edge(`read()`, "-|>"),
      fletcher.node((1, 0), `eof`, radius: 2em),
      fletcher.edge((0, 0), (0, 0), `read()`, "--|>", bend: 130deg),
    )),
    m.steps.on("3-", (
      fletcher.edge(`close()`, "-|>"),
      fletcher.node((2, 0), `closed`, radius: 2em, extrude: (-2.5, 0)),
      fletcher.edge((0, 0), (2, 0), `close()`, "-|>", bend: -40deg),
    )),
)
]

= Geometry

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
      m.steps.on("2-", (
        line((0, 0), (-rad / 5 * 1.2, -rad / 3 * 1.2),
          mark: mark, name: "x1"),
        content("x1.end", math.equation(alt: "x one", $x_1$), anchor: "north"),
        line((0, 0), (1.15 * rad, 0), mark: mark, name: "x2"),
        content("x2.end", math.equation(alt: "x two", $x_2$), anchor: "west"),
        line((0, 0), (0, 1.15 * rad), mark: mark, name: "x3"),
        content("x3.end", math.equation(alt: "x three", $x_3$), anchor: "south"),
      )),
    )

    (
      m.steps.on("3-", (
        line((0, 0), vec-a,
          mark: (start: "circle", end: "circle", fill: ink,
            scale: 0.5, anchor: "center")),
        content((rel: (0.08, 0.08), to: vec-a), math.equation(alt: "vector a", $arrow(a)$),
          anchor: "south-west"),
        line((0, 0), phi-point, style: "dashed"),
        line(phi-point, vec-a, style: "dashed"),
      )),
    )

    (
      m.steps.on("4-", (
        cetz.angle.angle((0, 0), (-1, -calc.tan(60deg)),
          (1, -calc.tan(30deg)), label: math.equation(alt: "phi", $phi$),
          stroke: (paint: gray, thickness: 0.5pt),
          mark: (end: "stealth", fill: gray, scale: 0.7)),
        cetz.angle.angle((0, 0), (1, calc.tan(60deg)),
          (1, calc.tan(90deg)), label: math.equation(alt: "theta", $theta$),
          stroke: (paint: gray, thickness: 0.5pt),
          mark: (start: "stealth", fill: gray, scale: 0.7),
          label-radius: 0.75),
      )),
    )
})
]

= Evidence

#m.slide(variant: "header-body", columns: 2)[
  == What makes a technical slide?
][
  *Include*
  - a question or claim
  - units and definitions
  - reproducible computation
  - a stated interpretation
][
  *Avoid*
  - unlabelled decorative plots
  - numbers copied by hand
  - animation without exposition
  - citations disconnected from claims
]

// One-off closing slide: the theme's inverted canvas, one large phrase.
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide(invert: true, cells: (
    body: text(size: 1.6em, weight: "medium")[Questions?],
  ))
]

// A real `==` heading in the header block keeps the same heading show rules
// (and therefore the same size) as the automatic slide headers.
#m.slide(
  "content",
  numbered: false,
  cells: (
    header: [== References],
    body: [
      #set text(size: 0.63em)
      #bibliography("references.bib", title: none, style: "ieee")
    ],
  ),
)
