#import "@local/mosaic:0.0.2" as mosaic

// Content between a level-1 heading and the next level-2 heading becomes the
// automatic section slide's subtitle, so a tagline costs no explicit slide and
// the heading keeps its outline entry.
#set page(width: 160pt, height: 90pt, margin: 5pt)
#show: mosaic.setup.with(
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

= Section <tagged-section>

SECTION TAGLINE

== First

A

= Bare Section

== Second

B

#context {
  // One page per section slide and per content slide: 4 in total. A tagline
  // does not add a page, and a section without one still compiles.
  assert(counter(page).final().first() == 4)
  assert(query(<tagged-section>).len() == 1)
  assert(query(heading.where(outlined: true)).len() == 4)
}
