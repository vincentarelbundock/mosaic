#import "@local/mosaic:0.0.1" as mosaic

#set page(width: 240pt, height: 135pt, margin: 8pt)
#set heading(numbering: "1.1")

#let expected-heading(body, value) = {
  assert(value != none)
  assert(value.body == body)
}

#show: mosaic.setup.with(
  spacing: (inset: 8pt),
)
#set text(size: 9pt)

#mosaic.deck(
  foreground: context {
    let page = counter(page).get().first()
    let section = mosaic.current-heading()
    let slide = mosaic.current-heading(level: 2)
    if page == 1 {
      expected-heading([Alpha], section)
      assert(slide == none)
    } else if page in (2, 3, 4) {
      expected-heading([Alpha], section)
      expected-heading([Alpha slide], slide)
    } else if page == 5 {
      // An unoutlined current section must not fall back to Alpha. A new
      // level-one heading also resets the active level-two heading.
      assert(section == none)
      expected-heading(
        [Beta],
        mosaic.current-heading(outlined: false),
      )
      assert(slide == none)
    } else if page in (6, 7) {
      assert(section == none)
      expected-heading(
        [Beta],
        mosaic.current-heading(outlined: false),
      )
      expected-heading([Beta slide], slide)
    } else if page in (8, 9) {
      assert(section == none)
      expected-heading(
        [Beta],
        mosaic.current-heading(outlined: false),
      )
      expected-heading([Nested container], slide)
    }
  },
)

#mosaic.slide(numbered: false)[
  = Alpha <alpha>
]

#mosaic.slide[
  == Alpha slide <alpha-slide>

  #mosaic.reveal[First][Second][Third]

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

  #mosaic.replace[Before][After]
]

#mosaic.slide[
  == Nested container

  #grid[
    === Nested detail <nested-detail>
  ]

  #mosaic.reveal[One][Two]
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
