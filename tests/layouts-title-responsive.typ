#import "@local/mosaic:0.0.1" as mosaic

#let paper = sys.inputs.at("paper", default: "16-9")
#let appearance = sys.inputs.at("appearance", default: "light")
#show: mosaic.setup.with(
  paper: paper,
  overflow: "warn",
)
#show: body => {
  if appearance == "dark" {
    set page(fill: rgb("#111827"))
    set text(fill: rgb("#f3f4f6"))
  }
  body
}

#let ccp = (id: "ccp", name: [Centre for Comparative Politics])
#let eis = (id: "eis", name: [European Institute for Social Data])
#let lpe = (id: "lpe", name: [Laboratory for Public Evidence])
#let eamc = (id: "eamc", name: [East Asia Methods Centre])

#mosaic.slide(layout: mosaic.layouts.title(
  [When measurement choices change substantive conclusions],
  variant: "academic",
  subtitle: [Evidence from a coordinated replication],
  authors: (
    mosaic.layouts.author([Priya Nair], affiliations: (ccp,)),
    mosaic.layouts.author([Elena García], affiliations: (eis,)),
    mosaic.layouts.author([Noah Williams], affiliations: (ccp,)),
    mosaic.layouts.author([Fatima El-Sayed], affiliations: (lpe,)),
    mosaic.layouts.author([Lucas Moreau], affiliations: (eis,)),
    mosaic.layouts.author([Mei Chen], affiliations: (eamc,)),
    mosaic.layouts.author([Samuel Okafor], affiliations: (lpe,)),
    mosaic.layouts.author([Amina Diallo], affiliations: (ccp,)),
  ),
  date: [Toronto · July 2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  [Compact academic metadata],
  variant: "academic",
  subtitle: [An explicit inline author layout],
  authors: (
    mosaic.layouts.author([Priya Nair], affiliations: (ccp,)),
    mosaic.layouts.author([Elena García], affiliations: (eis,)),
  ),
  date: [Toronto · July 2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  [When public data disappears],
  variant: "left-aligned",
  subtitle: [Open Data Day 2027 · What disappearing archives teach us about reproducibility],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock], affiliations: (ccp,)),),
  date: [March 2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  [Models, evidence, and public decisions],
  variant: "centered-stack",
  subtitle: [Annual Research Lecture · A public conversation about uncertainty],
  authors: (mosaic.layouts.author([Maya Thompson], affiliations: (eis,)),),
  date: [2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  [From raw data to publication],
  variant: "accent-block",
  subtitle: [Hands-on session · Build and publish a reproducible report],
  authors: (mosaic.layouts.author([Facilitator · Jordan Lee]),),
))

#mosaic.slide(layout: mosaic.layouts.title(
  [Measuring environmental change],
  variant: "image-right",
  image: (path: path("/docs/assets/images/title-river.webp"), alt: "Autumn wetlands"),
  subtitle: [Field observations across twelve sites],
  authors: (mosaic.layouts.author([River Systems Group]),),
))

#mosaic.slide(layout: mosaic.layouts.title(
  [Measuring environmental change],
  variant: "image-bottom",
  image: (path: path("/docs/assets/images/title-river.webp"), alt: "Autumn wetlands"),
  subtitle: [Field observations from the St. Lawrence wetlands],
  authors: (mosaic.layouts.author([River Systems Group]),),
  rule: true,
))

#[
  // Light-on-dark composition: a scoped label rule recolors the title cell.
  #show label("mosaic-cell-title"): set text(fill: white)
  #mosaic.slide(
    layout: mosaic.layouts.title(
      [Cities after dark],
      variant: "image-background",
      image: mosaic.components.image(
        path("/docs/assets/images/title-city.webp"),
        darken: 45%,
        alt: "Coastal city lights at night",
      ),
      align: left + bottom,
      subtitle: [Public lecture · Infrastructure, evidence, and life after sunset],
      authors: (mosaic.layouts.author([Amara Johnson], orcid: "0000-0001-2345-6789"),),
      date: [Montréal · October 2027],
    ),
  )
]

#mosaic.slide(layout: mosaic.layouts.title(
  [Cities after dark, unadjusted],
  variant: "image-background",
  image: (path: path("/docs/assets/images/title-city.webp"), alt: "Coastal city lights at night"),
  align: top + right,
  subtitle: [The same background with the ordinary document text color],
))
