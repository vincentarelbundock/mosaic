// A dimmed component mutes its own paint along with its text. `steps.on(..,
// before: "dimmed")` can only set the ink, which reaches text and nothing a
// component paints, so each component reads that ink and mutes its fill,
// border, and rail to match. scripts/run-tests.py looks for the loud colors in
// the SVG of each frame: absent from the dimmed one, present in the lit one.
#import "@local/mosaic:0.0.3" as m

#show: m.setup

#let loud = (fill: rgb("#00ff11"), accent: rgb("#ff0011"))

#m.slide[
  #m.steps.on(2, before: "dimmed")[
    #m.components.card(..loud)[DIMMED CARD]
    #m.components.callout(..loud, title: [Title])[DIMMED CALLOUT]
    #m.components.quote(..loud)[DIMMED QUOTE]
    #m.components.badge(..loud)[DIMMED BADGE]
    #m.components.divider(stroke: 2pt + loud.accent)
    #m.components.progress(variant: "line", ..loud)
  ]
]

#context assert(counter(page).final().first() == 2)
