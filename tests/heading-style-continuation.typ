#import "@local/mosaic:0.0.1" as mosaic

#set page(width: 160pt, height: 90pt, margin: 5pt)
#show: mosaic.setup.with(
  spacing: (inset: 5pt),
)
#set text(size: 7pt)
#show heading.where(level: 2): set text(
  size: 1.45em,
  weight: "bold",
  fill: red,
)
#show heading.where(level: 2): set align(center)

#mosaic.slide[
  == Automatically styled <styled-heading>

  #mosaic.steps.reveal[
    - First frame. #metadata(none) <stable-body>
    - Second frame.
    - Third frame.
  ]
]

#context {
  let body-positions = query(<stable-body>).map(
    item => item.location().position(),
  )
  assert(query(heading).len() == 1)
  assert(query(<styled-heading>).len() == 1)
  assert(
    query(<styled-heading>).first().body == [Automatically styled],
  )
  assert(body-positions.len() == 3)
  assert(
    body-positions.all(position => position.y == body-positions.first().y),
    message: repr(body-positions),
  )
  assert(counter(page).final().first() == 3)
}
