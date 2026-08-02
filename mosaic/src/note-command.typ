// Construction and validation of non-rendering speaker-note records.
#import "shared.typ": tag, fail

#let note-field-keys = ("body", "kind", "mosaic")

#let is-note(value) = {
  if (
    type(value) != content
      or value.func() != metadata
      or type(value.value) != dictionary
      or value.value.at("mosaic", default: none) != tag
      or value.value.at("kind", default: none) != "note"
  ) {
    return false
  }
  if value.value.keys().sorted() != note-field-keys {
    fail("invalid speaker note record")
  }
  if type(value.value.body) != content {
    fail("speaker note body must be content")
  }
  true
}

/// Attaches non-rendering speaker notes to a logical slide.
///
/// Multiple note blocks accumulate in source order. Wrap a note in
/// `steps.on`, `steps.reveal`, or `steps.replace` to assign it to the same
/// physical frames as nearby incremental content.
///
/// -> content
#let note(
  /// Note content.
  /// -> content
  body,
) = {
  if type(body) != content {
    fail("speaker note body must be content")
  }
  metadata((
    mosaic: tag,
    kind: "note",
    body: body,
  ))
}
