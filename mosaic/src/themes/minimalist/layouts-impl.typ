#import "../layouts-common.typ" as common
#import "tokens.typ" as tokens

#let default = common.default
#let title(..args) = common.title(tokens.red, ..args)
#let section(subtitle: none) = common.section(tokens.red, subtitle: subtitle)
