#import "@local/mosaic:0.0.2" as mosaic

// Every quieting mode of components.progress() on one footline: SEC and NUM
// take the per-count auto rule, ALW always displays, ALL extends the silence
// to every unnumbered page even for the sections count.
#show: mosaic.setup.with(
  title: [Quiet],
  foreground: align(bottom + right, context [
    SEC#mosaic.components.progress(count: "sections")
    NUM#mosaic.components.progress()
    ALW#mosaic.components.progress(quiet: false)
    ALL#mosaic.components.progress(count: "sections", quiet: true)
  ]),
)

#mosaic.slide(layout: "title")

= One

== First

Body

== Second

Body

#context assert(counter(page).final().first() == 4)
