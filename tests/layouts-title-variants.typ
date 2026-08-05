#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test
#import "../mosaic/src/layout/resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings

// `base-size` is an observation, not a stored setting: `render-slide` reads it
// from the live context so composed title tiers track the active theme. A
// fixture that resolves layouts directly supplies it the same way.
#let settings = make-settings() + (base-size: 28pt)
#let image-path = path("/docs/assets/images/title-river.webp")
#let udem = [Universite de Montreal]
#let cirano = [CIRANO]
#let academic-authors = (
  mosaic.layouts.author([Ada Lovelace], affiliations: (udem, cirano)),
  mosaic.layouts.author([Grace Hopper], affiliations: (cirano,)),
  mosaic.layouts.author([Katherine Johnson], affiliations: (udem,)),
)

#let academic-command = mosaic.layouts.title(
  title: [A long academic title],
  variant: "academic",
  subtitle: [A multilevel analysis],
  authors: academic-authors,
  date: [July 2027],
)
#let academic = resolve-layout(academic-command, settings)
#assert(academic.kind == "split")
#assert(academic.axis == "height")
#assert(academic.tracks.at(0) == 1fr)
#assert(academic.tracks.slice(1).all(track => track == auto))
#assert(grid-test.count(academic) == 3)
#for id in ("title", "authors", "details") {
  assert(grid-test.info(academic, id).cell.id == id)
}
#assert(grid-test.info(academic, "title").cell.content != none)
#assert(grid-test.info(academic, "authors").cell.content != none)

#let structured-academic = resolve-layout(mosaic.layouts.title(
  title: [Structured authors],
  variant: "academic",
  authors: (
    mosaic.layouts.author(
      [Ada Lovelace],
      affiliations: (udem, cirano),
      email: "ada@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    mosaic.layouts.author(
      [Grace Hopper],
      affiliations: (cirano,),
    ),
  ),
), settings)
#assert(grid-test.count(structured-academic) == 3)
#for id in ("title", "authors", "details") {
  assert(grid-test.info(structured-academic, id).cell.id == id)
}

#let orcid-only = resolve-layout(mosaic.layouts.title(
  title: [ORCID only],
  variant: "academic",
  authors: (
    mosaic.layouts.author([Grace Hopper], orcid: "0000-0001-2345-6789"),
  ),
), settings)
#assert(grid-test.count(orcid-only) == 2)
#for id in ("title", "authors") {
  assert(grid-test.info(orcid-only, id).cell.id == id)
}

// `ruled` is the default variant, so an unnamed variant resolves the same
// single-cell composition an explicit `ruled` does.
#let ruled = resolve-layout(mosaic.layouts.title(
  title: [When public data disappears],
  variant: "ruled",
  subtitle: [Evidence from twelve public archives],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock], affiliations: (udem,)),),
  date: [March 2027],
), settings)
#assert(ruled.kind == "cell")
#assert(ruled.id == "title")
#assert(grid-test.count(ruled) == 1)

#let default-variant = resolve-layout(mosaic.layouts.title(
  title: [Bare title],
  authors: (),
  rule: false,
), settings)
#assert(default-variant.kind == "cell")
#assert(grid-test.count(default-variant) == 1)

#let centered = resolve-layout(mosaic.layouts.title(
  title: [Models and evidence],
  variant: "centered",
  subtitle: [Annual research lecture],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock]),),
), settings)
#assert(centered.kind == "cell")
#assert(grid-test.count(centered) == 1)

#let kicker = resolve-layout(mosaic.layouts.title(
  title: [Models and evidence],
  variant: "kicker",
  subtitle: [Annual research lecture],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock]),),
), settings)
#assert(kicker.kind == "cell")
#assert(grid-test.count(kicker) == 1)

#let panel = resolve-layout(mosaic.layouts.title(
  title: [Models and evidence],
  variant: "panel",
  subtitle: [Annual research lecture],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock]),),
), settings)
#assert(panel.kind == "split")
#assert(panel.axis == "width")
#assert(panel.children.at(0).id == "details")
#assert(panel.children.at(0).style.fill == settings.colors.text)
#assert(panel.children.at(1).id == "title")

#let bordered = resolve-layout(mosaic.layouts.title(
  title: [Models and evidence],
  variant: "bordered",
  authors: (mosaic.layouts.author([Vincent Arel-Bundock]),),
), settings)
#assert(bordered.kind == "cell")
#assert(grid-test.count(bordered) == 1)

#let split-right = resolve-layout(mosaic.layouts.title(
  title: [Measuring environmental change],
  variant: "image",
  position: "right",
  image: image-path,
), settings)
#assert(split-right.kind == "split")
#assert(split-right.axis == "width")
#assert(split-right.tracks == (3fr, 2fr))
#assert(split-right.children.at(0).kind == "cell")
#assert(split-right.children.at(1).id == "image")
#assert(grid-test.count(split-right) == 2)

// `position` defaults to `left`, so the image variant with no position is the
// left split.
#let split-left = resolve-layout(mosaic.layouts.title(
  title: [Measuring environmental change],
  variant: "image",
  image: image-path,
  tracks: (3fr, 2fr),
), settings)
#assert(split-left.tracks == (3fr, 2fr))
#assert(split-left.children.at(0).id == "image")
#assert(split-left.children.at(1).kind == "cell")

#let band = resolve-layout(mosaic.layouts.title(
  title: [Measuring environmental change],
  variant: "image",
  position: "top",
  image: image-path,
), settings)
#assert(band.kind == "split")
#assert(band.axis == "height")
#assert(band.tracks == (2fr, 3fr))
#assert(band.children.at(0).id == "image")
#assert(band.children.at(1).kind == "cell")
#assert(grid-test.count(band) == 2)

#show: mosaic.setup
#mosaic.slide(layout: academic-command)
