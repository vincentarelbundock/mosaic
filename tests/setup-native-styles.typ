#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(
  spacing: (inset: 5pt),
)
#set text(size: 8pt)
#show heading.where(depth: 2): set text(
  size: 14pt,
  weight: "bold",
  fill: red,
)
#show figure.caption: set text(size: 6pt, fill: blue)

// Ordinary Typst rules remain the final, local override layer.
#show heading.where(level: 2): set text(fill: green)

#mosaic.slide[
  == Native styled heading

  #figure(
    rect(width: 20pt, height: 8pt, fill: gray),
    caption: [Native styled caption],
  )
]

#mosaic.slide[
  - First list item
  - Second list item
]
