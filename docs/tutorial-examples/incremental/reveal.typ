#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#m.deck(default-grid: m.grid.cell("body"))
#let slide = m.slide.with(cell-styles: (body: (inset: 1.5em)))

#slide[
  == `reveal`: gradual bullet points

  #m.reveal[
    - State the question.
    - Examine the evidence.
    - Present the conclusion.
  ]
]
