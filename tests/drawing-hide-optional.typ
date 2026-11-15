// `steps.drawing` needs `hide:` only when a command is actually hidden. A
// drawing whose commands are removed outside their range, or dimmed, draws
// without one.
#import "@local/mosaic:0.0.3" as m

#show: m.setup

#let canvas = m.steps.drawing.with(render: commands => commands.join(" "))

// Two pages.
#m.slide[
  #canvas(
    "DRAWBASE",
    m.steps.on("2-", before: "removed", "DRAWLATER"),
  )
]

#context assert(counter(page).final().first() == 2)
