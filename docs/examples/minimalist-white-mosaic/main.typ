#import "@local/mosaic:0.0.1" as m

#let cream = rgb("#fffcf9")
#let red = rgb("#c83224")
#let serif = "Source Serif 4"

#let copy = [Presentations are communication tools that can be used as
demonstrations, lectures, speeches, reports, and more. It is mostly presented
before an audience. It serves a variety of purposes, making presentations
powerful tools for convincing and teaching. Lorem ipsum dolor sit amet,
consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
dolore magna aliqua.]

#let photo(name, fit: "cover") = m.image(path("assets/" + name), fit: fit)

#let c = m.grid.cell
#let surface(..overrides) = (
  (fill: cream, inset: 0pt, align: top + left) + overrides.named()
)


// Font and fill are set once via `#set text(font: serif, fill: red)` below;
// these helpers inherit both and only vary size (and weight for titles).
#let title(body, size: 31pt) = text(size: size, weight: "bold", body)

#let body-text(body, size: 10pt) = text(size: size, body)

#let slide = m.slide
#show: m.setup.with(
  colors: (
    canvas: cream,
    surface: cream,
    accent: red,
    text: red,
    inverse-text: cream,
    muted: red,
    line: red,
  ),
  spacing: (inset: 0pt),
)
#set text(font: serif, fill: red)

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
  #title([Minimalist White\ Presentation.], size: 39pt)
]

// 02 — Intro sentence
#slide(grid: c("intro-line"),
  cell-styles: (
    intro-line: surface(align: center + horizon),
  ),
)[
  #title([Write a short introduction here.], size: 25pt)
]

// 03 — Contents
#slide(grid: c("contents"),
  cell-styles: (
    contents: surface(inset: (left: 48pt), align: left + horizon),
  ),
)[
  #set enum(numbering: "1.", indent: 0pt, body-indent: 10pt, spacing: 5pt)
  #text(size: 25pt, weight: "bold")[
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
  #text(size: 39pt, weight: "bold", fill: cream)[Introduction.]
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
  #title([Welcome to\ Presentation], size: 29pt)
  #v(10pt)
  #body-text([I'm Rain, and I'll be sharing with you my beautiful ideas.
  Follow me at \@reallygreatsite to learn more. #copy], size: 8.5pt)
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
  #title([Our company was\ created with the\ vision to be the best\ in the industry.], size: 27pt)
][
  #stack(
    dir: ttb,
    spacing: 22pt,
    [#title([Who we are?], size: 16pt)#linebreak()#body-text([Elaborate on your topic here. #copy], size: 7.5pt)],
    [#title([What we do?], size: 16pt)#linebreak()#body-text([Elaborate on your topic here. #copy], size: 7.5pt)],
    [#title([Why we do?], size: 16pt)#linebreak()#body-text([Elaborate on your topic here. #copy], size: 7.5pt)],
  )
]

// 07 — Section
#slide(grid: c("about"),
  cell-styles: (
    about: surface(fill: red, inset: 48pt, align: left + horizon),
  ),
)[
  #text(size: 39pt, weight: "bold", fill: cream)[About Us.]
]

// 08 — Our history
#slide(grid: m.grid.h(
  m.grid.t(1fr, c("history-images")),
  m.grid.t(1fr, c("history-copy")),
),
  cell-styles: (
    history-images: surface(inset: (top: 48pt, left: 48pt, bottom: 42pt)),
    history-copy: surface(inset: (left: 28pt, right: 45pt), align: right + horizon),
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
  #title([Our History], size: 30pt)
  #v(10pt)
  #body-text([#copy #copy], size: 8pt)
]

// 09 — Mission and vision
#slide(grid: m.grid.h(
  c("mission"),
  c("vision"),
),
  cell-styles: (
    mission: surface(inset: 45pt, align: center + horizon),
    vision: surface(fill: red, inset: 45pt, align: center + horizon),
  ),
)[
  #align(center)[#title([Mission], size: 29pt)]
  #v(14pt)
  #body-text([#copy #copy], size: 8pt)
][
  #align(center)[#text(size: 29pt, weight: "bold", fill: cream)[Vision]]
  #v(14pt)
  #text(size: 8pt, fill: cream)[#copy #copy]
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
  #title([Meet the Team], size: 29pt)
][
  #grid(
    columns: (72pt, 1fr),
    rows: (72pt, 72pt, 72pt),
    gutter: 14pt,
    row-gutter: 14pt,
    photo("image12.png"),
    [#title([John Doe], size: 15pt)#linebreak()#body-text([position], size: 8pt)],
    photo("image15.png"),
    [#title([Jane Doe], size: 15pt)#linebreak()#body-text([position], size: 8pt)],
    photo("image2.png"),
    [#title([John Doe], size: 15pt)#linebreak()#body-text([position], size: 8pt)],
  )
]

// 11 — Section
#slide(grid: c("projects"),
  cell-styles: (
    projects: surface(fill: red, inset: 48pt, align: left + horizon),
  ),
)[
  #text(size: 39pt, weight: "bold", fill: cream)[Our Projects.]
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
  #title([Our Products], size: 29pt)
][
  #stack(
    dir: ttb,
    spacing: 24pt,
    ..range(1, 5).map(n => [
      #title([Project #("One", "Two", "Three", "Four").at(n - 1)], size: 15pt)
      #linebreak()
      #body-text([Elaborate on what you want to discuss.], size: 8pt)
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
  #title([Project One is lorem\ ipsum dolor sit\ amet, consectetur\ adipiscing elit, sed\ do eiusmod tempor\ incididunt.], size: 27pt)
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
    project-two-copy: surface(inset: (left: 30pt, right: 48pt), align: right + horizon),
  ),
)[
  #rect(width: 100%, height: 100%, stroke: 1.5pt + red, inset: 0pt)[#photo("image41.png")]
][
  #title([Project Two], size: 29pt)
  #v(10pt)
  #body-text([#copy #copy], size: 8pt)
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
  #title([Market Research], size: 29pt)
  #v(10pt)
  #body-text([#copy #copy], size: 8pt)
][
  #stack(
    dir: ttb,
    spacing: 26pt,
    ..(
      ([+88%], [Elaborate on the statistic here.]),
      ([+400k], [Elaborate on the statistic here.]),
      ([-12%], [Elaborate on the statistic here.]),
    ).map(pair => [
      #title(pair.first(), size: 25pt)#linebreak()
      #body-text(pair.last(), size: 8pt)
    ]),
  )
]

// 17 — Line chart
#slide(grid: c("chart"),
  cell-styles: (
    chart: surface(inset: (top: 42pt, left: 48pt, right: 48pt, bottom: 34pt)),
  ),
)[
  #title([Market Research], size: 29pt)
  #body-text([#copy], size: 8pt)
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
    #title([“], size: 38pt)
    #v(-8pt)
    #title([Write an original statement or\ inspiring quote.], size: 26pt)
    #v(9pt)
    #body-text([— Include a credit, citation, or supporting message], size: 8pt)
  ]
]

// 19 — Contact
#slide(grid: c("contact"),
  cell-styles: (
    contact: surface(inset: 48pt, align: left + horizon),
  ),
)[
  #title([Contact Us], size: 29pt)
  #v(15pt)
  #body-text([
    123 Anywhere St., Any City, ST 12345 \
    123-456-7890 \
    hello\@reallygreatsite.com \
    reallygreatsite.com \
    \@reallygreatsite
  ], size: 9pt)
]
