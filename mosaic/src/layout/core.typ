// Shared record shape and validation primitives for semantic layouts.
#import "../shared.typ": tag, fail

#let layout-field-keys = (
  content: ("columns", "tracks", "variant"),
  image: ("caption", "fit", "image", "position", "tracks"),
  title: (
    "accent", "authors", "date", "image", "position", "rule", "subtitle",
    "title", "tracks", "variant",
  ),
  section: (
    "accent", "image", "number", "position", "subtitle", "tracks", "variant",
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


// The fitting vocabulary of the image layout's `fit:` shorthand. Native
// `image` also accepts `"stretch"`; a design that truly wants distortion
// passes ready-made content built on the native element instead.
#let image-fit-modes = ("cover", "contain")

// A picture is named by a native `path` value and never by a string. Mosaic
// hands the source to native `image` from inside the package, where a string
// resolves against the package's own root rather than the deck's project, so
// a string could only ever find a file the package ships. A `path` value
// carries the project it was written in.
#let path-hint = "write path(\"cover.webp\") so the file resolves in your project"

// A picture has two spellings and no third: a bare `path`, which the layout
// turns into an image filling its region, or ready-made content, which states
// everything about itself. `components.image` is that content's usual
// constructor and already owns `fit`, `scrim`, and `alt`, so a dictionary
// repeating those keys here would be a second way to say the same thing.
#let validate-image(value, name) = {
  if type(value) in (content, path) {
    return value
  }
  if type(value) == str {
    fail(name + " must be a native path, not a string; " + path-hint)
  }
  if type(value) == dictionary {
    fail(
      name + " no longer takes a dictionary; build the picture with "
        + "components.image(path(\"cover.webp\"), scrim: ..) and pass that",
    )
  }
  fail(name + " must be a native path or content")
}
