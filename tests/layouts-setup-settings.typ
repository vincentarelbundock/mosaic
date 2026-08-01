#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(
  colors: (
    canvas: rgb("#123456"),
    text: rgb("#abcdef"),
  ),
  spacing: (inset: 18pt),
)
#set text(size: 17pt)
#show heading: set text(size: 1.4em, weight: "bold")
#show figure.caption: set text(size: 0.7em)

#mosaic.slide[Setup-driven ordinary slide]
