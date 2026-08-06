#import "@preview/mosaic:0.0.1" as m

#show: m.setup.with(
  background: [SETUP BACKGROUND],
  foreground: [#place(top + right)[SETUP LOGO]],
)

#m.slide[INHERITED PLANES]

#m.slide(layout: m.layouts.title(title: [TITLE WITH DEFAULT PLANES]), numbered: false)

#m.slide(
  background: none,
  foreground: none,
)[SUPPRESSED PLANES]

#m.slide(
  background: [LOCAL BACKGROUND],
  foreground: [#place(top + right)[LOCAL FOREGROUND]],
)[OVERRIDDEN PLANES]

#context assert(counter(page).final().first() == 4)
