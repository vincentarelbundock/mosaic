// A custom theme is imported as the active Mosaic facade.
#import "/docs/examples/embedded/appearance/_starter-theme.typ" as m

#show: m.setup

#m.slide(
  grid: m.layouts.title(
    title: [A starter theme],
    subtitle: [A small facade over Mosaic],
  ),
  numbered: false,
)

== The whole theme stays structural

#m.steps.reveal[
  - `setup` specializes Mosaic's document wrapper.
  - `layouts` returns ordinary layout recipes.
  - Visual tokens remain private implementation details.
]

#m.slide(
  grid: m.layouts.section(),
  content: (section: [That is all there is]),
  section: true,
  numbered: false,
)
