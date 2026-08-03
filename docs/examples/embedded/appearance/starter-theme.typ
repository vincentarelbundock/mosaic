// A custom theme is imported as the active Mosaic facade.
#import "/docs/examples/embedded/appearance/_starter-theme.typ" as m

#show: m.setup

#m.slide(
  layout: m.layouts.title(
    title: [A starter theme],
    subtitle: [A small facade over Mosaic],
  ),
)

== The whole theme stays structural

#m.steps.reveal[
  - `setup` binds one passive definition in the facade.
  - `layouts` owns its callable recipes directly.
  - Tokens and components are separate only when genuinely shared.
]

#m.slide(
  layout: m.layouts.section(),
  content: (section: [That is all there is]),
)
