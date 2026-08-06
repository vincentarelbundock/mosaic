#import "@preview/mosaic:0.0.1" as m

#show: m.setup

#let slide-progress = m.slide.with(
  layout: m.layouts.content(variant: "header-body"),
  foreground: [
    #place(bottom + left)[
      #m.components.progress(variant: "line", width: 100%, thickness: 3pt)
    ]
  ],
)

#slide-progress[
  == Frame the question
][
  Begin with the decision the audience needs to make.
]

#slide-progress[
  == Show the evidence
][
  Make the comparison that supports the decision visible.
]

#slide-progress[
  == Land the conclusion
][
  End with the action the evidence supports.
]
