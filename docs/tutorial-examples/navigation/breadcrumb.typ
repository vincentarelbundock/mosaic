#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#let breadcrumb() = context {
  let section = m.current-heading()
  let slide = m.current-heading(level: 2)
  if section != none {
    let parts = (link(section.location(), section.body),)
    if slide != none {
      parts.push(slide.body)
    }
    parts.join([ › ])
  }
}

#m.deck(
  foreground: [
    #place(top + right)[
      #pad(top: 0.9em, right: 1.35em)[
        #text(size: 0.65em, fill: luma(35%))[#breadcrumb()]
      ]
    ]
  ],
)

= Methods

== Data

Describe the observations.

== Model

Explain the model.
