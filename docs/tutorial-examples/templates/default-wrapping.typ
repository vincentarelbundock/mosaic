#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let myslide = m.slide.with(grid: m.templates.default(
  fill: (
    header: rgb("#dbeafe"),
    footer: rgb("#fde68a"),
  ),
  align: (footer: right),
))

#myslide[
  == A long title wraps onto another line while its region expands automatically
][
  #lorem(24)
][
  A longer footer also wraps when needed, grows upward, and preserves its usual
  padding and right alignment.
]
