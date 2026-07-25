// Values and helpers shared by all internal Mosaic modules.
#let tag = "mosaic:0.0.1"

#let fail(message) = assert(false, message: "mosaic: " + message)

#let valid-path(value) = type(value) == path or (
  type(value) == str and value != ""
)

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
