#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(overflow: "record")

#mosaic.slide[Normal content fits.]

#mosaic.slide[
  #mosaic.steps.reveal[
    #lorem(180)
  ][
    Overflow remains authored at the normal text size.
  ]
]
