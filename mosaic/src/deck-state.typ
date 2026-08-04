// Deck runtime state and internal logical-slide numbering.
#import "shared.typ": key

#let layouts-state = state(key("layouts"), (:))
#let logical-slide = counter(key("logical-slide"))
#let logical-slide-id = counter(key("logical-slide-id"))
#let logical-section = counter(key("logical-section"))
