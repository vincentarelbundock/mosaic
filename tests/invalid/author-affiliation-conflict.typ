#import "@local/mosaic:0.0.1" as mosaic

#let first = (id: "lab", name: [First Lab])
#let second = (id: "lab", name: [Second Lab])
#mosaic.layouts.title(
  [Title],
  variant: "academic",
  authors: (
    mosaic.layouts.author([Ada], affiliations: (first,)),
    mosaic.layouts.author([Grace], affiliations: (second,)),
  ),
)
