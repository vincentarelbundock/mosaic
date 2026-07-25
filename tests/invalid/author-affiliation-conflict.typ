#import "@local/mosaic:0.0.1" as mosaic

#let first = (id: "lab", name: [First Lab])
#let second = (id: "lab", name: [Second Lab])
#mosaic.templates.title(
  variant: "academic",
  authors: (
    mosaic.author([Ada], affiliations: (first,)),
    mosaic.author([Grace], affiliations: (second,)),
  ),
)
