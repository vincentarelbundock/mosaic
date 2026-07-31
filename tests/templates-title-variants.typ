#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test
#import "../mosaic/src/template-resolver.typ": resolve-template
#import "../mosaic/src/settings.typ": make-settings

#let settings = make-settings()
#let image-path = path("/docs/assets/images/title-river.webp")
#let udem = (id: "udem", name: [Universite de Montreal])
#let cirano = (id: "cirano", name: [CIRANO])
#let academic-authors = (
  mosaic.author([Ada Lovelace], affiliations: (udem, cirano)),
  mosaic.author([Grace Hopper], affiliations: (cirano,)),
  mosaic.author([Katherine Johnson], affiliations: (udem,)),
)

#let academic-command = mosaic.templates.title(
  [A long academic title],
  variant: "academic",
  subtitle: [A multilevel analysis],
  authors: academic-authors,
  date: [July 2027],
)
#let academic = resolve-template(academic-command, settings)
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

#let structured-academic = resolve-template(mosaic.templates.title(
  [Structured authors],
  variant: "academic",
  authors: (
    mosaic.author(
      [Ada Lovelace],
      affiliations: (udem, cirano),
      email: "ada@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    mosaic.author(
      [Grace Hopper],
      affiliations: (cirano,),
    ),
  ),
), settings)
#assert(grid-test.count(structured-academic) == 3)
#for id in ("title", "authors", "details") {
  assert(grid-test.info(structured-academic, id).cell.id == id)
}

#let orcid-only = resolve-template(mosaic.templates.title(
  [ORCID only],
  variant: "academic",
  authors: (
    mosaic.author([Grace Hopper], orcid: "0000-0001-2345-6789"),
  ),
), settings)
#assert(grid-test.count(orcid-only) == 2)
#for id in ("title", "authors") {
  assert(grid-test.info(orcid-only, id).cell.id == id)
}

#let left-grid = resolve-template(mosaic.templates.title(
  [When public data disappears],
  variant: "left-aligned",
  subtitle: [Evidence from twelve public archives],
  authors: (mosaic.author([Vincent Arel-Bundock], affiliations: (udem,)),),
  date: [March 2027],
), settings)
#assert(left-grid.kind == "cell")
#assert(grid-test.count(left-grid) == 1)
#assert(grid-test.info(left-grid, "title").cell.content != none)

#let centered = resolve-template(mosaic.templates.title(
  [Models and evidence],
  variant: "centered-stack",
  subtitle: [Annual research lecture],
  authors: (mosaic.author([Vincent Arel-Bundock]),),
), settings)
#assert(centered.kind == "cell")
#assert(grid-test.count(centered) == 1)

#let accent = resolve-template(mosaic.templates.title(
  [From raw data to publication],
  variant: "accent-block",
  subtitle: [Build a reproducible report],
  authors: (mosaic.author([Vincent Arel-Bundock]),),
), settings)
#assert(accent.kind == "split")
#assert(accent.axis == "width")
#assert(accent.tracks == (4%, 1fr))
#assert(grid-test.count(accent) == 2)
#assert(grid-test.info(accent, "accent").cell.style.fill == settings.colors.accent)

#let split-right = resolve-template(mosaic.templates.title(
  [Measuring environmental change],
  variant: "image-right",
  image: image-path,
), settings)
#assert(split-right.kind == "split")
#assert(split-right.axis == "width")
#assert(split-right.tracks == (3fr, 2fr))
#assert(split-right.children.at(0).kind == "cell")
#assert(split-right.children.at(1).id == "image")
#assert(grid-test.count(split-right) == 2)

#let split-left = resolve-template(mosaic.templates.title(
  [Measuring environmental change],
  variant: "image-left",
  image: image-path,
  tracks: (3fr, 2fr),
), settings)
#assert(split-left.tracks == (3fr, 2fr))
#assert(split-left.children.at(0).id == "image")
#assert(split-left.children.at(1).kind == "cell")

#let band = resolve-template(mosaic.templates.title(
  [Measuring environmental change],
  variant: "image-top",
  image: image-path,
), settings)
#assert(band.kind == "split")
#assert(band.axis == "height")
#assert(band.tracks == (2fr, 3fr))
#assert(band.children.at(0).id == "image")
#assert(band.children.at(1).kind == "cell")
#assert(grid-test.count(band) == 2)

#let background = resolve-template(mosaic.templates.title(
  [Cities after dark],
  variant: "image-background",
  image: path("/docs/assets/images/title-city.webp"),
  align: top + left,
), settings)
#assert(background.kind == "cell")
#assert(background.id == "title")
#assert(background.content != none)
#assert(background.style.background != none)
#assert(background.style.at("fill", default: none) == none)
#assert(background.style.text.fill == settings.colors.text)
#assert(background.style.align == top + left)

#let centered-background = resolve-template(mosaic.templates.title(
  [Cities after dark],
  variant: "image-background",
  image: image-path,
  align: center,
), settings)
#assert(centered-background.style.inset.left == centered-background.style.inset.right)

#let right-background = resolve-template(mosaic.templates.title(
  [Cities after dark],
  variant: "image-background",
  image: image-path,
  align: right,
), settings)
#assert(background.style.inset.left == right-background.style.inset.right)
#assert(background.style.inset.right == right-background.style.inset.left)

#show: mosaic.setup
#mosaic.slide(grid: academic-command)
