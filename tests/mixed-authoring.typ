#import "@local/mosaic:0.0.2" as mosaic

#show: mosaic.setup.with(
  spacing: (inset: 5pt),
)
#set text(size: 7pt, fill: luma(20%))
#show heading.where(level: 2): set text(weight: "bold")

== Automatic one

The first slide comes from a heading.

#mosaic.slide(layout: mosaic.grids.columns("a", "b"))[Explicit left][Explicit right]

== Automatic two

The final slide returns to headings.

#context assert(counter(page).final().first() == 3)
