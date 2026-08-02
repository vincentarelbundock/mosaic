#import "../mosaic/src/settings.typ": make-settings, validate-settings

#let settings = make-settings()
#assert(settings.keys().sorted() == ("features", "shape", "spacing", "type"))
#assert(settings.features.keys().sorted() == (
  "footer", "logo", "overflow", "progress", "slide-number", "slide-total",
))
#assert(validate-settings(settings) == settings)
