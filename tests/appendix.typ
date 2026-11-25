// An appendix marker stops the totals at the end of the talk. Slides and
// sections after it keep numbering past the totals ("4 / 3"), and the toc
// section variant lists only the talk's sections. The progress indicator on a
// backup slide is drawn full rather than past its track.
#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(
  layouts: (content: m.layouts.content(variant: "header-body-footer")),
  cells: (footer: m.components.progress(variant: "line")),
)

#let expect(slide, section) = context {
  let deck = m.info()
  assert(
    (deck.slide.number, deck.slide.total) == slide,
    message: "slide " + repr((deck.slide.number, deck.slide.total)),
  )
  assert(
    (deck.section.number, deck.section.total) == section,
    message: "section " + repr((deck.section.number, deck.section.total)),
  )
}

= Talk section A
== One
#expect((1, 3), (1, 2))
== Two
#expect((2, 3), (1, 2))
= Talk section B
== Three
#expect((3, 3), (2, 2))

#m.appendix

= Backup section
== Four
#expect((4, 3), (3, 2))

#m.slide(layout: m.layouts.section(variant: "toc"))[Contents]

#m.slide[== Five][#expect((5, 3), (4, 2))]
