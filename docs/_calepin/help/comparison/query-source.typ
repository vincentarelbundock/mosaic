#import "/_calepin/calepin.typ" as calepin
#set document(title: [Mosaic and Touying])
#metadata((
  title: "Mosaic and Touying",
  description: "How Mosaic's grid-and-native-rules approach differs from Touying's theme configuration.",
  tags: ("help", "questions"),
)) <website-metadata>

#title()

#link("https://github.com/touying-typ/touying")[Touying] and Mosaic both create presentations in Typst. Touying centers its workflow on themes and their configuration options. Mosaic centers its workflow on named grid cells and native Typst `set` and `show` rules. Touying is a good fit when an existing theme already matches the presentation. Mosaic is a good fit when you want to compose and style slides directly.

#table(
  columns: (auto, 1fr, 1fr),
  inset: 0.5em,
  table.header([Concern], [Mosaic], [Touying]),
  [Layout], [Composable grid trees], [Theme-defined structures],
  [Styling], [Native Typst rules], [Framework configuration],
  [Custom slides], [Ordinary functions and grids], [Theme methods receiving framework state],
  [Page control], [Native `set page`], [`config-page`; direct `set page` reserved],
)

Mosaic's incremental commands were heavily influenced by Touying, and parts of its counter freezing and cell fitting are adapted from it. The #link("../acknowledgments.html")[Acknowledgments] page records those debts in full.
