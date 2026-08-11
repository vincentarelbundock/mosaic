#import "@local/mosaic:0.0.2" as mosaic

#let malformed = mosaic.steps.on(2)[Later].value
#let _ = malformed.remove("after")

#show: mosaic.setup
== Rejected temporal record
#metadata(malformed)