#import "@preview/mosaic:0.0.1" as m

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
