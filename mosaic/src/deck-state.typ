// Deck runtime state and internal logical-slide numbering.
#let layouts-state = state("mosaic:0.0.1:layouts", (:))
#let logical-slide = counter("mosaic:0.0.1:logical-slide")
#let logical-slide-id = counter("mosaic:0.0.1:logical-slide-id")
#let logical-section = counter("mosaic:0.0.1:logical-section")
