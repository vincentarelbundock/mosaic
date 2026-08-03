#import "@local/mosaic:0.0.1" as mosaic
#let furniture = [
  #place(bottom + right, dx: -1em, dy: -0.5em)[
    #mosaic.components.progress(variant: "1/1")
  ]
  #place(bottom + left)[
    #mosaic.components.progress(variant: "line", width: 100%, thickness: 3pt)
  ]
]
#show: mosaic.setup.with(
  content: (
    footer: [Mosaic furniture test],
    foreground: furniture,
  ),
)
#mosaic.slide(layout: mosaic.layouts.content(variant: "body-footer"))[First]
#mosaic.slide(layout: mosaic.layouts.content(variant: "body-footer"))[Second]
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "body-footer"),
  content: (foreground: none),
)[No furniture]
