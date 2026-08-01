#import "@local/mosaic:0.0.1" as mosaic
#show: mosaic.setup.with(features: (
  slide-number: true,
  slide-total: true,
  progress: true,
  footer: [Mosaic feature test],
))
#mosaic.slide(grid: mosaic.layouts.default(variant: "body"))[First]
#mosaic.slide(grid: mosaic.layouts.default(variant: "body"))[Second]
