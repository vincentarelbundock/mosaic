#import "@local/mosaic:0.0.3" as mosaic

// A lone size is not a shorthand on a general split: no child is the one it
// would belong to.
#mosaic.grids.columns(tracks: 40%, "left", "right")
