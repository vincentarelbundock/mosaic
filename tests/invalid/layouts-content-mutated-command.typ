#import "@local/mosaic:0.0.2" as mosaic

#let command = mosaic.layouts.content(columns: 2)
#command.fields.insert("columns", 0)

#show: mosaic.setup
#mosaic.slide(layout: command)[Body]
