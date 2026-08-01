#import "@local/mosaic:0.0.1" as mosaic

#let command = mosaic.layouts.image(variant: "left")
#command.fields.insert("tracks", (1fr,))

#show: mosaic.setup
#mosaic.slide(grid: command)[Image][Body]
