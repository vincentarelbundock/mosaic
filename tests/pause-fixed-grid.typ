#import "@preview/mosaic:0.0.1" as m

#show: m.setup

#m.slide(
  layout: m.grids.cell(
    id: "fixed",
    content: [
      FIXED PAUSE FIRST
      #m.steps.pause
      FIXED PAUSE SECOND
    ],
  ),
)

#context assert(counter(page).final().first() == 2)
