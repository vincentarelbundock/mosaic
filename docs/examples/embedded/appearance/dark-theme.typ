#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m

#let authors = (m.layouts.author(
  "Ada Lovelace",
  affiliations: ([Platform Engineering],),
),)

#let furniture = [
  #place(bottom + right, dx: -1.25em, dy: -0.35em)[
    #m.components.progress(variant: "1/1")
  ]
  #place(bottom + left)[
    #m.components.progress(variant: "line", width: 100%, thickness: 3pt)
  ]
]

#show: m.setup.with(
  title: [SYSTEMS AT SCALE],
  subtitle: [A dark theme for technical talks],
  authors: authors,
  base-size: 24pt,
  foreground: furniture,
)

#m.slide(
  layout: m.layouts.title(),
  numbered: false,
  foreground: none,
)

#m.slide(layout: m.layouts.content(
  variant: "header-body",
))[REQUEST PIPELINE][
  #raw(
    "async def handle(request):\n    result = await service.fetch(request.id)\n    return Response(result)",
    block: true,
    lang: "python",
  )

  #m.components.callout(title: [Back pressure])[
    Queue depth remains below the alert threshold.
  ]

  #table(
    columns: (1fr, auto),
    [Metric], [p95],
    [API latency], [48 ms],
    [Cache hit rate], [94%],
  )
]

= OBSERVABILITY
