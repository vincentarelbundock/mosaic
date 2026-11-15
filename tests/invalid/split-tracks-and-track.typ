#import "@local/mosaic:0.0.3" as mosaic

// A split is sized one way: by `tracks:` on the split, or by `track` wrappers
// around its children. Both at once would give a child two sizes.
#mosaic.grids.rows(
  tracks: (auto, 1fr),
  mosaic.grids.track(auto, "header"),
  "body",
)
