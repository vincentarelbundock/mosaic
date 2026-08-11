#import "@local/mosaic:0.0.2" as mosaic

#let malformed = mosaic.layouts.title(title: [Title])
#let _ = malformed.insert("extra", true)

#show: mosaic.setup
#mosaic.slide(layout: malformed)
