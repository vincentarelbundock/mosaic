#import "@local/mosaic:0.0.1" as m

#show: m.setup

#let slide-progress = m.slide.with(
  grid: m.templates.default(
    variant: "header-body",
    progress: "line",
  ),
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
