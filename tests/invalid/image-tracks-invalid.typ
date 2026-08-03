#import "@local/mosaic:0.0.1" as mosaic
#show: mosaic.setup
#mosaic.slide(
  layout: "image",
  variant: "left",
  image: path("/docs/assets/images/dog.webp"),
  tracks: ("wide",),
  content: (header: [== T], body: [b]),
)
