// Construction and validation of source-order incremental pause markers.
#import "../shared.typ": tag, fail

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
/// This is the least ceremonious way to build a slide: drop a marker where the
/// pause belongs, and everything after it moves to the following frame.
/// Everything before it stays on screen, so the slide accumulates.
///
/// ```typ
/// #mosaic.slide[
///   == Argument
///   The premise.
///   #mosaic.pause
///   The consequence.
///   #mosaic.pause
///   The objection.
/// ]
/// ```
///
/// A pause is a value rather than a function, so it takes no arguments and no
/// body. Compare `steps.on` and `steps.reveal`, which name their steps
/// explicitly and can therefore reach frames out of source order.
///
/// Empty leading, trailing, or consecutive pauses produce no blank frames.
///
/// -> content
#let pause = metadata((
  mosaic: tag,
  kind: "pause",
))
