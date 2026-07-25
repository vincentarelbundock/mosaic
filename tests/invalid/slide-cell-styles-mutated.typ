#import "@local/mosaic:0.0.1" as mosaic

#let command = mosaic.slide(cell-styles: (body: (fill: red)))[Body]
#let value = command.value
#let styles = value.cell-styles
#styles.body.insert("content-sized", true)
#value.insert("cell-styles", styles)
#let mutated = metadata(value)

#show: mosaic.setup
#mutated