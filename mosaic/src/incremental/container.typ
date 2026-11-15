// Containers Mosaic itself provides, made transparent to its own walks.
//
// A component resolves its paint inside a `context` block, and a `context`
// block is opaque: nothing can look inside it for a step, a pause, or a
// speaker note. Content written in the body of a card would therefore be
// invisible to the commands of the package that drew the card.
//
// So a container does not hand over only its rendering. It hands over a
// record of the content the author wrote (`parts`, by name) and the function
// that draws the container around it (`render`), followed by that rendering.
// A walk that meets the record recurses into the parts and, when it rebuilds
// the slide for one step, calls `render` on the transformed parts and drops
// the stand-in. Where nothing walks the content (a document with no deck, or
// a place that really is opaque) the record is inert metadata and the
// stand-in is what shows, exactly as before.
#import "../shared.typ": tag, is-record

#let container-field-keys = ("kind", "mosaic", "parts", "render")

#let is-container(value) = (
  is-record(value, "container", container-field-keys, "container")
)

// The stand-in is the one element that follows its record, and it always
// carries a label: this one, or the author's own, since `#card[..] <mine>`
// attaches to the last element the call produced and replaces it. A walk
// that rebuilds a sequence therefore drops the labeled sibling after a
// record, and moves an author's label onto the drawing it puts there.
#let stand-in-label = <mosaic-container-stand-in>

#let is-stand-in(value) = (
  type(value) == content
    and value.at("label", default: none) == stand-in-label
)

// `parts` is a dictionary of the author's content by name; an entry that is
// not content (an absent title) is carried through untouched. `render` takes
// the same dictionary and returns the drawing.
//
// The stand-in draws from inside `context`, which defers the call: a walk
// that drops the stand-in never runs it. That matters to a container whose
// drawing refuses unresolved steps, as a fitted figure does; the parts it
// would be refusing are the ones the walk is about to resolve.
#let make-container(parts, render: none) = {
  metadata((mosaic: tag, kind: "container", parts: parts, render: render))
  [#context render(parts)#stand-in-label]
}
