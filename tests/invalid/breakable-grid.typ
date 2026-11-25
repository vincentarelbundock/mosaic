#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup

#mosaic.slide(
  mosaic.grids.columns("left", "right"),
  breakable: true,
)[Left][Right]
