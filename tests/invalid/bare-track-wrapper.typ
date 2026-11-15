#import "@local/mosaic:0.0.3" as mosaic

// `grids.track` is gone: `columns` and `rows` size their children through
// `tracks:`. The name remains only to say so.
#show: mosaic.setup
#mosaic.slide(
  layout: mosaic.grids.rows(mosaic.grids.track(auto, "header"), "body"),
)[Removed track wrapper]
