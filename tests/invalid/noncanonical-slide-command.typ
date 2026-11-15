#import "@local/mosaic:0.0.3" as mosaic

#let command = mosaic.slide()[Body].children.first().value
#command.insert("bogus", true)

#show: mosaic.setup
#metadata(command)
