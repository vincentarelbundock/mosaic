// Dark is a palette, not a theme: any theme flips polarity by passing
// `palettes.dark` through `setup(colors: ..)`. This deck runs the
// default light theme under that swap and must come out fully dark, syntax
// highlighting included, which exercises the canvas-luminance branch.
#import "@preview/mosaic:0.0.1" as m

#let authors = (m.layouts.author(
  "Ada Lovelace",
  affiliations: ([Platform Engineering],),
),)

#show: m.setup.with(
  colors: m.palettes.dark,
  title: [SYSTEMS AT SCALE],
  subtitle: [A practical engineering talk],
  authors: authors,
  date: [2026],
  foreground: [
    #place(bottom + left)[
      #m.components.progress(variant: "line", width: 100%, thickness: 3pt)
    ]
  ],
)

#m.slide(layout: m.layouts.title(), foreground: none)

#m.slide(layout: m.layouts.content(variant: "header-body"))[
  REQUEST PIPELINE
][
  #grid(
    columns: (1fr, 1fr),
    gutter: 18pt,
    [
      *Architecture*

      - Edge proxy
      - Stateless API
      - Durable queue
    ],
    raw("def handle(request):\n    return queue.publish(request)", lang: "python", block: true),
  )

  #m.components.callout(title: [Back pressure])[
    Queue depth remains below the alert threshold.
  ]
]

#context assert(counter(page).final().first() == 3)

= OBSERVABILITY
