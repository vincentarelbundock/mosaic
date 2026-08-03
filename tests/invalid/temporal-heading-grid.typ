#import "@local/mosaic:0.0.1" as mosaic

#let delayed = mosaic.steps.on("2-", mosaic.grid.cell(id: "body"))

#show: mosaic.setup

#mosaic.slide(layout: delayed)[
  == A heading cannot be in a delayed cell
]
