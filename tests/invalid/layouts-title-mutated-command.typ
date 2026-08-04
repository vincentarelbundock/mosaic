#import "@local/mosaic:0.0.1" as mosaic

#let command = mosaic.layouts.title(title: [Title], variant: "swiss")
#command.fields.insert("variant", "image-right")

#show: mosaic.setup
#mosaic.slide(layout: command)
