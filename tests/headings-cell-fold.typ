#import "@local/mosaic:0.0.2" as mosaic

// An automatic `==` slide addresses the cells the standard layouts carry
// ("header" and "body"). A configured content layout without a header cell
// must still accept the heading: it folds into the body flow instead of
// failing on a cell id the author never wrote.
#set page(width: 160pt, height: 90pt, margin: 5pt)
#show: mosaic.setup.with(
  layouts: (content: mosaic.layouts.content(variant: "body")),
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

== Folded Title

FOLDED BODY

#context {
  assert(counter(page).final().first() == 1)
  assert(query(heading).len() == 1)
}
