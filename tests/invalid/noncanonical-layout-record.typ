#import "@local/mosaic:0.0.1" as mosaic

#let malformed = mosaic.layouts.title([Title])
#let _ = malformed.remove("suppress-global-logo")

#show: mosaic.setup
#mosaic.slide(grid: malformed)
