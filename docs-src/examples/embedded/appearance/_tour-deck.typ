// One deck body, shared by every example on the Themes page. The wrappers differ
// only in which theme they import, so whatever changes between their rendered
// slides is exactly what a theme owns.
//
// `deck` is the only export: the slides, called with the active theme facade
// as `m`. The deck metadata rides on the title slide, so a wrapper needs no
// second import.
#import "@preview/mosaic:0.0.1": layouts
#let author = layouts.author

// The title and section slides name their layout rather than building one, so
// they follow whatever `setup(layouts:)` configured for the deck.
#let deck(m) = {
  m.slide(
    "title",
    numbered: false,
    title: [The Optimal Number of Naps],
    subtitle: [Findings from a subject who slept through the study],
    date: [March 2026],
    authors: (
      author(
        "Ada Lovelace",
        affiliations: ([Institute for Applied Statistics], [Analytical Society]),
        orcid: "0000-0002-1825-0097",
      ),
      author(
        "Charles Babbage",
        affiliations: ([Analytical Society],),
        orcid: "0000-0001-5109-3700",
      ),
    ),
  )

  m.slide(layout: m.layouts.content(variant: "header-body"))[
    == The problem
  ][
    Nobody agrees on how many naps a day is correct. We asked the only expert on
    the subject and he fell asleep during the question.

    - Recruit one dog.
    - Watch him for a week.
    - Write down every time he stops moving.
  ]

  m.slide("section", cells: (section: [The instrument]))

  m.slide(layout: m.layouts.content(variant: "header-body", columns: 2))[
    == Two ways to count a nap
  ][
    *Strict*

    - Eyes fully closed.
    - Tail completely still.
    - Survives one doorbell.
  ][
    *Generous*

    - Eyes mostly closed.
    - Tail negotiable.
    - He looks comfortable, so it counts.
  ]

  m.slide(layout: m.layouts.content(variant: "header-body"))[
    == One pass of the counter
  ][
    #raw(
      "def count_naps(dog, hours):\n"
        + "    return [h for h in hours\n"
        + "            if dog.is_horizontal(h)]",
      block: true,
      lang: "python",
    )

    #m.components.callout(role: "warning", title: [Caveat])[
      Sitting upright with both eyes closed remains contested.
    ]
  ]

  // A second section, so the section-aware themes show movement: the
  // metropolis bars advance, the mono toc gains an entry, and the numbered
  // section variants count up.
  m.slide("section", cells: (section: [In practice]))

  m.slide(
    layout: m.layouts.image(
      (
        path: path("/docs-src/assets/images/dog.webp"),
        alt: "A dog resting on a sunlit floor",
      ),
      variant: "right",
    ),
    cells: (
      header: [== A well-behaved subject],
      body: [
        The method requires a subject who stays put. This one is world class.
      ],
    ),
  )

  m.slide(layout: m.layouts.content(variant: "header-body", columns: 2))[
    == What it costs him
  ][
    #table(
      columns: (1fr, auto),
      stroke: (x, y) => if y == 0 { (bottom: 0.5pt) },
      [Naps], [Hours],
      [3], [4.1],
      [11], [9.8],
    )
  ][
    #m.components.badge(role: "accent")[asleep]

    #m.components.badge(role: "warning")[stirring]

    #m.components.badge(role: "error")[doorbell]
  ]
}
