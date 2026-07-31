// Palette, helpers, and theme live in preamble.typ; `*` re-exports Mosaic (`m`)
// and every helper used below.
#import "preamble.typ": *
#show: deck-theme

// 01 — Cover
#m.slide(
  grid: c("cover"),
  foreground: [
    #place(bottom + left, dx: 45pt, dy: -45pt)[
      #line(length: 752pt, stroke: 1pt + red)
    ]
  ],
  cell-styles: (
    cover: surface(inset: 45pt, align: left + horizon),
  ),
)[
  #title([Minimalist White\ Presentation.], size: 2.79em)
]

// 02 — Intro sentence
#slide(grid: c("intro-line"),
  cell-styles: (
    intro-line: surface(align: center + horizon),
  ),
)[
  #title([Write a short introduction here.], size: 1.79em)
]

// 03 — Contents
#slide(grid: c("contents"),
  cell-styles: (
    contents: surface(inset: (left: 48pt), align: left + horizon),
  ),
)[
  #set enum(numbering: "1.", indent: 0pt, body-indent: 10pt)
  #text(size: 1.79em, weight: "bold")[
    + Introduction
    + About Us
    + Our Projects
    + Chapter Title
    + Chapter Title
  ]
]

// 04 — Section
#slide(grid: c("introduction"),
  cell-styles: (
    introduction: surface(fill: red, inset: 48pt, align: left + horizon),
  ),
)[
  #text(size: 2.79em, weight: "bold", fill: cream)[Introduction.]
]

// 05 — Welcome
#slide(grid: m.grid.h(
  m.grid.t(1fr, c("welcome-copy")),
  m.grid.t(0.72fr, c("welcome-photo")),
),
  cell-styles: (
    welcome-copy: surface(inset: (left: 48pt, right: 24pt), align: left + horizon),
    welcome-photo: surface(inset: (top: 44pt, right: 48pt, bottom: 38pt)),
  ),
)[
  #title([Welcome to\ Presentation], size: 2.07em)
  #v(10pt)
  #body-text([I'm Rain, and I'll be sharing with you my beautiful ideas.
  Follow me at \@reallygreatsite to learn more. #copy], size: 0.9em)
][
  #rect(width: 100%, height: 100%, stroke: 1.5pt + red, inset: 0pt)[
    #photo("image21.png")
  ]
]

// 06 — Three questions
#slide(grid: m.grid.h(
  rule: 0.8pt + red,
  gutter: 0.04fr,
  m.grid.t(0.95fr, c("vision")),
  m.grid.t(1fr, c("questions")),
),
  cell-styles: (
    vision: surface(inset: 48pt, align: left + horizon),
    questions: surface(inset: (left: 28pt, right: 45pt), align: left + horizon),
  ),
)[
  #set par(leading: 0.2em)
  #title([Our company was\ created with the\ vision to be the best\ in the industry.], size: 1.93em)
][
  #stack(
    dir: ttb,
    spacing: 22pt,
    [#title([Who we are?], size: 1.14em)#linebreak()#body-text([Introduce the people behind the work.], size: 0.85em)],
    [#title([What we do?], size: 1.14em)#linebreak()#body-text([Describe the value your company creates.], size: 0.85em)],
    [#title([Why we do it?], size: 1.14em)#linebreak()#body-text([Explain the purpose that guides the team.], size: 0.85em)],
  )
]

// 07 — Section
#slide(grid: c("about"),
  cell-styles: (
    about: surface(fill: red, inset: 48pt, align: left + horizon),
  ),
)[
  #text(size: 2.79em, weight: "bold", fill: cream)[About Us.]
]

// 08 — Our history
#slide(grid: m.grid.h(
  m.grid.t(1fr, c("history-images")),
  m.grid.t(1fr, c("history-copy")),
),
  cell-styles: (
    history-images: surface(inset: (top: 48pt, left: 48pt, bottom: 42pt)),
    history-copy: surface(inset: (left: 28pt, right: 45pt), align: left + horizon),
  ),
)[
  #grid(
    columns: (1fr),
    rows: (1fr, 1fr),
    gutter: 10pt,
    photo("image7.png"),
    photo("image27.png"),
  )
][
  #title([Our History], size: 2.14em)
  #v(10pt)
  #body-text([#copy], size: 0.9em)
]

// 09 — Mission and vision
#slide(grid: m.grid.h(
  c("mission"),
  c("vision"),
),
  cell-styles: (
    mission: surface(inset: 45pt, align: left + horizon),
    vision: surface(fill: red, inset: 45pt, align: left + horizon),
  ),
)[
  #align(center)[#title([Mission], size: 2.07em)]
  #v(14pt)
  #body-text([#copy], size: 0.9em)
][
  #align(center)[#text(size: 2.07em, weight: "bold", fill: cream)[Vision]]
  #v(14pt)
  #text(size: 0.9em, fill: cream)[#copy]
]

// 10 — Team
#slide(grid: m.grid.h(
  rule: 0.8pt + red,
  gutter: 0.05fr,
  m.grid.t(0.98fr, c("team-title")),
  m.grid.t(0.97fr, c("team-list")),
),
  cell-styles: (
    team-title: surface(inset: 48pt, align: left + horizon),
    team-list: surface(inset: (left: 24pt, right: 48pt), align: left + horizon),
  ),
)[
  #title([Meet the Team], size: 2.07em)
][
  #grid(
    columns: (72pt, 1fr),
    rows: (72pt, 72pt, 72pt),
    gutter: 14pt,
    row-gutter: 14pt,
    photo("image12.png"),
    [#title([John Doe], size: 1.07em)#linebreak()#body-text([position], size: 0.8em)],
    photo("image15.png"),
    [#title([Jane Doe], size: 1.07em)#linebreak()#body-text([position], size: 0.8em)],
    photo("image2.png"),
    [#title([John Doe], size: 1.07em)#linebreak()#body-text([position], size: 0.8em)],
  )
]

// 11 — Section
#slide(grid: c("projects"),
  cell-styles: (
    projects: surface(fill: red, inset: 48pt, align: left + horizon),
  ),
)[
  #text(size: 2.79em, weight: "bold", fill: cream)[Our Projects.]
]

// 12 — Products
#slide(grid: m.grid.h(
  c("products-title"),
  c("products-list"),
),
  cell-styles: (
    products-title: surface(inset: 48pt, align: left + horizon),
    products-list: surface(inset: (left: 30pt, right: 48pt), align: left + horizon),
  ),
)[
  #title([Our Products], size: 2.07em)
][
  #stack(
    dir: ttb,
    spacing: 24pt,
    ..range(1, 5).map(n => [
      #title([Project #("One", "Two", "Three", "Four").at(n - 1)], size: 1.07em)
      #linebreak()
      #body-text([Elaborate on what you want to discuss.], size: 0.85em)
    ]),
  )
]

// 13 — Project one
#slide(grid: m.grid.h(
  rule: 0.8pt + red,
  gutter: 0.05fr,
  m.grid.t(0.95fr, c("project-one-title")),
  m.grid.t(1fr, c("project-one-gallery")),
),
  cell-styles: (
    project-one-title: surface(inset: 48pt, align: left + horizon),
    project-one-gallery: surface(inset: (top: 48pt, right: 48pt, bottom: 42pt)),
  ),
)[
  #title([Project One turns\ a focused idea into\ a clear, useful result.], size: 1.93em)
][
  #grid(
    columns: (1fr, 1fr),
    rows: (1fr, 0.55fr),
    gutter: 8pt,
    row-gutter: 8pt,
    grid.cell(colspan: 2, photo("image18.png")),
    photo("image54.png"),
    photo("image4.png"),
  )
]

// 14 — Project two
#slide(grid: m.grid.h(
  c("project-two-photo"),
  c("project-two-copy"),
),
  cell-styles: (
    project-two-photo: surface(inset: (top: 48pt, left: 48pt, bottom: 42pt)),
    project-two-copy: surface(inset: (left: 30pt, right: 48pt), align: left + horizon),
  ),
)[
  #rect(width: 100%, height: 100%, stroke: 1.5pt + red, inset: 0pt)[#photo("image41.png")]
][
  #title([Project Two], size: 2.07em)
  #v(10pt)
  #body-text([#copy], size: 0.9em)
]

// 15 — Image mosaic
#slide(grid: c("mosaic"),
  cell-styles: (
    mosaic: surface(inset: (top: 48pt, left: 48pt, right: 48pt, bottom: 42pt)),
  ),
)[
  #grid(
    columns: (1.05fr, 0.85fr, 0.85fr),
    rows: (1fr, 1fr),
    gutter: 8pt,
    row-gutter: 8pt,
    photo("image57.png"),
    photo("image5.png"),
    photo("image3.png"),
    photo("image9.png"),
    photo("image10.png"),
    photo("image6.png"),
  )
]

// 16 — Market research statistics
#slide(grid: m.grid.h(
  rule: 0.8pt + red,
  gutter: 0.04fr,
  m.grid.t(1.05fr, c("research-copy")),
  m.grid.t(0.91fr, c("research-stats")),
),
  cell-styles: (
    research-copy: surface(inset: 48pt, align: left + horizon),
    research-stats: surface(inset: 44pt, align: left + horizon),
  ),
)[
  #title([Market Research], size: 2.07em)
  #v(10pt)
  #body-text([#copy], size: 0.9em)
][
  #stack(
    dir: ttb,
    spacing: 26pt,
    ..(
      ([+88%], [Elaborate on the statistic here.]),
      ([+400k], [Elaborate on the statistic here.]),
      ([-12%], [Elaborate on the statistic here.]),
    ).map(pair => [
      #title(pair.first(), size: 1.79em)#linebreak()
      #body-text(pair.last(), size: 0.85em)
    ]),
  )
]

// 17 — Line chart
#slide(grid: c("chart"),
  cell-styles: (
    chart: surface(inset: (top: 42pt, left: 48pt, right: 48pt, bottom: 34pt)),
  ),
)[
  #title([Market Research], size: 2.07em)
  #linebreak()
  #body-text([#copy], size: 0.9em)
  #v(12pt)
  #m.image(path("assets/image1.png"), width: 100%, height: 52%, fit: "contain")
]

// 18 — Quote
#slide(grid: c("quote"),
  cell-styles: (
    quote: surface(align: center + horizon),
  ),
)[
  #align(center)[
    #title([“], size: 2.71em)
    #v(-8pt)
    #title([Write an original statement or\ inspiring quote.], size: 1.86em)
    #v(9pt)
    #body-text([— Include a credit, citation, or supporting message], size: 0.85em)
  ]
]

// 19 — Contact
#slide(grid: c("contact"),
  cell-styles: (
    contact: surface(inset: 48pt, align: left + horizon),
  ),
)[
  #title([Contact Us], size: 2.07em)
  #v(15pt)
  #body-text([
    123 Anywhere St., Any City, ST 12345 \
    123-456-7890 \
    hello\@reallygreatsite.com \
    reallygreatsite.com \
    \@reallygreatsite
  ], size: 0.9em)
]
