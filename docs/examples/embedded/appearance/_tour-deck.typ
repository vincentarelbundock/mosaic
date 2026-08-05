// One deck body, shared by every example on the Themes page. The wrappers differ
// only in which theme they import, so whatever changes between their rendered
// slides is exactly what a theme owns.
//
// `deck` is the only export: the slides, called with the active theme facade
// as `m`. The deck metadata rides on the title slide, so a wrapper needs no
// second import.
#import "@local/mosaic:0.0.1": layouts
#let author = layouts.author

// The title and section slides name their layout rather than building one, so
// they follow whatever `setup(layouts:)` configured for the deck.
#let deck(m) = {
  m.slide(
    "title",
    numbered: false,
    title: [Bootstrapping the Median],
    subtitle: [Resampling without a closed form],
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
    The sample median has no convenient variance formula, so its standard error
    is easier to resample than to derive.

    - Draw ten thousand samples with replacement.
    - Take the median of each.
    - Read the interval off the resampled distribution.
  ]

  m.slide("section", cells: (section: [The estimator]))

  m.slide(layout: m.layouts.content(variant: "header-body", columns: 2))[
    == Two ways to read the draws
  ][
    *Percentile*

    - Sort the resampled medians.
    - Cut at 2.5% and 97.5%.
    - Report the two endpoints.
  ][
    *Basic*

    - Center the draws on the estimate.
    - Reflect them through it.
    - Report the reflected quantiles.
  ]

  m.slide(layout: m.layouts.content(variant: "header-body"))[
    == One pass of the bootstrap
  ][
    #raw(
      "def bootstrap(sample, draws):\n"
        + "    return [median(resample(sample))\n"
        + "            for _ in range(draws)]",
      block: true,
      lang: "python",
    )

    #m.components.callout(role: "warning", title: [Caveat])[
      Coverage degrades when the statistic is not pivotal.
    ]
  ]

  // A second section, so the section-aware themes show movement: the
  // metropolis bars advance, the mono toc gains an entry, and the numbered
  // section variants count up.
  m.slide("section", cells: (section: [In practice]))

  m.slide(
    layout: m.layouts.image(
      (
        path: path("/docs/assets/images/dog.webp"),
        alt: "A dog resting on a sunlit floor",
      ),
      variant: "right",
    ),
    cells: (
      header: [== A well-behaved sample],
      body: [
        Resampling assumes the draws are exchangeable. This one is not moving.
      ],
    ),
  )

  m.slide(layout: m.layouts.content(variant: "header-body", columns: 2))[
    == What it costs
  ][
    #table(
      columns: (1fr, auto),
      stroke: (x, y) => if y == 0 { (bottom: 0.5pt) },
      [Draws], [Time],
      [1 000], [0.4 s],
      [10 000], [3.9 s],
    )
  ][
    #m.components.badge(role: "accent")[stable]

    #m.components.badge(role: "warning")[draft]

    #m.components.badge(role: "error")[deprecated]
  ]
}
