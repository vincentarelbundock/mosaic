// Handout mode renders only the last step of each slide, so that step is the
// canonical frame: it carries the real heading elements and the reference
// labels that step 1 carries in an ordinary deck.
#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(handout: true)

== Handout title <handout-title>
HANDOUT BODY
#m.steps.pause
HANDOUT MORE

=== Handout subhead
HANDOUT TAIL #metadata(none) <tail-mark>

#figure(rect(), caption: [HANDOUT CAPTION]) <handout-figure>
See @handout-figure.

#context {
  assert(counter(page).final().first() == 1)
  assert(query(heading).map(it => it.body) == (
    [Handout title],
    [Handout subhead],
  ))
  assert(query(<handout-title>).len() == 1)
  assert(query(<handout-figure>).len() == 1)
  // The subhead is a block of its own, not the opening words of the paragraph
  // that follows it.
  let subhead = query(heading).last().location().position()
  let tail = query(<tail-mark>).first().location().position()
  assert(tail.y > subhead.y, message: repr((subhead, tail)))
}
