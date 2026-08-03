// Presentation-oriented image convenience built on native Typst images.
#import "../shared.typ": validate-scrim

#let _native-image = image

/// Creates a slide-sized native Typst image with an optional scrim.
///
/// Width and height default to `100%`, while `fit` defaults to `"cover"`.
/// All additional arguments are forwarded unchanged to Typst's native
/// `image`, including `alt`, `format`, `page`, and `scaling`.
/// When Mosaic is imported as a package, use a native `path` value for an
/// image in the calling project, for example `path("photo.webp")`.
///
/// `scrim` paints a layer over the picture and under whatever text is composed
/// on top of it, which is how a photograph is quieted enough to read against.
/// It takes an ordinary Typst paint, so it accepts exactly what a `fill`
/// accepts: `black.transparentize(55%)` darkens the whole frame evenly, and a
/// gradient darkens only the band the text occupies. Without a scrim, this
/// function returns the native image element directly.
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
  /// Paint layered over the picture, or `none`.
  /// -> none | color | gradient | tiling
  scrim: none,
  /// Additional arguments forwarded to native Typst `image`.
  ..native,
) = {
  let scrim = validate-scrim(scrim, "image")

  if scrim == none {
    return _native-image(
      source,
      width: width,
      height: height,
      fit: fit,
      ..native,
    )
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
        fill: scrim,
        stroke: none,
      ),
    )
  ]
}
