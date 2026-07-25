#import "@local/mosaic:0.0.1" as mosaic

#let grid = mosaic.grid.cell(id: "body")
#grid.style.remove("inset")

#show: mosaic.setup
#mosaic.slide(grid: grid)[Malformed cell]
