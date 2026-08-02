#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m

#show: m.setup.with(output: "speaker")

#m.slide[
  #m.note[THEMED SPEAKER NOTE]
  == Themed speaker slide
]

#context assert(counter(page).final().first() == 1)
