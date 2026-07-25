#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#let section-links() = context {
  let current = m.current-heading()
  let sections = query(heading.where(level: 1, outlined: true))
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

#m.deck(
  foreground: [
    #place(bottom + center)[
      #pad(bottom: 0.7em)[#section-links()]
    ]
  ],
)

= Methods

= Results

= Discussion
