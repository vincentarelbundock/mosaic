#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(paper: "4-3")

== Four by three

#context {
  assert(page.width == 280mm)
  assert(page.height == 210mm)
}
