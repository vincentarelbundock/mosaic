#import "@preview/mosaic:0.0.1" as mosaic

#set page(width: 240pt, height: 135pt, margin: 8pt)
#set heading(numbering: "1.1")

#show: mosaic.setup.with(
  spacing: (inset: 8pt),
)
#set text(size: 9pt)

#mosaic.slide(numbered: false)[
  = Alpha <alpha>
]

#mosaic.slide[
  == Alpha slide <alpha-slide>

  #mosaic.steps.reveal[First][Second][Third]

  === Detail <alpha-detail>
]

#mosaic.slide(numbered: false)[
  #heading(
    depth: 1,
    outlined: false,
    bookmarked: false,
  )[Beta]
]

#mosaic.slide[
  == Beta slide

  #mosaic.steps.replace[Before][After]
]

#mosaic.slide[
  == Nested container

  #grid[
    === Nested detail <nested-detail>
  ]

  #mosaic.steps.reveal[One][Two]
]

#context {
  let all = query(heading)
  assert(all.len() == 7, message: repr(all.map(it => it.body)))
  assert(
    query(heading.where(outlined: true)).len() == 6,
  )
  assert(query(<alpha>).len() == 1)
  assert(query(<alpha-slide>).len() == 1)
  assert(query(<alpha-detail>).len() == 1)
  assert(query(<nested-detail>).len() == 1)
  assert(counter(heading).final() == (2, 2, 1))
  assert(counter(page).final().first() == 9)
}
