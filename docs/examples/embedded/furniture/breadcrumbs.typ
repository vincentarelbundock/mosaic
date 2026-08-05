#import "@local/mosaic:0.0.1" as m

#let active-heading(level) = {
  let headings = query(
    heading.where(level: level, outlined: true).before(here()),
  )
  if headings.len() > 0 { headings.last() }
}

#let breadcrumb() = context {
  let section = active-heading(1)
  let slide = active-heading(2)
  if section != none {
    let parts = (link(section.location(), section.body),)
    if slide != none {
      parts.push(slide.body)
    }
    parts.join([ › ])
  }
}

#show: m.setup.with(
  foreground: [
    #place(top + right)[
      #pad(top: 0.9em, right: 1.35em)[
        #text(size: 0.65em, fill: luma(35%))[#breadcrumb()]
      ]
    ]
  ],
)
#set text(size: 22pt)

= Methods

== Data

Describe the observations.

== Model

Explain the model.
