// Private presentation settings and contextual configuration.
#import "shared.typ": fail, require-dictionary, reject-unknown-keys
#import "color-defaults.typ": default-text, default-muted

#let merge-record(base, override, name) = {
  require-dictionary(override, name)
  reject-unknown-keys(override, base, name)
  base + override
}

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
    fill: default-text,
  ),
  title: (size: 2em, weight: "semibold"),
  subtitle: (size: 1.05em, fill: default-muted),
  heading: (size: 1.4em, weight: "semibold"),
  caption: (size: 0.72em, fill: default-muted),
  small: (size: 0.55em, fill: default-muted),
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
  list-spacing: 0.8em,
)

#let default-features = (
  slide-number: false,
  slide-total: false,
  progress: false,
  logo: none,
  footer: none,
  overflow: "warn",
)

#let settings-state = state("mosaic:settings", none)

#let make-settings(
  spacing: (:),
  features: (:),
) = {
  let spacing = merge-record(default-spacing, spacing, "spacing")
  let features = merge-record(default-features, features, "features")
  if features.overflow not in ("off", "warn") {
    fail("features overflow must be \"off\" or \"warn\"")
  }
  (
    type: default-type,
    shape: default-shape,
    spacing: spacing,
    features: features,
  )
}

#let validate-settings(value) = {
  if type(value) != dictionary {
    fail("invalid internal presentation settings")
  }
  if (
    value.keys().sorted() != ("features", "shape", "spacing", "type")
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
