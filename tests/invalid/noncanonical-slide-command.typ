#import "@local/mosaic:0.0.2" as mosaic

#let command = mosaic.slide()[Body].value
#command.insert("bogus", true)

#show: mosaic.setup
#metadata(command)
