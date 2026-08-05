// One deck body, shared by every theme in the tour. The five tour files differ
// only in which facade they import, so whatever changes between their rendered
// slides is exactly what a theme owns.
#let info = (
  title: [Bootstrapping the Median],
  subtitle: [Resampling without a closed form],
  date: [March 2026],
)

#let deck(m) = {
  m.slide(layout: m.layouts.title(), numbered: false)
}
