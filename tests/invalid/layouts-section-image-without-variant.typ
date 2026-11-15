#import "@local/mosaic:0.0.3" as mosaic

// A picture does not select the picture variant by itself: under the default
// theme the section layout is `baseline`, and the message says what to add.
#show: mosaic.setup
#mosaic.slide(
  layout: "section",
  image: path("/docs-src/assets/images/dog.webp"),
)[Section]
