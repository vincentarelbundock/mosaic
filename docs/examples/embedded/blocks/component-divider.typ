#import "@local/mosaic:0.0.1" as m

#show: m.setup

== `components.divider()`

#block(width: 85%)[
  #lorem(12)
  #v(0.6em)
  #m.components.divider(label: [Evidence])
  #v(0.6em)
  #lorem(12)
  #v(0.6em)
  #m.components.divider()
  #v(0.6em)
  #lorem(12)
]
