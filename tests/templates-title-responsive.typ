#import "@local/mosaic:0.0.1" as mosaic

#let paper = sys.inputs.at("paper", default: "16-9")
#let scheme = sys.inputs.at("scheme", default: "light")
#show: mosaic.setup.with(
  paper: paper,
  colors: mosaic.color.scheme(scheme),
  features: (overflow: "warn"),
)

#let ccp = (id: "ccp", name: [Centre for Comparative Politics])
#let eis = (id: "eis", name: [European Institute for Social Data])
#let lpe = (id: "lpe", name: [Laboratory for Public Evidence])
#let eamc = (id: "eamc", name: [East Asia Methods Centre])

#mosaic.slide(grid: mosaic.templates.title(
  variant: "academic",
  subtitle: [Evidence from a coordinated replication],
  authors: (
    mosaic.author([Priya Nair], affiliations: (ccp,)),
    mosaic.author([Elena García], affiliations: (eis,)),
    mosaic.author([Noah Williams], affiliations: (ccp,)),
    mosaic.author([Fatima El-Sayed], affiliations: (lpe,)),
    mosaic.author([Lucas Moreau], affiliations: (eis,)),
    mosaic.author([Mei Chen], affiliations: (eamc,)),
    mosaic.author([Samuel Okafor], affiliations: (lpe,)),
    mosaic.author([Amina Diallo], affiliations: (ccp,)),
  ),
  date: [Toronto · July 2027],
))[When measurement choices change substantive conclusions]

#mosaic.slide(grid: mosaic.templates.title(
  variant: "academic",
  subtitle: [An explicit inline author layout],
  authors: (
    mosaic.author([Priya Nair], affiliations: (ccp,)),
    mosaic.author([Elena García], affiliations: (eis,)),
  ),
  date: [Toronto · July 2027],
))[Compact academic metadata]

#mosaic.slide(grid: mosaic.templates.title(
  variant: "left-aligned",
  subtitle: [Open Data Day 2027 · What disappearing archives teach us about reproducibility],
  authors: (mosaic.author([Vincent Arel-Bundock], affiliations: (ccp,)),),
  date: [March 2027],
))[When public data disappears]

#mosaic.slide(grid: mosaic.templates.title(
  variant: "centered-stack",
  subtitle: [Annual Research Lecture · A public conversation about uncertainty],
  authors: (mosaic.author([Maya Thompson], affiliations: (eis,)),),
  date: [2027],
))[Models, evidence, and public decisions]

#mosaic.slide(grid: mosaic.templates.title(
  variant: "accent-block",
  subtitle: [Hands-on session · Build and publish a reproducible report],
  authors: (mosaic.author([Facilitator · Jordan Lee]),),
))[From raw data to publication]

#mosaic.slide(grid: mosaic.templates.title(
  variant: "image-right",
  image: (path: path("/docs/assets/images/title-river.webp"), alt: "Autumn wetlands"),
  subtitle: [Field observations across twelve sites],
  authors: (mosaic.author([River Systems Group]),),
))[Measuring environmental change]

#mosaic.slide(grid: mosaic.templates.title(
  variant: "image-bottom",
  image: (path: path("/docs/assets/images/title-river.webp"), alt: "Autumn wetlands"),
  subtitle: [Field observations from the St. Lawrence wetlands],
  authors: (mosaic.author([River Systems Group]),),
))[Measuring environmental change]

#mosaic.slide(grid: mosaic.templates.title(
  variant: "image-background",
  image: (path: path("/docs/assets/images/title-city.webp"), alt: "Coastal city lights at night"),
  panel-align: left + bottom,
  subtitle: [Public lecture · Infrastructure, evidence, and life after sunset],
  authors: (mosaic.author([Amara Johnson], orcid: "0000-0001-2345-6789"),),
  date: [Montréal · October 2027],
))[Cities after dark]
