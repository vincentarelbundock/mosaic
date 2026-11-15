#import "@local/mosaic:0.0.3" as mosaic

#let command = metadata(
  mosaic.steps.on("2-", "later").value + (unknown: true),
)
#let canvas = mosaic.steps.drawing.with(
  render: commands => commands.join(", "),
  hide: commands => commands,
)

#show: mosaic.setup
#mosaic.slide[
  #canvas(("base", command))
]
