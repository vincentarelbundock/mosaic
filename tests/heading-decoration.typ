// A transforming heading rule declared through `decorate-heading` is applied on
// every frame, not only on the one that carries the real heading element. Two
// rules nest in declaration order, the later one outermost, as native show
// rules do. The function is reached through the public theme-extension API,
// `themes.decorate-heading`, which is how a deck or a custom theme spells it.
#import "@local/mosaic:0.0.3" as m

#let decorate-heading = m.themes.decorate-heading

#show: m.setup
#show heading.where(level: 2): set text(fill: red)
#show: decorate-heading.with(level: 2, it => block(width: 100%)[
  #it
  #v(0.24em)
  #line(length: 2.4em)
  #metadata(none) <rule-mark>
])
#show: decorate-heading.with(level: 2, upper)

== Decorated title
DECORATED BODY #metadata(none) <body-mark>
#m.steps.pause
DECORATED MORE

#context {
  let marks = query(<body-mark>).map(it => it.location().position())
  let rules = query(<rule-mark>).map(it => it.location().position())
  assert(counter(page).final().first() == 2)
  assert(marks.len() == 2)
  assert(marks.first().y == marks.last().y, message: repr(marks))
  // The rule is drawn on both frames, at the same place.
  assert(rules.len() == 2)
  assert(rules.first().y == rules.last().y, message: repr(rules))
  assert(rules.first().x == rules.last().x, message: repr(rules))
  assert(query(heading).len() == 1)
}
