// The title information every variant example on the Title slides page renders.
// Three authors over two institutions, one of them shared, so the `academic`
// legend has something to number; every field of `layouts.author` is exercised.
#import "@preview/mosaic:0.0.1" as m

#let ccp = [Centre for Comparative Politics]
#let eis = [European Institute for Social Data]

#let info = (
  title: [The Optimal Number of Naps],
  subtitle: [Findings from a subject who slept through the study],
  authors: (
    m.layouts.author(
      [Priya Nair],
      affiliations: (ccp, eis),
      email: "priya.nair@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    m.layouts.author(
      [Elena García],
      affiliations: (eis,),
      orcid: "0000-0002-1825-0097",
    ),
    m.layouts.author(
      [Tomás Ferreira],
      affiliations: (ccp,),
      orcid: "0000-0003-4567-8901",
    ),
  ),
  date: [Toronto · July 2027],
)

#let river = (
  path: path("/docs/assets/images/title-river.webp"),
  alt: "Aerial view of winding channels through autumn wetlands",
)
