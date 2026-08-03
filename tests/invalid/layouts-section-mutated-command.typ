#import "@local/mosaic:0.0.1" as mosaic

#let command = mosaic.layouts.section(variant: "plain")
#command.fields.insert("variant", "image-bottom")

#show: mosaic.setup
#mosaic.slide(layout: command)[Body]
