#import "@local/mosaic:0.0.1" as mosaic

#let command = mosaic.templates.title(variant: "left-aligned")
#command.fields.insert("variant", "image-right")

#show: mosaic.setup
#mosaic.slide(grid: command)[Title]
