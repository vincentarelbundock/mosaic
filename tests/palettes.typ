// The curated palette collection composes with any theme: every facade
// exports `palettes`, each entry is the flat eight-color dictionary that
// `setup(colors: ..)` accepts, and polarity-sensitive rules branch on the
// canvas each palette supplies. This deck runs a dark scheme through the
// editorial theme, exercises components and syntax highlighting on it, and
// inverts one slide, which is the combination the palette contract in
// tests/test_palettes.py exists to keep legible.
#import "@local/mosaic:0.0.1" as m
#import m.themes.editorial: setup, slide, layouts, components, palettes

// The collection is one namespace on every facade: the polarity pair reached
// through the editorial facade is the same value the root facade exports, and
// `palettes` is the only namespace that names it.
#assert(palettes.light == m.palettes.light)
#assert(palettes.dark == m.palettes.dark)
#assert(palettes.espresso.keys() == palettes.light.keys())

#show: setup.with(
  colors: palettes.espresso,
  title: [Night Service],
  subtitle: [Operations after dark],
  date: [2026],
)

#slide(layout: layouts.title())

#slide(layout: layouts.content(variant: "header-body"))[
  Rollout plan
][
  - Freeze the queue
  - Drain the workers

  #raw("systemctl restart worker", lang: "bash", block: true)

  #components.callout(title: [Status], role: "warning")[
    The standby region stays warm through the window.
  ]
]

#slide(invert: true)[
  One inverted slide keeps the accent and status colors while the ground
  swaps to the palette's text color.
]

#context assert(counter(page).final().first() == 3)
