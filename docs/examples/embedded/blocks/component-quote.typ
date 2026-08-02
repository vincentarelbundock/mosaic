#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set page(fill: rgb("#f3f0e9"))

== `components.quote()`

#align(center + horizon)[
  #m.components.quote(
    [#text(size: 1.25em, style: "italic")[
      “A useful slide makes the relationship visible.”
    ]],
    attribution: [Ada Example],
    source: [Field notes],
    style: (inset: 1.3em),
  )
]
