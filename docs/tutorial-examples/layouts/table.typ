#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let data = table(columns: 2, [Group], [Value], [A], [42], [B], [57])

#let myslide = m.slide.with(grid: m.layouts.table(title: [Titled table]))
#myslide[#data]

#let myslide = m.slide.with(grid: m.layouts.table(caption: [Two groups]))
#myslide[#data]

#let myslide = m.slide.with(
  grid: m.layouts.table(title: [Highlighted], highlight: [Group B]),
)
#myslide[#data]

#let myslide = m.slide.with(
  grid: m.layouts.table(title: [Sourced table], source: [Illustrative]),
)
#myslide[#data]
