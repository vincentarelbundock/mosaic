// A component dimmed by a step mutes its own paint along with its text.
// Dimming is ink, which reaches text and nothing a component paints, so the
// walk that redraws a component under a dimmed state tells it so, and a
// component nested in it inherits the state. Only a step does this: gray text
// around a component leaves its paint alone. scripts/run-tests.py looks for
// the loud colors in the SVG of each page.
#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(overflow: "off")

#let loud = (fill: rgb("#00ff11"), accent: rgb("#ff0011"))
#let nested = (fill: rgb("#1100ff"), accent: rgb("#ff00ee"))

// Two pages: dimmed, then lit.
#m.slide[
  #m.steps.on(2, before: "dimmed")[
    #m.components.card(..loud)[
      DIMMED CARD
      #m.components.badge(..nested)[NESTED BADGE]
    ]
    #m.components.callout(..loud, title: [Title])[DIMMED CALLOUT]
    #m.components.quote(..loud)[DIMMED QUOTE]
    #m.components.badge(..loud)[DIMMED BADGE]
    #m.components.divider(stroke: 2pt + loud.accent)
    #m.components.progress(variant: "line", ..loud)
  ]
]

// One page: the dim ink written by hand is text color and nothing else.
#m.slide[
  #text(fill: gray)[
    #m.components.card(..loud)[GRAY TEXT, LIT CARD]
  ]
]

// Two pages: a revealed item dimmed once the build moves on.
#m.slide[
  #m.steps.reveal(after: "dimmed")[
    - #m.components.badge(..loud)[FIRST ITEM]
    - Second item
  ]
]

#context assert(counter(page).final().first() == 5)
