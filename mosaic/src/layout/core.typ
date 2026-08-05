// Shared record shape and validation primitives for semantic layouts.
#import "../shared.typ": (
  tag, fail, reject-unknown-keys, valid-path, validate-scrim,
)

#let layout-field-keys = (
  content: ("columns", "tracks", "variant"),
  image: ("caption", "fit", "image", "tracks", "variant"),
  title: (
    "accent", "align", "authors", "date", "image", "rule", "subtitle",
    "title", "tracks", "variant",
  ),
  section: (
    "accent", "image", "number", "subtitle", "tracks", "variant",
  ),
)

#let make-layout(name, fields) = (
  mosaic: tag,
  kind: "layout",
  name: name,
  fields: fields,
)

#let validate-accent(fields, name, allow-auto: false) = {
  if type(fields.accent) != color and not (allow-auto and fields.accent == auto) {
    fail("layout " + repr(name) + " accent must be a color")
  }
}

#let is-layout(value) = if (
  type(value) != dictionary
    or value.keys().sorted()
      != ("fields", "kind", "mosaic", "name")
    or value.mosaic != tag
    or value.kind != "layout"
    or type(value.name) != str
    or value.name not in layout-field-keys
    or type(value.fields) != dictionary
) {
  false
} else {
  value.fields.keys().sorted() == layout-field-keys.at(value.name)
}


// The fitting vocabulary Mosaic validates, shared by every place a picture
// spec is checked so the spelling cannot drift. Native `image` also accepts
// `"stretch"`; a design that truly wants distortion passes ready-made content
// built on the native element instead.
#let image-fit-modes = ("cover", "contain")

#let validate-visual-spec(
  value,
  subject,
  allow-size: true,
) = {
  if type(value) == content {
    return value
  }
  let spec = if valid-path(value) {
    (path: value)
  } else if type(value) == dictionary {
    value
  } else {
    fail(
      subject
        + " must be content, a non-empty path string, a native path, or a path dictionary",
    )
  }
  let allowed = if allow-size {
    ("path", "alt", "width", "height", "fit", "scrim")
  } else {
    ("path", "alt", "fit", "scrim")
  }
  reject-unknown-keys(spec, allowed, subject)
  if "path" not in spec or not valid-path(spec.path) {
    fail(subject + " path must be a non-empty string or native path")
  }
  let alt = spec.at("alt", default: none)
  if alt != none and type(alt) != str {
    fail(subject + " alt must be a string or none")
  }
  let fit = spec.at("fit", default: "cover")
  if type(fit) != str or fit not in image-fit-modes {
    fail(subject + " fit must be \"cover\" or \"contain\"")
  }
  let _ = validate-scrim(spec.at("scrim", default: none), subject)
  spec
}
