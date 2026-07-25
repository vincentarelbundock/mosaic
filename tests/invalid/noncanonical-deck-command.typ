#import "@local/mosaic:0.0.1" as mosaic

#let malformed = mosaic.deck().value
#let _ = malformed.remove("foreground")

#show: mosaic.setup
#metadata(malformed)
== Unreachable slide