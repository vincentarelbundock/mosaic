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

#let swiss = resolve-layout(mosaic.layouts.title(
  title: [When public data disappears],
  variant: "swiss",
  subtitle: [Evidence from twelve public archives],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock], affiliations: (udem,)),),
  date: [March 2027],
), settings)
#assert(swiss.kind == "split")
#assert(swiss.axis == "height")
#assert(swiss.tracks == (1fr, auto))
#assert(grid-test.count(swiss) == 2)
#assert(grid-test.info(swiss, "title").cell.content != none)
#assert(grid-test.info(swiss, "details").cell.content != none)

// Without metadata and with the baseline rule suppressed, swiss collapses to
// the plain title mass.
#let bare-swiss = resolve-layout(mosaic.layouts.title(
  title: [Bare title],
  authors: (),
  rule: false,
), settings)
#assert(bare-swiss.kind == "cell")
#assert(grid-test.count(bare-swiss) == 1)

#let centered = resolve-layout(mosaic.layouts.title(
  title: [Models and evidence],
  variant: "centered",
  subtitle: [Annual research lecture],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock]),),
), settings)
#assert(centered.kind == "cell")
#assert(grid-test.count(centered) == 1)

#let plate = resolve-layout(mosaic.layouts.title(
  title: [Models and evidence],
  variant: "plate",
  subtitle: [Annual research lecture],
  authors: (mosaic.layouts.author([Vincent Arel-Bundock]),),
), settings)
#assert(plate.kind == "cell")
#assert(plate.style.fill == settings.colors.text)

#let bordered = resolve-layout(mosaic.layouts.title(
  title: [Models and evidence],
  variant: "bordered",
  authors: (mosaic.layouts.author([Vincent Arel-Bundock]),),
), settings)
#assert(bordered.kind == "cell")
#assert(grid-test.count(bordered) == 1)

#let split-right = resolve-layout(mosaic.layouts.title(
  title: [Measuring environmental change],
  variant: "image-right",
  image: image-path,
), settings)
#assert(split-right.kind == "split")
#assert(split-right.axis == "width")
#assert(split-right.tracks == (3fr, 2fr))
#assert(split-right.children.at(0).kind == "cell")
#assert(split-right.children.at(1).id == "image")
#assert(grid-test.count(split-right) == 2)

#let split-left = resolve-layout(mosaic.layouts.title(
  title: [Measuring environmental change],
  variant: "image-left",
  image: image-path,
  tracks: (3fr, 2fr),
), settings)
#assert(split-left.tracks == (3fr, 2fr))
#assert(split-left.children.at(0).id == "image")
#assert(split-left.children.at(1).kind == "cell")

#let band = resolve-layout(mosaic.layouts.title(
  title: [Measuring environmental change],
  variant: "image-top",
  image: image-path,
), settings)
#assert(band.kind == "split")
#assert(band.axis == "height")
#assert(band.tracks == (2fr, 3fr))
#assert(band.children.at(0).id == "image")
#assert(band.children.at(1).kind == "cell")
#assert(grid-test.count(band) == 2)

#let background = resolve-layout(mosaic.layouts.title(
  title: [Cities after dark],
  variant: "image-background",
  image: path("/docs/assets/images/title-city.webp"),
  align: top + left,
), settings)
#assert(background.kind == "cell")
#assert(background.id == "title")
#assert(background.content != none)
#assert(background.style.background != none)
#assert(background.style.at("fill", default: none) == none)
// Structural cells carry no text or align styles; typography comes from the
// <mosaic-cell-title> label rules and the anchor is applied in the content.
#assert("text" not in background.style)
#assert("align" not in background.style)

#let centered-background = resolve-layout(mosaic.layouts.title(
  title: [Cities after dark],
  variant: "image-background",
  image: image-path,
  align: center,
), settings)
#assert(centered-background.style.inset.left == centered-background.style.inset.right)

#let right-background = resolve-layout(mosaic.layouts.title(
  title: [Cities after dark],
  variant: "image-background",
  image: image-path,
  align: right,
), settings)
#assert(background.style.inset.left == right-background.style.inset.right)
#assert(background.style.inset.right == right-background.style.inset.left)

#show: mosaic.setup
#mosaic.slide(layout: academic-command)
