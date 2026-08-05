#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(
  layouts: (content: mosaic.grids.columns("header", "body")),
)

== Heading in the header region

Body in the one-column body region.
