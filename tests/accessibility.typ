// The tagged-PDF contract, one theme per `--input theme=` value: the title
// slide opens the structure tree at H1 so a deck of `==` slides never skips a
// heading level, theme chrome (folio, statusline, progress) and mono's `$`
// prompt are artifacts rather than announced content, and components export
// cleanly. The test runner compiles this fixture under `--pdf-standard ua-1`
// for every theme and reads the structure elements and marked-content
// operators straight out of the PDF bytes.
#import "@local/mosaic:0.0.2" as mosaic

#let theme = sys.inputs.at("theme", default: "default")
#let m = (
  default: mosaic.themes.default,
  editorial: mosaic.themes.editorial,
  metropolis: mosaic.themes.metropolis,
  manifesto: mosaic.themes.manifesto,
  mono: mosaic.themes.mono,
).at(theme)

#show: m.setup.with(
  title: [Accessible export],
  subtitle: [Tagged structure],
  authors: [Ada Lovelace],
  date: [2026-09-01],
)

#m.slide(layout: "title")

== Header

== Components

#m.components.callout(title: [Note])[A callout exports as content.]
