// Shared record shape and validation primitives for semantic layouts.
#import "shared.typ": tag, fail, reject-unknown-keys, valid-path

#let layout-field-keys = (
  default: ("accent", "columns", "progress", "tracks", "variant"),
  title: (
    "accent", "align", "authors", "date", "image", "rule", "subtitle", "title",
    "tracks", "variant",
  ),
  section: ("accent", "image", "number", "subtitle", "tracks", "variant"),
)

#let make-grid(name, fields, suppress-global-logo: false) = (
  mosaic: tag,
  kind: "layout-grid",
  name: name,
  fields: fields,
  suppress-global-logo: suppress-global-logo,
)

#let validate-accent(fields, name) = {
  if type(fields.accent) != color {
    fail("layout " + repr(name) + " accent must be a color")
  }
}

#let is-layout-grid(value) = if (
  type(value) != dictionary
    or value.keys().sorted()
      != ("fields", "kind", "mosaic", "name", "suppress-global-logo")
    or value.mosaic != tag
    or value.kind != "layout-grid"
    or type(value.name) != str
    or value.name not in layout-field-keys
    or type(value.fields) != dictionary
    or type(value.suppress-global-logo) != bool
) {
  false
} else {
  value.fields.keys().sorted() == layout-field-keys.at(value.name)
}


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
    ("path", "alt", "width", "height", "fit")
  } else {
    ("path", "alt", "fit")
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
  if type(fit) != str or fit not in ("cover", "contain", "stretch") {
    fail(subject + " fit must be \"cover\", \"contain\", or \"stretch\"")
  }
  spec
}
