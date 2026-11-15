#import "@local/mosaic:0.0.3" as mosaic

// `font` and `base-size` are options of `setup` under every theme. A custom
// theme that declares neither still accepts them, and one that states nothing
// gets Typst's own font and the engine's base size.
#let colors = (
  canvas: white, surface: white, text: black, muted: gray,
  line: gray, accent: blue, warning: orange, error: red,
)
#let bare = mosaic.themes.setup((colors: colors))

#let input = sys.inputs.at("case", default: "bare")
#show: if input == "bare" {
  bare
} else if input == "deck" {
  bare.with(font: "DejaVu Sans Mono", base-size: 31pt)
} else {
  // A bundled theme takes the same two options, over its own defaults.
  mosaic.themes.editorial.setup.with(font: "DejaVu Sans Mono", base-size: 31pt)
}

== Slide

#context {
  if input == "bare" {
    assert(text.size == 24pt, message: repr(text.size))
    assert(text.font == "libertinus serif", message: repr(text.font))
  } else {
    assert(text.size == 31pt, message: repr(text.size))
    assert(text.font == "dejavu sans mono", message: repr(text.font))
  }
}
