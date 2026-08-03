#import "@local/mosaic:0.0.1" as m

#let grid = m.grid.cell("body", inset: 1.5em)

#show: m.setup
#set text(size: 22pt)

#m.slide(layout: 
  grid,
  content: (background: [
    #place(center)[
      #circle(width: 410pt, fill: blue.lighten(88%), stroke: none)
    ]
  ]),
)[
  == Full-slide backgrounds

  The circle is behind the grid.
]
