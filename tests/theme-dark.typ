#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m

#let expected = (
  "setup", "slide", "note", "pause", "surface",
  "grid", "layouts", "steps", "components",
)
#assert(expected.all(name => name in m))
#assert(("tokens", "code-theme", "base-setup").all(name => name not in m))

#let authors = (m.layouts.author(
  "Ada Lovelace",
  affiliations: ([Platform Engineering],),
),)

#show: m.setup.with(
  title: [SYSTEMS AT SCALE],
  subtitle: [A practical engineering talk],
  authors: authors,
  date: [2026],
  content: (foreground: [
    #place(bottom + left)[
      #m.components.progress(variant: "line", width: 100%, thickness: 3pt)
    ]
  ]),
)

#m.slide(layout: m.layouts.title(), content: (foreground: none))

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
