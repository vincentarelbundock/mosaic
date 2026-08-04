// Callable Cream layout namespace: base layouts with Cream defaults.
#import "../../layout/api.typ" as _base
#import "../../author.typ": author
#import "tokens.typ" as _tokens

#let content = _base.content.with(variant: "header-body")
#let title = _base.title
#let section = _base.section.with(accent: _tokens.white)
#let image = _base.image
