#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  content: (
    background: [SETUP BACKGROUND],
    foreground: [#place(top + right)[SETUP LOGO]],
  ),
)

#m.slide[INHERITED PLANES]

#m.slide(layout: m.layouts.title(title: [TITLE WITH DEFAULT PLANES]), numbered: false)

#m.slide(
  content: (
    background: none,
    foreground: none,
  ),
)[SUPPRESSED PLANES]

#m.slide(
  content: (
    background: [LOCAL BACKGROUND],
    foreground: [#place(top + right)[LOCAL FOREGROUND]],
  ),
)[OVERRIDDEN PLANES]

#context assert(counter(page).final().first() == 4)
