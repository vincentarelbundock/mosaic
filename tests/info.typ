#import "@local/mosaic:0.0.1" as mosaic

#set page(width: 240pt, height: 135pt, margin: 8pt)

#let authors = (
  mosaic.layouts.author("Ada Lovelace", affiliations: ([Analytical Engine],)),
)

#show: mosaic.setup.with(
  title: [DECK TITLE],
  subtitle: [DECK SUBTITLE],
  authors: authors,
  date: [DECK DATE],
  spacing: (inset: 8pt),
)
#set text(size: 9pt)

// The record is the four declared fields plus the two position records.
#let fields = ("authors", "date", "section", "slide", "subtitle", "title")

// An unnumbered slide before every section: the counts are the deck's finals,
// but this slide's own numbers are zero.
#mosaic.slide(numbered: false)[
  #context {
    let info = mosaic.info()
    assert(info.keys().sorted() == fields)
    assert(info.title == [DECK TITLE])
    assert(info.subtitle == [DECK SUBTITLE])
    assert(info.authors == authors)
    assert(info.date == [DECK DATE])
    assert(info.slide == (number: 0, total: 2, numbered: false))
    assert(info.section == (number: 0, total: 2, title: none))
  }
]

// A section slide already names itself: the runtime writes the title before
// the planes and the grid render, so its own chrome reads the new section
// rather than the previous one.
#mosaic.slide(
  layout: "section",
  foreground: context {
    let info = mosaic.info()
    assert(info.section.number == 1)
    assert(info.section.title == [Methods])
    assert(info.slide.numbered == false)
  },
)[Methods]

// An ordinary slide holds the section it is in and takes the next number.
#mosaic.slide[
  #context {
    let info = mosaic.info()
    assert(info.slide == (number: 1, total: 2, numbered: true))
    assert(info.section == (number: 1, total: 2, title: [Methods]))
  }
]

#mosaic.slide(layout: "section")[Results]

// Incremental frames are one logical slide, so the number does not advance
// with the reveal.
#mosaic.slide[
  #mosaic.steps.reveal[One][Two]
  #context {
    let info = mosaic.info()
    assert(info.slide == (number: 2, total: 2, numbered: true))
    assert(info.section == (number: 2, total: 2, title: [Results]))
  }
]

// The same numbers the progress component prints, which reads the same
// position records.
#mosaic.slide(numbered: false)[
  #mosaic.components.progress(variant: "1/1")
  #mosaic.components.progress(variant: "1/1", count: "sections")
]
