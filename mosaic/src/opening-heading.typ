// The heading that opens a slide, read the same way for both kinds of slide.
//
// An explicit slide is an automatic slide written out: `== Title` followed by
// content and `slide[== Title][content]` describe the same thing, so both
// take their heading from here. The deck compiler walks the document with
// `top-level-content` to find the headings that open automatic slides, and the
// content router uses `split-opening-heading`, built on the same walk, to lift
// the heading that opens an explicit slide's first body. One definition of
// "opens with a heading" (spacing before it, styled wrappers around it, a
// constructed `heading(level: ..)`) keeps the two from drifting.
#import "shared.typ": typst-sequence, typst-space, typst-styled
#import "incremental/heading.typ": resolve-heading-depth

#let is-heading-space(value) = (
  value == []
    or (
      type(value) == content
        and value.func() in (parbreak, typst-space)
    )
)

#let wrap-content(value, wrappers) = {
  for wrapper in wrappers.rev() {
    value = (wrapper.func)(value, wrapper.styles)
  }
  value
}

#let top-level-content(body, wrappers: (), path: ()) = if (
  type(body) == content and body.func() == typst-sequence
) {
  body.children.enumerate().map(((index, child)) => top-level-content(
    child,
    wrappers: wrappers,
    path: path + (index,),
  )).flatten()
} else if type(body) == content and body.func() == typst-styled {
  top-level-content(
    body.child,
    wrappers: wrappers + ((
      func: body.func(),
      styles: body.styles,
      // The tree position of the styled element this wrapper came from, so
      // two entries share a wrapper prefix only when they sit inside the very
      // same styled elements, not merely equally many.
      id: path,
    ),),
    path: path + (0,),
  )
} else {
  ((
    raw: body,
    shown: wrap-content(body, wrappers),
    wrappers: wrappers,
  ),)
}

// Splits content into the heading that opens it and everything after, as
// `(heading: .., rest: ..)`. The heading keeps the styles of the styled
// elements it sits in and, if constructed, gains its depth; `rest` is `none`
// when nothing but spacing follows. Content that does not open with a heading
// returns `heading: none` and is not rebuilt.
#let split-opening-heading(body) = {
  let entries = top-level-content(body)
  let index = entries.position(entry => not is-heading-space(entry.raw))
  if index == none {
    return (heading: none, rest: body)
  }
  let opening = entries.at(index)
  if type(opening.raw) != content or opening.raw.func() != heading {
    return (heading: none, rest: body)
  }
  // Spacing around what follows the heading only separated the two in the
  // source. Left in, it would open or close the cell with an empty paragraph,
  // and the one-block spelling would differ from `slide[== T][Body]`.
  let after = entries.slice(index + 1)
  let start = after.position(entry => not is-heading-space(entry.raw))
  let end = after.rev().position(entry => not is-heading-space(entry.raw))
  (
    heading: wrap-content(resolve-heading-depth(opening.raw), opening.wrappers),
    rest: if start == none {
      none
    } else {
      after.slice(start, after.len() - end).map(entry => entry.shown).sum()
    },
  )
}
