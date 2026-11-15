#import "@local/mosaic:0.0.3" as mosaic

#let command = mosaic.layouts.title(title: [Title], variant: "centered")
#command.fields.insert("variant", "image-left")

#show: mosaic.setup
#mosaic.slide(layout: command)
