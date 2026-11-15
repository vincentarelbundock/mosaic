#import "@local/mosaic:0.0.3" as mosaic

// Lists under the themes that widen tight lists. Compiled once per theme by
// the runner (`--input theme=..`), which also reads the numbering back from
// the PDF text; the spacing contract is asserted here.
#let theme-name = sys.inputs.at("theme", default: "editorial")
#let theme = dictionary(mosaic.themes).at(theme-name)
#show: theme.setup.with(foreground: none)

// A zero-size marker at the start of an item, so its position can be read.
#let mark(name) = [#box(width: 0pt, height: 0pt)#label(name)]
#let top(name) = query(label(name)).first().location().position().y
#let assert-even(names) = {
  let tops = names.map(top)
  let gaps = tops.windows(2).map(pair => pair.at(1) - pair.at(0))
  for gap in gaps {
    assert(
      calc.abs(gap - gaps.first()) < 0.01pt,
      message: theme-name + " " + repr(names) + " gaps " + repr(gaps),
    )
  }
  gaps.first()
}

// Every spelling of an enum compiles and keeps its numbering.
#mosaic.slide[
  + PLUS ONE
  + PLUS TWO

  7. SEVEN
  8. EIGHT

  #enum(start: 3)[THREE][FOUR]

  #enum(numbering: "a)")[ALPHA][BETA]

  #list(marker: [ZZ])[MARKED]
]

// A list nested in a tight list, in a wide list, and in an enum sits at the
// item rhythm, not at the paragraph spacing.
#mosaic.slide[
  - #mark("tight-a") a
  - #mark("tight-b") b
    - #mark("tight-n1") n1
    - #mark("tight-n2") n2
  - #mark("tight-c") c
]
#mosaic.slide[
  - #mark("wide-a") a

  - #mark("wide-b") b
    + #mark("wide-n1") n1
    + #mark("wide-n2") n2

  - #mark("wide-c") c
]
#mosaic.slide[
  + #mark("enum-a") a
  + #mark("enum-b") b
    - #mark("enum-n1") n1
  + #mark("enum-c") c
]

// A deck that changes the item spacing keeps the rhythm even.
#[
  #set list(spacing: 2em)
  #mosaic.slide[
    - #mark("user-a") a
    - #mark("user-b") b
      - #mark("user-n1") n1
    - #mark("user-c") c
  ]
]

#context {
  let tight = assert-even(("tight-a", "tight-b", "tight-n1", "tight-n2", "tight-c"))
  let wide = assert-even(("wide-a", "wide-b", "wide-n1", "wide-n2", "wide-c"))
  let numbered = assert-even(("enum-a", "enum-b", "enum-n1", "enum-c"))
  let user = assert-even(("user-a", "user-b", "user-n1", "user-c"))
  assert(calc.abs(tight - wide) < 0.01pt)
  assert(calc.abs(tight - numbered) < 0.01pt)
  assert(user > tight + 1pt, message: repr((user, tight)))
}
