#import "@local/mosaic:0.0.1" as m

#let grid = m.grid.cell("body")
#let numbering = [
  #place(bottom + right)[
    #pad(right: 1.5em, bottom: 0.9em)[
      #text(size: 0.65em, fill: gray)[
        Slide #m.slide-number(total: true)
        · step #m.step-number(total: true)
        · page #m.page-number()
      ]
    ]
  ]
]

#show: m.setup
#set text(size: 22pt)

#m.deck(default-grid: grid, foreground: numbering)
#m.slide(cell-styles: (body: (inset: 1.5em)))[
  == Numbering in the foreground

  #m.reveal[
    - `slide-number()` counts logical slides.
    - `step-number()` counts incremental frames.
    - `page-number()` counts physical pages.
  ]
]
