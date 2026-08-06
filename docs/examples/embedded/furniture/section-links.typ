#import "@preview/mosaic:0.0.1" as m

#let section-links() = context {
  let sections = query(heading.where(level: 1, outlined: true))
  let preceding = query(
    heading.where(level: 1, outlined: true).before(here()),
  )
  let current = if preceding.len() > 0 { preceding.last() }
  sections.map(section => {
    let active = (
      current != none
        and current.location() == section.location()
    )
    link(
      section.location(),
      box(
        inset: (x: 0.7em, y: 0.3em),
        radius: 0.3em,
        fill: if active { blue.lighten(85%) } else { luma(94%) },
        text(
          weight: if active { "bold" } else { "regular" },
          section.body,
        ),
      ),
    )
  }).join(h(0.35em))
}

#show: m.setup.with(
  foreground: [
    #place(bottom + center)[
      #pad(bottom: 0.7em)[#section-links()]
    ]
  ],
)
#set text(size: 22pt)

= Methods

= Results

= Discussion
