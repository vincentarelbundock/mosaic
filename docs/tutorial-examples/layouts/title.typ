#import "@local/mosaic:0.0.1" as m
#import "../../_includes/title-fixtures.typ": dashboard, mark
#show: m.setup

#let ccp = (id: "ccp", name: [Centre for Comparative Politics])
#let eis = (id: "eis", name: [European Institute for Social Data])
#let lpe = (id: "lpe", name: [Laboratory for Public Evidence])
#let eamc = (id: "eamc", name: [East Asia Methods Centre])
#let udem = (id: "udem", name: [Université de Montréal])
#let civic = (id: "civic", name: [Institute for Civic Statistics])

#m.slide(grid: m.layouts.title(
  [Compact academic metadata],
  variant: "academic",
  subtitle: [An inline scholarly title layout],
  authors: (
    m.author(
      [Priya Nair],
      affiliations: (ccp, eis),
      email: "priya.nair@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    m.author([Elena García], affiliations: (eis,)),
  ),
  date: [Toronto · July 2027],
))

#m.slide(
  grid: m.layouts.title(
    [When public data disappears],
    variant: "left-aligned",
    subtitle: [What twelve disappearing archives teach us about reproducibility],
    authors: (m.author([Vincent Arel-Bundock], affiliations: (udem,)),),
    date: [March 2027],
  ),
  foreground: [
    #place(top + left)[#mark([OPEN DATA DAY], rgb("#2563eb"))]
    #place(top + right)[#mark([MOSAIC LAB], rgb("#0f766e"))]
  ],
)

#m.slide(grid: m.layouts.title(
  [Models, evidence, and public decisions],
  variant: "centered-stack",
  subtitle: [Annual Research Lecture · A public conversation about uncertainty],
  authors: (m.author([Maya Thompson], affiliations: (civic,)),),
  date: [2027],
))

#m.slide(grid: m.layouts.title(
  [Solid accent block],
  variant: "accent-block",
  subtitle: [A solid color spine; no image],
  authors: (m.author([Variant · accent-block]),),
))

#m.slide(grid: m.layouts.title(
  [Image on the right],
  variant: "image-right",
  image: dashboard,
  subtitle: [Text leads; the visual follows],
  authors: (m.author([Variant · image-right]),),
))

#m.slide(grid: m.layouts.title(
  [Image on the left],
  variant: "image-left",
  image: dashboard,
  subtitle: [The visual leads; text follows],
  authors: (m.author([Variant · image-left]),),
))

#m.slide(grid: m.layouts.title(
  [Measuring environmental change],
  variant: "image-top",
  image: (
    path: path("/docs/assets/images/title-river.webp"),
    alt: "Aerial view of winding channels through autumn wetlands",
  ),
  subtitle: [Field observations from the St. Lawrence wetlands],
  authors: (m.author([River Systems Group]),),
))

#m.slide(grid: m.layouts.title(
  [Wetlands from above],
  variant: "image-bottom",
  image: (
    path: path("/docs/assets/images/title-river.webp"),
    alt: "Aerial view of winding channels through autumn wetlands",
  ),
  subtitle: [A landscape-first account of changing habitats],
  authors: (m.author([River Systems Group]),),
))

// The image itself carries the contrast: darken it and switch the title
// cell to light text through its <mosaic-cell-title> label, scoped to this
// slide.
#[
  #show label("mosaic-cell-title"): set text(fill: white)
  #m.slide(grid: m.layouts.title(
    [Cities after dark],
    variant: "image-background",
    image: m.image(
      path("/docs/assets/images/title-city.webp"),
      darken: 45%,
      alt: "Coastal city lights at night with dark sky and water to the left",
    ),
    align: top + left,
    subtitle: [Public lecture · Infrastructure, evidence, and life after sunset],
    authors: (m.author([Amara Johnson], orcid: "0000-0001-2345-6789"),),
    date: [Montréal · October 2027],
  ))
]
