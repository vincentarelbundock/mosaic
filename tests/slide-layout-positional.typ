#import "@local/mosaic:0.0.2" as m
#show: m.setup

// Positional selection and the named spelling are the same slide.
#m.slide("content", variant: "body")[
  = One cell, edge to edge
  Full-bleed body content.
]

#m.slide(layout: "content", variant: "body")[
  Named selection of the same layout.
]

#m.slide("content", variant: "body", columns: 2)[Left half][Right half]
