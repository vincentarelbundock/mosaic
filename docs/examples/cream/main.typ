// The reusable look (palette, theme, slide constructors) lives in theme.typ;
// deck-specific helpers live in preamble.typ, which re-exports the theme.
// `*` re-exports Mosaic (`m`) and every helper used below.
#import "preamble.typ": *
#show: theme.apply

// 01 — Cover
#slide(
  grid: m.grid.h(
    m.grid.t(0.62fr, c("cover",content: [])),
    m.grid.t(0.38fr, c("cover-photo",content: photo("image2.jpg"))),
  ),
  foreground: [
    #place(bottom + left, dx: 142pt, dy: -68pt)[
      #align(center)[#text(size: 2.6em, weight: "bold", fill: ink)[CLEAN\ MINIMAL]]
    ]
    #place(bottom + left, dx: 28pt, dy: -50pt)[#line(length: 470pt, stroke: 1pt + ink)]
  ],
  cell-styles: (
    cover: surface(fill: cream, inset: 42pt),
    cover-photo: surface(fill: cream, inset: (top: 28pt, right: 28pt, bottom: 28pt)),
  ),
)

// 02 — Agenda
#slide(
  grid: m.grid.h(
    m.grid.t(0.55fr, c("agenda")),
    m.grid.t(0.45fr, c("agenda-photo",content: photo("image10.png"))),
  ),
  cell-styles: (
    agenda: surface(fill: cream, inset: 42pt),
    agenda-photo: surface(fill: cream),
  ),
)[
  #set text(fill: ink)
  = AGENDA
  #stack(
    dir: ttb,
    spacing: 0pt,
    ..(
      ("1", "INTRODUCTION"),
      ("2", "ABOUT US"),
      ("3", "OUR PROJECTS"),
    ).map(item => block(width: 100%, stroke: (bottom: 0.8pt + ink), inset: (x: 4pt, y: 14pt))[
      #grid(
        columns: (44pt, 1fr),
        align: (left + horizon, left + horizon),
        text(size: 2em, weight: "bold")[#item.first()],
        text(weight: "bold")[#item.last()],
      )
    ]),
  )
]

// 03 — Introduction section
#slide(
  grid: m.grid.h(
    m.grid.t(0.56fr, c("intro")),
    m.grid.t(0.44fr, c("intro-photo",content: photo("image8.jpg"))),
  ),
  foreground: [#frame],
  cell-styles: (
    intro: surface(inset: 70pt, align: left + horizon),
    intro-photo: surface(),
  ),
)[
  = INTRODUCTION
  Elaborate on your topic here.
]

// 04 — Welcome
#slide(
  grid: m.grid.h(
    c("welcome-left"),
    c("welcome-right"),
  ),
  foreground: [#frame],
  cell-styles: (
    welcome-left: surface(inset: 45pt, align: left + horizon),
    welcome-right: surface(inset: 28pt),
  ),
)[
  #m.image(path("assets/image3.jpg"), width: 55%, height: 34%)
  #v(22pt)
  I'm Rain, and I'll be sharing with you my beautiful ideas. Follow me
  at \@reallygreatsite to learn more.
][
  = WELCOME TO\ PRESENTATION
  #v(25pt)
  #photo("image3.jpg")
]

// 05 — Topic
#slide(
  grid: m.grid.h(
    m.grid.t(0.54fr, c("topic-copy")),
    m.grid.t(0.46fr, c("topic-photo",content: photo("image4.png"))),
  ),
  foreground: [#frame],
  cell-styles: (
    topic-copy: surface(inset: 42pt, align: top),
    topic-photo: surface(),
  ),
)[
 = TOPIC
 #v(28pt)
 #lorem
]

// 06 — Four topics
#slide(grid: c("four-topics"), foreground: [#frame],
  cell-styles: (
    four-topics: surface(inset: 34pt),
  ),
)[
  #grid(
    columns: (0.36fr, 0.32fr, 0.32fr),
    rows: (1fr, 1fr),
    gutter: 12pt,
    row-gutter: 12pt,
    grid.cell(rowspan: 2, photo("image13.png")),
    ..range(1, 5).map(n => [
      == Topic #n
      Elaborate on your topic here. Lorem ipsum dolor sit amet,
      consectetur adipiscing elit, sed do eiusmod tempor incididunt.
    ]),
  )
]

// 07 — About us
#slide(
  grid: m.grid.h(
    m.grid.t(0.62fr, c("about")),
    m.grid.t(0.38fr, c("about-photo",content: photo("image1.jpg"))),
  ),
  cell-styles: (
    about: surface(fill: cream, inset: 25pt, align: center + horizon),
    about-photo: surface(fill: cream),
  ),
)[
  #set text(fill: ink)
  #align(center)[
    #circle(radius: 188pt, stroke: 1pt + ink, inset: 45pt)[
      #align(center + horizon)[
        = ABOUT US
        Elaborate on your topic here.
      ]
    ]
  ]
]

// 08 — Topics on cream
#slide(
  grid: m.grid.h(
    m.grid.t(0.67fr, c("cream-topics")),
    m.grid.t(0.33fr, c("cream-photo",content: photo("image7.png"))),
  ),
  cell-styles: (
    cream-topics: surface(fill: cream, inset: 35pt),
    cream-photo: surface(fill: cream, inset: 24pt),
  ),
)[
  #set text(fill: ink)
  #grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),
    gutter: 18pt,
    row-gutter: 18pt,
    ..range(1, 5).map(n => [
      == Topic #n
      Elaborate on your topic here. Lorem ipsum dolor sit amet,
      consectetur adipiscing elit.
    ]),
  )
]

// 09 — Topic one
#slide(
  grid: m.grid.h(
    m.grid.t(0.53fr, m.grid.v(
      c("topic-one-title"),
      c("topic-one-left-copy"),
    )),
    m.grid.t(0.47fr, m.grid.v(
      c("topic-one-copy"),
      c("topic-one-photo",content: photo("image14.png")),
    )),
  ),
  cell-styles: (
    topic-one-title: surface(fill: cream, inset: 38pt, align: center + horizon),
    topic-one-left-copy: surface(fill: cream, inset: 28pt),
    topic-one-copy: surface(fill: cream, inset: 28pt),
    topic-one-photo: surface(fill: cream),
  ),
)[
  #set text(fill: ink)
  = TOPIC 1
][
  #set text(fill: ink)
  #lorem
][
  #set text(fill: ink)
  #lorem
]

// 10 — Topic two
#slide(grid: m.grid.h(
  c("topic-two-photo",content: photo("image20.png")),
  c("topic-two-copy"),
),
  cell-styles: (
    topic-two-photo: surface(fill: cream),
    topic-two-copy: surface(fill: cream, inset: 30pt, align: horizon),
  ),
)[
  #set text(fill: ink)
  = TOPIC 2
  #lorem
]

// 12 — Team
#slide(grid: c("team"),
  cell-styles: (
    team: surface(fill: cream, inset: 18pt),
  ),
)[
  #set text(fill: ink)
  #align(center)[
    = THE TEAM
  ]
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    gutter: 0pt,
    ..(
      ("image31.png", "Jane Doe", "Director"),
      ("image35.png", "Jane Doe", "Marketing"),
      ("image36.png", "John Doe", "Sales"),
      ("image24.png", "Jane Doe", "PR"),
    ).map(person => rect(height: 315pt, stroke: 0.7pt + rgb("#777"), inset: 0pt)[
      #m.image(path("assets/" + person.first()), height: 145pt)
      #pad(x: 10pt, top: 9pt)[
        #align(center)[
          == #person.at(1)
          #person.at(2)
          #v(10pt)
          Elaborate on their expertise here.
        ]
      ]
    ]),
  )
]

// 13 — Picture statement
#slide(
  grid: m.grid.h(
    c("picture-left",content: []),
    m.grid.t(22pt, c("picture-caption")),
    c("picture-right",content: []),
  ),
  background: photo("image26.jpg"),
  cell-styles: (
    picture-left: surface(fill: none),
    picture-caption: surface(fill: cream, align: center + horizon),
    picture-right: surface(fill: none),
  ),
)[
  #rotate(90deg)[
    #box(width: 620pt)[
      #align(center)[#text(fill: ink)[A picture is worth a thousand words]]
    ]
  ]
]

// 14 — Projects section
#slide(
  grid: m.grid.h(
    m.grid.t(0.61fr, c("projects-section")),
    m.grid.t(0.39fr, c("projects-photo",content: photo("image28.jpg"))),
  ),

  cell-styles: (
    projects-section: surface(inset: 25pt, align: center + horizon),
    projects-photo: surface(),
  ),
)[
  #circle(radius: 174pt, stroke: 1pt + white, inset: 55pt)[
    #align(center + horizon)[
      = OUR PROJECTS
    ]
  ]
]

// 15 — Projects list
#slide(grid: m.grid.h(
  m.grid.t(0.64fr, c("projects-list")),
  m.grid.t(0.36fr, c("projects-pattern",content: photo("image34.png"))),
), foreground: [#frame],
  cell-styles: (
    projects-list: surface(inset: 35pt),
    projects-pattern: surface(),
  ),
)[
  #grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),
    gutter: 18pt,
    row-gutter: 18pt,
    ..range(1, 5).map(n => [
      == Project #n
      Elaborate on your topic here. Lorem ipsum dolor sit amet,
      consectetur adipiscing elit, sed do eiusmod tempor.
    ]),
  )
]

// 16 — Market research
#slide(grid: m.grid.h(
  m.grid.t(0.58fr, c("research-photo")),
  m.grid.t(0.42fr, c("research-list")),
), foreground: [#frame],
  cell-styles: (
    research-photo: surface(),
    research-list: surface(inset: 32pt),
  ),
)[
  #photo("image30.png")
  #place(top + left, dx: 35pt, dy: 85pt)[
    = MARKET\ RESEARCH
    Elaborate on your topic here.
  ]
][
  #stack(
    dir: ttb,
    spacing: 12pt,
    ..range(1, 5).map(n => [
      == Statistic #n
      Elaborate on your topic here. Lorem ipsum dolor sit amet.
    ]),
  )
]

// 17 — Donut statistics
#slide(grid: m.grid.h(
  m.grid.t(0.78fr, c("donuts")),
  m.grid.t(0.22fr, c("donut-photo",content: photo("image37.png"))),
), foreground: [#frame],
  cell-styles: (
    donuts: surface(inset: 22pt),
    donut-photo: surface(),
  ),
)[
  #align(center)[
    #v(1em)
    = MARKET RESEARCH
    Elaborate on the featured statistics.
    #v(8pt)
    #let max-radius = 75pt
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 35pt,
      align: bottom,
      ..((28, "28%"), (60, "60%"), (100, "100%")).map(stat => {
        let radius = max-radius * stat.first() / 100
        [
          #box(height: 2 * max-radius)[#align(center + bottom)[
            #circle(radius: radius, fill: white)[
              #align(center + horizon)[#text(size: radius * 0.5, weight: "bold", fill: ink)[#stat.last()]]
            ]
          ]]
          #v(12pt)
          #text(size: 0.6em)[Elaborate here.]
        ]
      }),
    )
  ]
]

// 18 — Gallery image
#slide(grid: m.grid.h(
  m.grid.t(0.34fr, c("gallery-title")),
  m.grid.t(0.66fr, c("gallery-grid")),
), foreground: [#frame],
  cell-styles: (
    gallery-title: surface(inset: 38pt),
    gallery-grid: surface(inset: 0pt),
  ),
)[
  = GALLERY\ IMAGE
  Elaborate on your topic here.
][
  #grid(
    columns: (0.8fr, 1.1fr, 0.9fr),
    rows: (0.7fr, 1.15fr, 0.65fr),
    gutter: 5pt,
    row-gutter: 5pt,
    ..("image32.png", "image20.png", "image21.png", "image17.png", "image23.png",
      "image22.png", "image25.png", "image29.png", "image15.png").map(photo),
  )
]

// 20 — Contact
#slide(grid: m.grid.h(
  m.grid.t(0.46fr, c("contact-photo",content: photo("image47.png"))),
  m.grid.t(0.54fr, c("contact")),
), foreground: [#frame],
  cell-styles: (
    contact-photo: surface(),
    contact: surface(inset: 44pt, align: left + horizon),
  ),
)[
  = CONTACT US
  #v(12pt)
  123 Anywhere St., Any City, ST 12345 \
  123-456-7890 \
  hello\@reallygreatsite.com \
  reallygreatsite.com \
  \@reallygreatsite
]

