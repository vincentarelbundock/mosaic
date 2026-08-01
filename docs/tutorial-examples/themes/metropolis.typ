#import "@local/mosaic:0.0.1" as m
#import "/docs/tutorial-examples/themes/_content.typ": points, title-info

#let theme = m.themes.metropolis

#show: theme.apply

#theme.title(..title-info)

== Grids compose

#points

#theme.section([Where next?])
