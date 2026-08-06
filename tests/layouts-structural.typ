#import "@preview/mosaic:0.0.1" as mosaic
#show: mosaic.setup
#let bonsai = image("/docs-src/assets/images/bonsai.webp", alt: "Bonsai tree", width: 100%, height: 100%, fit: "cover")
#let dog = image("/docs-src/assets/images/dog.webp", alt: "Dog", width: 100%, height: 100%, fit: "cover")
#let institute-a = [Institute A]
#let institute-b = [Institute B]
#let institute-c = [Institute C]

#mosaic.slide(layout: mosaic.layouts.title(
  title: [Academic title],
  variant: "academic",
  subtitle: [A replication study],
  authors: (
    mosaic.layouts.author([Ada], affiliations: (institute-a,)),
    mosaic.layouts.author([Grace], affiliations: (institute-b,)),
    mosaic.layouts.author([Katherine], affiliations: (institute-c,)),
    mosaic.layouts.author([Dorothy], affiliations: (institute-a,)),
  ),

  date: [July 2027],
))
#mosaic.slide(layout: mosaic.layouts.title(title: [Ruled title], variant: "ruled", subtitle: [Conference · Ruled subtitle]))
#mosaic.slide(layout: mosaic.layouts.title(title: [Centered title], variant: "centered", subtitle: [Centered subtitle]))
#mosaic.slide(layout: mosaic.layouts.title(title: [Kicker title], variant: "kicker", subtitle: [Workshop]))
#mosaic.slide(layout: mosaic.layouts.title(title: [Panel title], variant: "panel", subtitle: [Workshop]))
#mosaic.slide(layout: mosaic.layouts.title(title: [Bordered title], variant: "bordered", subtitle: [Colloquium]))
#mosaic.slide(layout: mosaic.layouts.title(title: [Image-right title], variant: "image", position: "right", image: path("/docs-src/assets/images/title-river.webp")))
#mosaic.slide(layout: mosaic.layouts.title(title: [Image-top title], variant: "image", position: "top", image: (path: path("/docs-src/assets/images/title-river.webp"), alt: "Wetlands")))

#mosaic.slide(layout: mosaic.layouts.section())[Plain section]
#mosaic.slide(layout: mosaic.layouts.section(number: [01]))[Numbered section]
#mosaic.slide(layout: mosaic.layouts.section(variant: "image-bottom", image: path("/docs-src/assets/images/dog.webp")))[Image-bottom section]
#mosaic.slide(layout: mosaic.layouts.section(variant: "image-background", image: dog))[Image-background section]
