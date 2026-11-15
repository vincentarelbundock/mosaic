// Construction and validation of non-rendering speaker-note records.
#import "../shared.typ": tag, fail, is-record

#let note-field-keys = ("body", "kind", "mosaic")

#let is-note(value) = {
  if not is-record(value, "note", note-field-keys, "speaker note") {
    return false
  }
  if type(value.value.body) != content {
    fail("speaker note body must be content")
  }
  true
}

/// Attaches non-rendering speaker notes to a logical slide.
///
/// Notes never appear in the slides themselves. They are collected and shown by
/// the `"speaker"` and `"notes"` outputs of `setup`.
///
/// ```typ
/// #show: mosaic.setup.with(output: "speaker")
///
/// #mosaic.slide[
///   == Results
///   #mosaic.note[Mention the confidence interval before the table.]
///   The estimate holds under both specifications.
/// ]
/// ```
///
/// Multiple note blocks on one slide accumulate in source order. Wrap a note in
/// `steps.on`, `steps.reveal`, or `steps.replace` to tie it to the same physical
/// frames as the incremental content it belongs with, so the speaker view shows
/// it beside the frame it describes.
///
/// A note never adds a frame, and is never dropped. Tied to a step the slide
/// does not reach, such as `steps.on(3)` on a slide whose visible content ends
/// at step 2, it is shown on the slide's last frame.
///
/// A note can be written anywhere Mosaic can find it by walking the slide's
/// content: in ordinary markup, in a native container, in a component, or in
/// a layout field such as a section tagline. It cannot be found inside a
/// `context` block, a `layout` callback, or the output of a show rule, and a
/// note placed there fails the compile rather than being dropped.
///
/// -> content
#let note(
  /// The note text. Ordinary content, so lists and emphasis work as usual.
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
