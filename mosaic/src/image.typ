// Presentation-oriented image convenience built on native Typst images.
#import "shared.typ": fail

#let _native-image = image

#let _validate-adjustment(value, name) = {
  if value != none and (
    type(value) != ratio or value < 0% or value > 100%
  ) {
    fail("image " + name + " must be a ratio from 0% to 100% or none")
  }
  value
}

/// Creates a slide-sized native Typst image with optional tonal adjustment.
///
/// Width and height default to `100%`, while `fit` defaults to `"cover"`.
/// All additional arguments are forwarded unchanged to Typst's native
/// `image`, including `alt`, `format`, `page`, and `scaling`.
/// When Mosaic is imported as a package, use a native `path` value for an
/// image in the calling project, for example `path("photo.webp")`.
///
/// `lighten` places a white wash over the image; `darken` places a black wash.
/// Each is the opacity of that wash and accepts a ratio from `0%` to `100%`.
/// They cannot be combined. Without either adjustment, this function returns
/// the native image element directly.
///
/// -> content
#let image(
  /// Native image source. Use `path(...)` for assets in the calling project.
  source,
  /// Width of the image area.
  /// -> auto | length | relative
  width: 100%,
  /// Height of the image area.
  /// -> auto | length | relative | fraction
  height: 100%,
  /// Native Typst image fitting mode.
  /// -> str
  fit: "cover",
  /// Strength of the white wash.
  /// -> none | ratio
  lighten: none,
  /// Strength of the black wash.
  /// -> none | ratio
  darken: none,
  /// Additional arguments forwarded to native Typst `image`.
  ..native,
) = {
  let lighten = _validate-adjustment(lighten, "lighten")
  let darken = _validate-adjustment(darken, "darken")
  if lighten != none and darken != none {
    fail("image accepts either lighten or darken, not both")
  }

  if lighten == none and darken == none {
    return _native-image(
      source,
      width: width,
      height: height,
      fit: fit,
      ..native,
    )
  }

  let wash = if lighten != none {
    white.transparentize(100% - lighten)
  } else {
    black.transparentize(100% - darken)
  }
  block(
    width: width,
    height: height,
    breakable: false,
    clip: true,
  )[
    #_native-image(
      source,
      width: if width == auto { auto } else { 100% },
      height: if height == auto { auto } else { 100% },
      fit: fit,
      ..native,
    )
    #place(
      top + left,
      rect(
        width: 100%,
        height: 100%,
        fill: wash,
        stroke: none,
      ),
    )
  ]
}
