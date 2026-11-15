#import "@local/mosaic:0.0.3" as mosaic

// `variant: "image"` alone meant the left position.
#show: mosaic.setup.with(title: [Title])
#mosaic.slide(
  layout: "title",
  variant: "image",
  image: path("/docs-src/assets/images/title-river.webp"),
)
