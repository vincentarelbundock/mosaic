// Palette, helpers, and theme live in preamble.typ; `*` re-exports Mosaic (`m`)
// and every helper used below.
#import "preamble.typ": *
#show: deck-theme

// 01 — Cover
#m.slide(
  grid: cell("cover", content: []),
  cell-styles: (cover: surface()),
  background: photo("image4.png"),
  foreground: [
    #place(top + left, dx: 28pt, dy: 26pt)[
      #text(size: 76pt, weight: "bold", fill: white)[PORTFOLIO]
    ]

  ],
)

// 02 — Contents
#m.slide(
  grid: m.grid.h(
    m.grid.t(0.16fr, cell("contents-margin", content: [])),
    m.grid.t(0.64fr, cell("contents-image", content: photo("image13.png"))),
    m.grid.t(0.20fr, cell("contents-edge", content: [])),
  ),
  cell-styles: (
    contents-margin: surface(fill: white),
    contents-image: surface(),
    contents-edge: surface(fill: white),
  ),
  foreground: [
    #place(top + center, dy: -12pt)[
      #text(size: 66pt, weight: "bold")[CONTENTS]
    ]
    #place(top + center, dx: 55pt, dy: 145pt)[
      #stack(
        dir: ttb,
        spacing: 17pt,
        text(size: 14pt, weight: "medium")[Introduction],
        text(size: 14pt, weight: "medium")[About Us],
        text(size: 14pt, weight: "medium")[Projects],
        text(size: 14pt, weight: "medium")[Exhibitions],
      )
    ]
    #place(bottom + center, dy: 17pt)[
      #text(size: 66pt, weight: "bold")[CONTENTS]
    ]
  ],
)

// 03 — Hello
#m.slide(
  grid: m.grid.h(
    m.grid.t(0.48fr, cell("hello-copy")),
    m.grid.t(0.52fr, cell("hello-photo", content: photo("image21.png"))),
  ),
  cell-styles: (
    hello-copy: surface(fill: white, inset: 28pt, align: center + horizon),
    hello-photo: surface(),
  ),
)[
  #black-panel([
    #align(left)[
      #text(size: 31pt, weight: "bold")[HELLO!]
      #v(8pt)
      #text(size: 10pt)[#lorem Lorem ipsum dolor sit amet, consectetur
      adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore.]
    ]
  ], inset: 25pt)
]

// 04 — About us
#m.slide(
  grid: m.grid.v(
    m.grid.t(1.05fr, cell("about-photo")),
    m.grid.t(0.95fr, cell("about-copy")),
  ),
  cell-styles: (
    about-photo: surface(),
    about-copy: surface(fill: white, inset: 24pt),
  ),
)[
  #box(width: 100%, height: 100%)[
    #photo("image10.png")
    #place(left + horizon, dx: 34pt)[
      #text(size: 34pt, weight: "bold", fill: white)[ABOUT US]
    ]
  ]
][
  #grid(
    columns: (1fr, 1fr),
    gutter: 30pt,
    text(size: 12.5pt)[#lorem],
    text(size: 12.5pt)[#lorem],
  )
]

// 05 — Paired portraits
#m.slide(
  grid: m.grid.h(
    m.grid.t(0.72fr, cell("pier", content: photo("image12.png"))),
    m.grid.t(0.72fr, cell("portrait", content: photo("image9.png"))),
    m.grid.t(1.05fr, cell("story")),
  ),
  cell-styles: (
    pier: surface(fill: white, inset: 25pt),
    portrait: surface(fill: gray),
    story: surface(fill: white, inset: 30pt, align: center + horizon),
  ),
)[
  #text(size: 13pt)[#lorem]
]

// 06 — Mission & vision
#m.slide(
  grid: m.grid.h(
    m.grid.t(1.3fr, cell("mission-body")),
    m.grid.t(0.7fr, cell("mission-photo", content: photo("image1.png"))),
  ),
  cell-styles: (
    mission-body: surface(fill: white, inset: 28pt),
    mission-photo: surface(),
  ),
)[
  #set par(leading: 0.3em)
  #text(size: 40pt, weight: "bold")[MISSION\ & VISION]
  #v(26pt)
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    black-panel([
      #text(size: 15pt, weight: "bold")[Mission]
      #v(8pt)
      #text(size: 10.5pt)[#lorem]
    ], inset: 16pt),
    black-panel([
      #text(size: 15pt, weight: "bold")[Vision]
      #v(8pt)
      #text(size: 10.5pt)[#lorem]
    ], inset: 16pt),
  )
]

// 07 — Full-bleed statement
#m.slide(
  grid: cell("statement", content: photo("image19.png")),
  cell-styles: (statement: surface(fill: white, inset: 10pt)),
  foreground: [
    #place(bottom + right, dx: -35pt, dy: -19pt)[
      #black-panel(
        text(size: 16pt, weight: "bold")[A PICTURE IS WORTH A THOUSAND WORDS],
        inset: (x: 28pt, y: 12pt),
      )
    ]
  ],
)

// 08 — Best shots
#m.slide(
  grid: m.grid.h(
    m.grid.t(0.95fr, cell("best-intro")),
    m.grid.t(0.62fr, cell("best-photo", content: photo("image5.png"))),
    m.grid.t(0.9fr, cell("best-list")),
  ),
  cell-styles: (
    best-intro: surface(fill: white, inset: 28pt),
    best-photo: surface(),
    best-list: surface(fill: ink, inset: 22pt, align: center + horizon),
  ),
)[
  #set par(leading: 0.3em)
  #text(size: 39pt, weight: "bold")[OUR BEST\ SHOTS]
  #v(17pt)
  #text(size: 11.5pt)[#lorem]
][
  #set text(fill: white)
  #for n in range(1, 5) [
    #text(size: 12pt, weight: "bold")[Project #n]
    #line(length: 100%, stroke: 0.5pt + rgb("#555555"))
    #text(size: 10pt)[Lorem ipsum dolor sit amet, consectetur adipiscing elit.]
    #v(7pt)
  ]
]

// 09 — Four-image gallery
#m.slide(
  grid: cell("gallery"),
  cell-styles: (gallery: surface(fill: white, inset: 28pt)),
)[
  #grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),
    gutter: 10pt,
    row-gutter: 10pt,
    photo("image2.png"),
    photo("image7.png"),
    photo("image16.png"),
    photo("image11.png"),
  )
]

// 10 — Numbered projects
#m.slide(
  grid: cell("numbered"),
  cell-styles: (numbered: surface(
    fill: ink,
    inset: (x: 105pt, y: 72pt),
    align: center + horizon,
  )),
)[
  #grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),
    gutter: 30pt,
    row-gutter: 30pt,
    project-card([01], [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.]),
    project-card([03], [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.]),
    project-card([02], [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.]),
    project-card([04], [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.]),
  )
]

// 11 — Big number
#m.slide(
  grid: cell("metric", content: []),
  cell-styles: (metric: surface()),
  background: photo("image6.png"),
  foreground: [
    #place(top + center, dy: 132pt)[
      #align(center)[
        #text(size: 88pt, weight: "bold")[123,456]
        #v(-5pt)
        #black-panel(
          text(size: 12pt, weight: "bold")[Big numbers catch your audience’s attention],
          inset: (x: 12pt, y: 5pt),
        )
      ]
    ]
  ],
)

// 12 — Chart
#m.slide(
  grid: m.grid.h(
    m.grid.t(0.85fr, cell("chart-copy")),
    m.grid.t(1.15fr, cell("chart-graphic", content: photo("image8.png", fit: "contain"))),
  ),
  cell-styles: (
    chart-copy: surface(fill: ink, inset: 27pt),
    chart-graphic: surface(fill: white, inset: 18pt),
  ),
)[
  #set text(fill: white)
  #text(size: 31pt, weight: "bold")[CHART]
  #v(8pt)
  #text(size: 11pt)[#lorem #lorem]
]

// 13 — Exhibitions
#m.slide(
  grid: m.grid.v(
    m.grid.t(0.28fr, cell("exhibitions-title")),
    m.grid.t(1fr, m.grid.h(
      cell("exhibition-1"),
      cell("exhibition-2"),
      cell("exhibition-3"),
      gutter: 7pt,
    )),
  ),
  cell-styles: (
    exhibitions-title: surface(
      fill: ink,
      inset: (x: 34pt, y: 18pt),
      align: center + horizon,
    ),
    exhibition-1: surface(fill: ink, inset: 14pt),
    exhibition-2: surface(fill: ink, inset: 14pt),
    exhibition-3: surface(fill: ink, inset: 14pt),
  ),
)[
  #text(size: 31pt, weight: "bold", fill: white)[EXHIBITIONS]
][
  #block(fill: white, width: 100%, height: 100%, inset: 0pt)[
    #m.image(path("assets/image18.png"), height: 71%)
    #pad(x: 11pt, top: 7pt)[
      #text(size: 12pt, weight: "bold")[Project 1]
      #linebreak()
      #text(size: 8.5pt)[Lorem ipsum dolor sit amet, consectetur adipiscing elit.]
    ]
  ]
][
  #block(fill: white, width: 100%, height: 100%, inset: 0pt)[
    #m.image(path("assets/image17.png"), height: 71%)
    #pad(x: 11pt, top: 7pt)[
      #text(size: 12pt, weight: "bold")[Project 2]
      #linebreak()
      #text(size: 8.5pt)[Lorem ipsum dolor sit amet, consectetur adipiscing elit.]
    ]
  ]
][
  #block(fill: white, width: 100%, height: 100%, inset: 0pt)[
    #m.image(path("assets/image3.png"), height: 71%)
    #pad(x: 11pt, top: 7pt)[
      #text(size: 12pt, weight: "bold")[Project 3]
      #linebreak()
      #text(size: 8.5pt)[Lorem ipsum dolor sit amet, consectetur adipiscing elit.]
    ]
  ]
]

// 14 — Closing
#m.slide(
  grid: m.grid.h(
    m.grid.t(0.42fr, cell("thanks")),
    m.grid.t(0.58fr, cell(
      "closing-photo",
      content: photo("image20.png"),
    )),
  ),
  cell-styles: (
    thanks: surface(fill: ink, inset: 32pt),
    closing-photo: surface(
      fill: ink,
      inset: (top: 175pt, right: 0pt, bottom: 0pt, left: 0pt),
    ),
  ),
)[
  #set par(leading: 0.35em)
  #text(size: 64pt, weight: "bold", fill: white)[THANK\ YOU]
]
