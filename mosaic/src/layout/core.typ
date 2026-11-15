// Shared record shape and validation primitives for semantic layouts.
#import "../shared.typ": tag, fail, validate-keys, validate-scrim

#let layout-field-keys = (
  content: ("columns", "tracks", "variant"),
  image: ("caption", "fit", "image", "tracks", "variant"),
  title: (
    "accent", "authors", "date", "image", "position", "rule", "subtitle",
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
    fail(
      "layout " + repr(name) + " accent must be a color"
        + if allow-auto { " or auto" } else { "" },
    )
  }
  fields
}

#let validate-variant(value, allowed, name) = {
  if type(value) != str or value not in allowed {
    fail(
      name + " has unsupported variant " + repr(value)
        + "; expected one of " + repr(allowed),
    )
  }
  value
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
// dictionary is checked so the spelling cannot drift. Native `image` also accepts
// `"stretch"`; a design that truly wants distortion passes ready-made content
// built on the native element instead.
#let image-fit-modes = ("cover", "contain")

// A picture is named by a native `path` value and never by a string. Mosaic
// hands the source to native `image` from inside the package, where a string
// resolves against the package's own root rather than the deck's project, so
// a string could only ever find a file the package ships. A `path` value
// carries the project it was written in.
#let path-hint = "write path(\"cover.webp\") so the file resolves in your project"

#let validate-image(
  value,
  name,
  allow-size: true,
) = {
  if type(value) == content {
    return value
  }
  if type(value) == str {
    fail(name + " must be a native path, not a string; " + path-hint)
  }
  let value = if type(value) == path {
    (path: value)
  } else if type(value) == dictionary {
    value
  } else {
    fail(name + " must be content, a native path, or a path dictionary")
  }
  let allowed = if allow-size {
    ("path", "alt", "width", "height", "fit", "scrim")
  } else {
    ("path", "alt", "fit", "scrim")
  }
  _ = validate-keys(value, allowed, name)
  if "path" not in value or type(value.path) != path {
    fail(name + " path must be a native path; " + path-hint)
  }
  let alt = value.at("alt", default: none)
  if alt != none and type(alt) != str {
    fail(name + " alt must be a string or none")
  }
  let fit = value.at("fit", default: "cover")
  if type(fit) != str or fit not in image-fit-modes {
    fail(name + " fit must be \"cover\" or \"contain\"")
  }
  _ = validate-scrim(value.at("scrim", default: none), name)
  value
}
