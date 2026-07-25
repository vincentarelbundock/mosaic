#import "@local/mosaic:0.0.1" as mosaic

#let malformed = mosaic.templates.title()
#let _ = malformed.remove("suppress-global-logo")

#show: mosaic.setup
#mosaic.slide(grid: malformed)[Rejected noncanonical template record]
