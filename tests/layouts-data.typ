#import "@local/mosaic:0.0.1" as mosaic
#show: mosaic.setup
#let native-table = table(columns: 2, [Group], [Value], [A], [42], [B], [57])
#let contained-sample = image("/docs/assets/images/dog.webp", alt: "Dog", fit: "contain")

#mosaic.slide(grid: mosaic.layouts.image(
  variant: "full",
  path: path("/docs/assets/images/bonsai.webp"),
  alt: "Bonsai tree",
))
#mosaic.slide(grid: mosaic.layouts.image(variant: "figure"))[#contained-sample]
#mosaic.slide(grid: mosaic.layouts.image(
  variant: "left",
  path: path("/docs/assets/images/bonsai.webp"),
  alt: "Bonsai tree",
  tracks: (2fr, 1fr),
))[
  Interpretation
]
#mosaic.slide(grid: mosaic.layouts.image(
  variant: "right",
  path: path("/docs/assets/images/bonsai.webp"),
  alt: "Bonsai tree",
  tracks: (1fr, 2fr),
))[
  Interpretation
]

#mosaic.slide(grid: mosaic.layouts.table(title: [Titled table]))[#native-table]
#mosaic.slide(grid: mosaic.layouts.table(caption: [Compact source data]))[#native-table]
#mosaic.slide(grid: mosaic.layouts.table(title: [Highlighted], highlight: [Group B]))[#native-table]
#mosaic.slide(grid: mosaic.layouts.table(title: [Sourced table], source: [Illustrative]))[#native-table]
