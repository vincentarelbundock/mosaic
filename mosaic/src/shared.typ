// Values and helpers shared by all internal Mosaic modules.
#let tag = "mosaic:0.0.1"

// Every internal state, counter, and metadata key is built from `tag`, so the
// namespace and its version bump in one place. Spelling a key literally would
// let a partial bump leave two versions addressing the same deck, which reads
// as silently empty state rather than as an error.
#let key(name) = tag + ":" + name

#let fail(message) = assert(false, message: "mosaic: " + message)

// Typst's structural element functions have no public constructors.
#let typst-sequence = [].func()
#let typst-styled = text(red)[].func()
#let typst-space = [ ].func()

#let valid-path(value) = type(value) == path or (
  type(value) == str and value != ""
)

// A scrim is an ordinary Typst paint, so it accepts exactly what a `fill`
// accepts and needs no Mosaic-specific vocabulary of its own. One validator
// serves both the component and every layout that carries an image, so the
// spelling cannot drift between them.
#let valid-paint(value) = type(value) in (color, gradient, tiling)

#let validate-scrim(value, subject) = {
  if value != none and not valid-paint(value) {
    fail(subject + " scrim must be a color, gradient, or tiling")
  }
  value
}

#let require-dictionary(value, name) = {
  if type(value) != dictionary {
    fail(name + " must be a dictionary")
  }
  none
}

#let reject-unknown-keys(value, allowed, name) = {
  let unknown = value.keys().filter(key => key not in allowed)
  if unknown.len() > 0 {
    fail(name + " does not accept " + repr(unknown.first()))
  }
  none
}

#let array-max(values, default: 1) = if values.len() == 0 {
  default
} else {
  calc.max(..values)
}
