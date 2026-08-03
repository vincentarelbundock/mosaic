// Named arguments on `slide` refine the configured layout: the fields the
// theme set survive, and only the named ones are replaced.
#import "@local/mosaic:0.0.1" as mosaic

#let configured-accent = rgb("#654321")

#show: mosaic.setup.with(
  title: [Field overlay],
  subtitle: [Configured subtitle],
  authors: (mosaic.layouts.author([Ada], affiliations: ((id: "a", name: [Institute A]),)),),
  date: [July 2027],
  layouts: (
    content: mosaic.layouts.content(variant: "header-body"),
    title: mosaic.layouts.title(variant: "accent-block", accent: configured-accent),
    section: mosaic.layouts.section(accent: configured-accent),
  ),
)

// The variant changes; the configured accent is still the one drawn.
#mosaic.slide(layout: "title", variant: "academic")
#mosaic.slide(layout: "section", number: [07])[Overlaid section]
// `layout: auto` overlays onto the configured content layout.
#mosaic.slide(columns: 2)[Left column][Right column]
