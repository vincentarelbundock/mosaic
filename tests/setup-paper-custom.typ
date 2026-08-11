// An explicit slide size, for aspect ratios the two aliases do not cover, plus
// a real page margin on the slide canvas.
#import "@local/mosaic:0.0.2" as mosaic
#import "../mosaic/src/paper.typ": paper-aliases, resolve-paper

// The aliases resolve to the dimensions of Typst's own presentation papers, so
// the page and the speaker-output thumbnail are sized from one value.
#assert(resolve-paper("16-9") == (width: 297mm, height: 167.0625mm))
#assert(resolve-paper("4-3") == paper-aliases.at("4-3"))
#assert(resolve-paper((width: 20cm, height: 20cm)).width == 20cm)

#show: mosaic.setup.with(
  paper: (width: 24cm, height: 12cm),
  margin: 5mm,
)

== Custom canvas

#context {
  assert(page.width == 24cm)
  assert(page.height == 12cm)
  assert(page.margin == 5mm)
}
