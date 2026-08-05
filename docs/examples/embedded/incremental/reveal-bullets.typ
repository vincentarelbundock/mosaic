#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(layouts: (content: m.grids.cell("body", inset: 1.5em)))
#set text(size: 22pt)
#let slide = m.slide

#slide[
  == `reveal`: gradual bullet points

  #m.steps.reveal[
    - State the question.
    - Examine the evidence.
    - Present the conclusion.
  ]
]
