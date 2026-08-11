#import "@local/mosaic:0.0.2" as mosaic

#let command = mosaic.steps.on("2-", "later")
#command.insert("unknown", true)
#let canvas = mosaic.steps.drawing.with(
  render: commands => commands.join(", "),
  hide: commands => commands,
)

#show: mosaic.setup
#mosaic.slide[
  #canvas(("base", command))
]
