#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let ccp = [Centre for Comparative Politics]
#let eis = [European Institute for Social Data]
#let lpe = [Laboratory for Public Evidence]
#let eamc = [East Asia Methods Centre]
#let civic = [Institute for Civic Statistics]

#m.slide(layout: m.layouts.title(
  title: [Compact academic metadata],
  variant: "academic",
  subtitle: [An inline scholarly title layout],
  authors: (
    m.layouts.author(
      [Priya Nair],
      affiliations: (ccp, eis),
      email: "priya.nair@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    m.layouts.author([Elena García], affiliations: (eis,)),
  ),
  date: [Toronto · July 2027],
))

#m.slide(layout: m.layouts.title(
  title: [Models, evidence, and public decisions],
  variant: "centered",
  subtitle: [Annual Research Lecture · A public conversation about uncertainty],
  authors: (m.layouts.author([Maya Thompson], affiliations: (civic,)),),
  date: [2027],
))

#m.slide(layout: m.layouts.title(
  title: [Models, evidence, and public decisions],
  variant: "plate",
  subtitle: [Annual Research Lecture · A public conversation about uncertainty],
  authors: (m.layouts.author([Maya Thompson], affiliations: (civic,)),),
  date: [2027],
))

#m.slide(layout: m.layouts.title(
  title: [Models, evidence, and public decisions],
  variant: "bordered",
  subtitle: [Annual Research Lecture],
  authors: (m.layouts.author([Maya Thompson], affiliations: (civic,)),),
  date: [2027],
))

#m.slide(layout: m.layouts.title(
  title: [Image on the right],
  variant: "image-right",
  image: (path: path("/docs/assets/images/dog.webp"), alt: "Dog"),
  subtitle: [Text leads; the visual follows],
  authors: (m.layouts.author([Variant · image-right]),),
))

#m.slide(layout: m.layouts.title(
  title: [Image on the left],
  variant: "image-left",
  image: (path: path("/docs/assets/images/dog.webp"), alt: "Dog"),
  subtitle: [The visual leads; text follows],
  authors: (m.layouts.author([Variant · image-left]),),
))

#m.slide(layout: m.layouts.title(
  title: [Measuring environmental change],
  variant: "image-top",
  image: (
    path: path("/docs/assets/images/title-river.webp"),
    alt: "Aerial view of winding channels through autumn wetlands",
  ),
  subtitle: [Field observations from the St. Lawrence wetlands],
  authors: (m.layouts.author([River Systems Group]),),
))

#m.slide(layout: m.layouts.title(
  title: [Wetlands from above],
  variant: "image-bottom",
  image: (
    path: path("/docs/assets/images/title-river.webp"),
    alt: "Aerial view of winding channels through autumn wetlands",
  ),
  subtitle: [A landscape-first account of changing habitats],
  authors: (m.layouts.author([River Systems Group]),),
))

// The photograph is already dark where the text sits, so no scrim is needed:
// switching the title cell to light text through its <mosaic-cell-title>
// label, scoped to this slide, is enough.
#[
  #show label("mosaic-cell-title"): set text(fill: white)
  #m.slide(layout: m.layouts.title(
    title: [Cities after dark],
    variant: "image-background",
    image: (
      path: path("/docs/assets/images/title-city.webp"),
      alt: "Coastal city lights at night with dark sky and water to the left",
    ),
    align: top + left,
    subtitle: [Public lecture · Infrastructure, evidence, and life after sunset],
    authors: (m.layouts.author([Amara Johnson], orcid: "0000-0001-2345-6789"),),
    date: [Montréal · October 2027],
  ))
]
