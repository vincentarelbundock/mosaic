#import "@local/mosaic:0.0.3" as mosaic
#show: mosaic.setup
#mosaic.slide(
  layout: "image",
  position: "left",
  image: path("/docs-src/assets/images/dog.webp"),
  tracks: ("wide",),
  cells: (header: [== T], body: [b]),
)
