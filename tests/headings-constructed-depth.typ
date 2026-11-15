#import "@local/mosaic:0.0.3" as mosaic

// A heading built with `heading(level: ..)` opens its slide carrying the
// depth the compiler classified it by, so theme rules written against
// `heading.where(depth: ..)` and against `where(level: ..)` both reach it.
#show: mosaic.setup.with(
  paper: (width: 160pt, height: 90pt),
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

#heading(level: 1)[Constructed section]

#heading(level: 2)[Constructed slide] <constructed>

Body.

#context {
  let headings = query(heading)
  assert(headings.map(it => it.depth) == (1, 2), message: repr(headings))
  assert(headings.map(it => it.level) == (1, 2), message: repr(headings))
  assert(query(<constructed>).len() == 1)
  assert(query(heading.where(depth: 2)).len() == 1)
  assert(counter(page).final().first() == 2)
}
