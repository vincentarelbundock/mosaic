// Construction and validation of source-order incremental pause markers.
#import "shared.typ": tag, fail

#let pause-field-keys = ("kind", "mosaic")

#let is-pause(value) = {
  if (
    type(value) != content
      or value.func() != metadata
      or type(value.value) != dictionary
      or value.value.at("mosaic", default: none) != tag
      or value.value.at("kind", default: none) != "pause"
  ) {
    return false
  }
  if value.value.keys().sorted() != pause-field-keys {
    fail("invalid pause record")
  }
  true
}

#let pause-segments(children) = {
  let segments = ((),)
  for child in children {
    if is-pause(child) {
      segments.push(())
    } else {
      segments.last().push(child)
    }
  }
  segments
}

#let has-pause(children) = children.any(is-pause)

#let pause-schedule(children, duration) = {
  let result = ()
  let start = 1
  for segment in pause-segments(children) {
    let span = duration(segment)
    if span > 0 {
      result.push((children: segment, start: start, duration: span))
      start += span
    }
  }
  result
}

/// Advances subsequent content to the next physical frame.
///
/// A pause separates source-order content into persistent incremental segments.
/// Empty leading, trailing, or consecutive pauses do not create blank frames.
///
/// -> content
#let pause = metadata((
  mosaic: tag,
  kind: "pause",
))
