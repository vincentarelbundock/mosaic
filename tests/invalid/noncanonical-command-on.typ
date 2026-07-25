#import "@local/mosaic:0.0.1" as mosaic

#let command = mosaic.on("2-", "later")
#command.insert("unknown", true)
#let canvas = mosaic.reduce.with(
  render: commands => commands.join(", "),
  hide: commands => commands,
)

#show: mosaic.setup
#mosaic.slide[
  #canvas(("base", command))
]
