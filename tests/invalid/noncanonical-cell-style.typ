#import "@local/mosaic:0.0.1" as mosaic

#let grid = mosaic.grids.cell(id: "body")
#grid.style.remove("inset")

#show: mosaic.setup
#mosaic.slide(layout: grid)[Malformed cell]
