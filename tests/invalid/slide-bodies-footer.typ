#import "@local/mosaic:0.0.3" as mosaic

// The footer is never filled positionally: a third body on a
// header-body-footer layout is an error that points at cells:.
#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body-footer"),
)[Header][Body][Footer]
