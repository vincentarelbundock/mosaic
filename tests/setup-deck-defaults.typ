#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  default-grid: m.grid.cell("main"),
  section-grid: m.grid.cell("section"),
  background: [SETUP BACKGROUND],
  foreground: [SETUP FOREGROUND],
)

#m.slide(content: (main: [EXPLICIT BODY]))

= AUTOMATIC SECTION
