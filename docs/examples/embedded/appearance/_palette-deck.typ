// One deck body, shared by every palette example on the Colors page. The wrappers all
// import the default theme and differ only in the palette their `colors:` line
// passes, so whatever changes between their rendered slides is exactly what a
// palette owns. Each slide leans on a different part of the palette: the title
// on canvas, ink, and line; the content slide on muted text, accent markers,
// the syntax theme, and a warning callout; the section on the accent rule; the
// components slide on surface panels and the three roles; and the last slide
// inverts, showing the swap `slide(invert: true)` performs within the active
// palette.
#import "@preview/mosaic:0.0.1": layouts
#let author = layouts.author

#let deck(m) = {
  m.slide(
    "title",
    numbered: false,
    title: [Reading the Tides],
    subtitle: [A season of gauge records],
    date: [March 2026],
    authors: (
      author(
        "Ada Lovelace",
        affiliations: ([Coastal Observatory],),
      ),
    ),
  )

  m.slide(layout: m.layouts.content(variant: "header-body"))[
    == The gauge record
  ][
    - Harmonic fit for the astronomical tide.
    - Residuals carry the weather.

    #raw(
      "surge = level - harmonic_fit(level)",
      block: true,
      lang: "python",
    )

    #m.components.callout(role: "warning", title: [Gaps])[
      The 2007 season is missing six weeks.
    ]
  ]

  m.slide("section", cells: (section: [The surge component]))

  m.slide(layout: m.layouts.content(variant: "header-body", columns: 2))[
    == Station summary
  ][
    #table(
      columns: (1fr, auto),
      stroke: (x, y) => if y == 0 { (bottom: 0.5pt) },
      [Station], [Trend],
      [North pier], [+2.1 mm/yr],
      [Harbor mouth], [+1.8 mm/yr],
    )
  ][
    #m.components.badge(role: "accent")[calibrated]

    #m.components.badge(role: "warning")[drifting]

    #m.components.badge(role: "error")[offline]

    #m.components.card(width: 100%, inset: 1em)[
      *Next survey.* The spring tide window.
    ]
  ]

  m.slide(invert: true)[
    One inverted slide for the headline number: canvas and text swap within
    the same palette, and the accent and status colors carry over unchanged.

    #m.components.badge(role: "accent")[+2.0 mm/yr]
  ]
}
