#import "@preview/mosaic:0.0.1" as mosaic

#let malformed = mosaic.grids.cell(id: "body")
#let _ = malformed.remove("id")

#show: mosaic.setup
#mosaic.slide(layout: malformed)[Rejected noncanonical cell record]
