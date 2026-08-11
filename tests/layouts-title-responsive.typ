#import "@local/mosaic:0.0.2" as mosaic

#let paper = sys.inputs.at("paper", default: "16-9")
#let appearance = sys.inputs.at("appearance", default: "light")
#show: mosaic.setup.with(
  paper: paper,
  overflow: "record",
)
#show: body => {
  if appearance == "dark" {
    set page(fill: rgb("#111827"))
    set text(fill: rgb("#f3f4f6"))
  }
  body
}

#let ccp = [Centre for Comparative Politics]
#let eis = [European Institute for Social Data]
#let lpe = [Laboratory for Public Evidence]
#let eamc = [East Asia Methods Centre]

#mosaic.slide(layout: mosaic.layouts.title(
  title: [When measurement choices change substantive conclusions],
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
  title: [Compact academic metadata],
  variant: "academic",
  subtitle: [An explicit inline author layout],
  authors: (
    mosaic.layouts.author([Priya Nair], affiliations: (ccp,)),
    mosaic.layouts.author([Elena García], affiliations: (eis,)),
  ),
  date: [Toronto · July 2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  title: [When public data disappears],
  variant: "ruled",
  subtitle: [Open Data Day 2027 · What disappearing archives teach us about reproducibility],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock], affiliations: (ccp,)),),
  date: [March 2027],
))

// Several authors across several affiliations must stay composed in the
// ruled details tiers.
#mosaic.slide(layout: mosaic.layouts.title(
  title: [When public data disappears],
  variant: "ruled",
  subtitle: [Open Data Day 2027],
  authors: (
    mosaic.layouts.author([Priya Nair], affiliations: (ccp,)),
    mosaic.layouts.author([Elena García], affiliations: (eis,)),
    mosaic.layouts.author([Noah Williams], affiliations: (ccp,)),
    mosaic.layouts.author([Fatima El-Sayed], affiliations: (lpe,)),
  ),
  date: [March 2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  title: [Models, evidence, and public decisions],
  variant: "centered",
  subtitle: [Annual Research Lecture · A public conversation about uncertainty],
  authors: (mosaic.layouts.author([Maya Thompson], affiliations: (eis,)),),
  date: [2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  title: [Models, evidence, and public decisions],
  variant: "kicker",
  subtitle: [Annual Research Lecture · A public conversation about uncertainty],
  authors: (
    mosaic.layouts.author([Maya Thompson], affiliations: (eis,)),
    mosaic.layouts.author([Priya Nair], affiliations: (ccp,)),
  ),
  date: [2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  title: [Models, evidence, and public decisions],
  variant: "bordered",
  subtitle: [Annual Research Lecture],
  authors: (mosaic.layouts.author([Maya Thompson], affiliations: (eis,)),),
  date: [2027],
))

#mosaic.slide(layout: mosaic.layouts.title(
  title: [Measuring environmental change],
  variant: "image",
  position: "right",
  image: (path: path("/docs-src/assets/images/title-river.webp"), alt: "Autumn wetlands"),
  subtitle: [Field observations across twelve sites],
  authors: (mosaic.layouts.author([River Systems Group]),),
))

#mosaic.slide(layout: mosaic.layouts.title(
  title: [Measuring environmental change],
  variant: "image",
  position: "bottom",
  image: (path: path("/docs-src/assets/images/title-river.webp"), alt: "Autumn wetlands"),
  subtitle: [Field observations from the St. Lawrence wetlands],
  authors: (mosaic.layouts.author([River Systems Group]),),
  rule: true,
))
