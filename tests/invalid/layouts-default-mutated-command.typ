#import "@local/mosaic:0.0.1" as mosaic

#let command = mosaic.layouts.default(columns: 2)
#command.fields.insert("columns", 0)

#show: mosaic.setup
#mosaic.slide(grid: command)[Body]
