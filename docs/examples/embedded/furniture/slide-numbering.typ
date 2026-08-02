#import "@local/mosaic:0.0.1" as m

#let grid = m.grid.cell("body", inset: 1.5em)

#show: m.setup.with(
  default-grid: grid,
  features: (
    slide-number: true,
    slide-total: true,
    progress: true,
  ),
)
#set text(size: 22pt)
#m.slide[
  == Built-in numbering and progress

  #m.steps.reveal[
    - The logical slide number remains stable across frames.
    - The progress indicator advances between logical slides.
  ]
]
