#import "@local/mosaic:0.0.2" as mosaic
#show: mosaic.setup
#mosaic.slide(
  layout: "image",
  variant: "left",
  image: path("/docs-src/assets/images/dog.webp"),
  tracks: ("wide",),
  cells: (header: [== T], body: [b]),
)
