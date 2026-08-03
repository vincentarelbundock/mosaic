// Exact callable Cream layout namespace.
#import "../layouts-common.typ" as _common
#import "tokens.typ" as _tokens
#import "../../author.typ": author

#let content = _common.content
#let title(..args) = _common.title(auto, ..args)
#let section(subtitle: none) = _common.section(_tokens.white, subtitle: subtitle)
