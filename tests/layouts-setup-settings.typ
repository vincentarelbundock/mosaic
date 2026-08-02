#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(
  spacing: (inset: 18pt),
)
#set page(fill: rgb("#123456"))
#set text(size: 17pt, fill: rgb("#abcdef"))
#show heading: set text(size: 1.4em, weight: "bold")
#show figure.caption: set text(size: 0.7em)

#mosaic.slide[Setup-driven ordinary slide]
