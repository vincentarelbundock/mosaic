// Private presentation settings and contextual configuration.
#import "shared.typ": fail, require-dictionary, reject-unknown-keys
#import "color.typ": scheme

#let merge-record(base, override, name) = {
  require-dictionary(override, name)
  reject-unknown-keys(override, base, name)
  base + override
}

#let default-colors = scheme("light")

#let default-type = (
  body: (
    font: (
      "Inter",
      "Source Sans 3",
      "Liberation Sans",
      "DejaVu Sans",
      "Libertinus Serif",
    ),
    fallback: true,
    size: 28pt,
    fill: luma(15%),
  ),
  title: (size: 2em, weight: "semibold"),
  subtitle: (size: 1.05em, fill: luma(42%)),
  heading: (size: 1.4em, weight: "semibold"),
  caption: (size: 0.72em, fill: luma(45%)),
  small: (size: 0.55em),
)

#let default-shape = (
  radius: 8pt,
  stroke: 0.8pt,
)

#let default-spacing = (
  inset: 1.25em,
  gap: 0.7em,
  compact-gap: 0.35em,
  heading-below: 0.75em,
  list-spacing: 0.5em,
)

#let default-features = (
  rounded: true,
  slide-number: false,
  slide-total: false,
  progress: false,
  section-label: false,
  logo: none,
  footer: none,
  overflow: "warn",
)

#let settings-state = state("mosaic:settings", none)

#let make-settings(
  colors: (:),
  spacing: (:),
  features: (:),
) = {
  let colors = merge-record(default-colors, colors, "colors")
  let typography = default-type + (
    body: default-type.body + (fill: colors.text),
    subtitle: default-type.subtitle + (fill: colors.muted),
    caption: default-type.caption + (fill: colors.muted),
    small: default-type.small + (fill: colors.muted),
  )
  let spacing = merge-record(default-spacing, spacing, "spacing")
  let features = merge-record(default-features, features, "features")
  if features.overflow not in ("off", "warn") {
    fail("features overflow must be \"off\" or \"warn\"")
  }
  (
    colors: colors,
    type: typography,
    shape: default-shape,
    spacing: spacing,
    features: features,
  )
}

// Derive slide-local settings without mutating the presentation settings state.
#let with-colors(value, colors, name: "slide colors") = {
  let colors = merge-record(value.colors, colors, name)
  let typography = value.type + (
    body: value.type.body + (fill: colors.text),
    subtitle: value.type.subtitle + (fill: colors.muted),
    caption: value.type.caption + (fill: colors.muted),
    small: value.type.small + (fill: colors.muted),
  )
  value + (
    colors: colors,
    type: typography,
  )
}

#let validate-settings(value) = {
  if type(value) != dictionary {
    fail("invalid internal presentation settings")
  }
  if (
    value.keys().sorted() != ("colors", "features", "shape", "spacing", "type")
      or type(value.colors) != dictionary
      or value.colors.keys().sorted() != default-colors.keys().sorted()
      or type(value.type) != dictionary
      or value.type.keys().sorted() != default-type.keys().sorted()
      or not value.type.values().all(item => type(item) == dictionary)
      or type(value.shape) != dictionary
      or value.shape.keys().sorted() != default-shape.keys().sorted()
      or type(value.spacing) != dictionary
      or value.spacing.keys().sorted() != default-spacing.keys().sorted()
      or type(value.features) != dictionary
      or value.features.keys().sorted() != default-features.keys().sorted()
  ) {
    fail("invalid internal presentation settings")
  }
  value
}

#let configure-settings(value) = settings-state.update(validate-settings(value))
