# Reveal and replace

The timing commands introduced on the [Steps and pauses](steps.md) page apply to lists, grid cells, inline text, equations, and drawing packages alike. Each section below shows one on a real slide. For equations, see [Math](../content/math.md).

## Reveal bullets

Wrap a list in `m.steps.reveal` to show one more item on each step.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup
#set text(size: 22pt)
#let slide = m.slide

#slide("content", variant: "body")[
  == `reveal`: gradual bullet points

  #m.steps.reveal[
    - State the question.
    - Examine the evidence.
    - Present the conclusion.
  ]
]
```

## Reveal cells

Revealed grid cells can start removed, allowing visible cells to use the space until the next panel arrives.

```typ
#import "@preview/mosaic:0.0.2" as m

#let grid = m.grids.columns(
  ..m.steps.reveal(
    before: "removed",
    after: "visible",
    m.grids.cell("first", inset: 1.5em),
    m.grids.cell("second", inset: 1.5em),
    m.grids.cell("third", inset: 1.5em),
  ),
)

#show: m.setup
#set text(size: 22pt)

// Fill each revealed cell through its stable <mosaic-cell-ID> label.
#let fill(id, color) = it => {
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    height: 100%,
    fill: color,
    body,
  )
  it
}
#show: fill("first", blue.lighten(92%))
#show: fill("second", green.lighten(92%))
#show: fill("third", orange.lighten(88%))

#m.slide(layout: grid)[
  *Cell 1*

  Initially fills the row.
][
  *Cell 2*

  Joins on step 2.
][
  *Cell 3*

  Joins on step 3.
]
```

## Reveal text

Use `m.steps.on` for a word, sentence, or other element that appears only at selected steps. Ranges may be integers, open ranges such as `"3-"`, closed ranges such as `"2-4"`, or everything up to a step, such as `"-2"`; `before` and `after` control the surrounding steps.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup
#set text(size: 22pt)
#let slide = m.slide

#slide("content", variant: "body")[
  == `on`: words and sentences

  The estimate is
  #m.steps.on(1, after: "visible")[*preliminary*],
  #m.steps.on(2, before: "dimmed", after: "dimmed")[*under review*],
  and finally
  #m.steps.on("3-")[*confirmed*].

  #m.steps.on("2-4", before: "hidden", after: "removed")[
    This sentence occupies space on steps 2 to 4.
  ]
]
```

## Replace content

Use `m.steps.replace` to revise a word or larger fragment without moving surrounding content; the largest alternative determines the stable slot.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup
#set text(size: 22pt)
#let slide = m.slide

#let card(fill, stroke, word) = block(
  width: 20em,
  inset: 1em,
  radius: 0.4em,
  fill: fill,
  stroke: 0.8pt + stroke,
)[
  #set text(size: 1.25em)
  The evidence is *#word.*
]

#slide("content", variant: "body")[
  == Replace content

  #m.steps.replace(
    align: center + horizon,
    card(rgb("#f7f0dd"), rgb("#d8bd72"), [promising]),
    card(rgb("#e8f1fb"), rgb("#9ab9d8"), [convincing]),
    card(rgb("#e8f5ec"), rgb("#91bea0"), [conclusive]),
  )
]
```

## CeTZ drawings

Draw a figure progressively when you want to explain its geometry in the order it is constructed. Connect `m.steps.drawing` to a CeTZ canvas and preserve hidden bounds so later additions do not shift the drawing.

This example adapts the [Bloch sphere from Scientific Diagrams](https://diagrams.janosh.dev/bloch-sphere).

```typ
#import "@preview/mosaic:0.0.2" as m
#import "@preview/cetz:0.5.2"

#show: m.setup

#let canvas = m.steps.drawing.with(
  render: cetz.canvas,
  hide: cetz.draw.hide.with(bounds: true),
)

#let grid = m.grids.rows(
  m.grids.track(auto, m.grids.cell(
    "title",
    inset: (top: 0.8em, right: 1.5em, bottom: 0.2em, left: 1.5em),
  )),
  m.grids.cell(
    "diagram",
    inset: (top: 0.2em, right: 1em, bottom: 0.8em, left: 1em),
  ),
)

// Center the diagram within its cell through its label.
#show label("mosaic-cell-diagram"): set align(center + horizon)

#m.slide(layout: grid)[
  == Reveal a Bloch sphere
][
  #text(size: 12pt)[
    #canvas(length: 2.2cm, {
      import cetz.draw: circle, content, line

      let rad = 2.5
      let vec-a = (rad / 3, rad / 2)
      let phi-point = (rad / 3, -rad / 5)
      let mark = (end: "stealth", fill: black)

      // Step 1: sphere.
      circle((0, 0), radius: rad)
      circle(
        (0, 0),
        radius: (rad, rad / 3),
        stroke: (dash: "dashed"),
        fill: gray.transparentize(70%),
      )

      // Step 2: coordinate axes.
      (
        m.steps.on("2-", (
          line(
            (0, 0),
            (-rad / 5 * 1.2, -rad / 3 * 1.2),
            mark: mark,
            name: "x1",
          ),
          content("x1.end", math.equation(alt: "x one", $x_1$), anchor: "north"),
          line((0, 0), (1.15 * rad, 0), mark: mark, name: "x2"),
          content("x2.end", math.equation(alt: "x two", $x_2$), anchor: "west"),
          line((0, 0), (0, 1.15 * rad), mark: mark, name: "x3"),
          content("x3.end", math.equation(alt: "x three", $x_3$), anchor: "south"),
        )),
      )

      // Step 3: Bloch vector and projection.
      (
        m.steps.on("3-", (
          line(
            (0, 0),
            vec-a,
            mark: (
              start: "circle",
              end: "circle",
              fill: black,
              scale: 0.5,
              anchor: "center",
            ),
          ),
          content(
            (rel: (0.08, 0.08), to: vec-a),
            math.equation(alt: "vector a", $arrow(a)$),
            anchor: "south-west",
          ),
          line((0, 0), phi-point, style: "dashed"),
          line(phi-point, vec-a, style: "dashed"),
        )),
      )

      // Step 4: angular coordinates.
      (
        m.steps.on("4-", (
          cetz.angle.angle(
            (0, 0),
            (-1, -calc.tan(60deg)),
            (1, -calc.tan(30deg)),
            label: math.equation(alt: "phi", $phi$),
            stroke: (paint: gray, thickness: 0.5pt),
            mark: (end: "stealth", fill: gray, scale: 0.7),
          ),
          cetz.angle.angle(
            (0, 0),
            (1, calc.tan(60deg)),
            (1, calc.tan(90deg)),
            label: math.equation(alt: "theta", $theta$),
            stroke: (paint: gray, thickness: 0.5pt),
            mark: (start: "stealth", fill: gray, scale: 0.7),
            label-radius: 0.75,
          ),
        )),
      )
    })
  ]
]
```

## Fletcher diagrams

Reveal a diagram path gradually when you want the audience to follow one relationship at a time. Connect `m.steps.drawing` to Fletcher, then use ordinary Mosaic timing functions around nodes and edges.

```typ
#import "@preview/mosaic:0.0.2" as m
#import "@preview/fletcher:0.5.8" as fletcher

#show: m.setup

#let colors = (
  rgb("#E69F00"), rgb("#56B4E9"), rgb("#009E73"), rgb("#F0E442"),
  rgb("#0072B2"), rgb("#D55E00"), rgb("#CC79A7"),
)
#let diagram = m.steps.drawing.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

// Center the diagram within its cell through its label.
#show label("mosaic-cell-diagram"): set align(center + horizon)

#m.slide(layout: 
  m.grids.cell("diagram"),
)[
  #diagram(
    node-stroke: 0.1em,
    node-fill: gradient.radial(
      colors.at(1).lighten(75%),
      colors.at(1),
      center: (30%, 20%),
      radius: 80%,
    ),
    spacing: 4em,
    fletcher.edge(
      (-1, 0),
      "r",
      "-|>",
      `open(path)`,
      label-pos: 0,
      label-side: center,
    ),
    fletcher.node((0, 0), `reading`, radius: 2em),
    m.steps.on("2-", (
      fletcher.edge(`read()`, "-|>"),
      fletcher.node((1, 0), `eof`, radius: 2em),
      fletcher.edge(
        (0, 0),
        (0, 0),
        `read()`,
        "--|>",
        bend: 130deg,
      ),
    )),
    m.steps.on("3-", (
      fletcher.edge(`close()`, "-|>"),
      fletcher.node(
        (2, 0),
        `closed`,
        radius: 2em,
        extrude: (-2.5, 0),
      ),
      fletcher.edge(
        (0, 0),
        (2, 0),
        `close()`,
        "-|>",
        bend: -40deg,
      ),
    )),
  )
]
```
