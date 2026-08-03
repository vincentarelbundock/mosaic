// Exact callable Minimalist layout namespace.
#import "../layouts-common.typ" as _common
#import "../../author.typ": author

#let content = _common.content
#let title(..args) = _common.title(auto, ..args)
#let section(subtitle: none) = _common.section(auto, subtitle: subtitle)
