#import "@local/mosaic:0.0.1" as mosaic
#show: mosaic.setup
#let bonsai = image("/docs/assets/images/bonsai.webp", alt: "Bonsai tree", width: 100%, height: 100%, fit: "cover")
#let dog = image("/docs/assets/images/dog.webp", alt: "Dog", width: 100%, height: 100%, fit: "cover")
#let institute-a = (id: "a", name: [Institute A])
#let institute-b = (id: "b", name: [Institute B])
#let institute-c = (id: "c", name: [Institute C])

#mosaic.slide(grid: mosaic.layouts.title(
  [Academic title],
  variant: "academic",
  subtitle: [A replication study],
  authors: (
    mosaic.author([Ada], affiliations: (institute-a,)),
    mosaic.author([Grace], affiliations: (institute-b,)),
    mosaic.author([Katherine], affiliations: (institute-c,)),
    mosaic.author([Dorothy], affiliations: (institute-a,)),
  ),

  date: [July 2027],
))
#mosaic.slide(grid: mosaic.layouts.title([Left-aligned title], variant: "left-aligned", subtitle: [Conference · Left subtitle]))
#mosaic.slide(grid: mosaic.layouts.title([Centered-stack title], variant: "centered-stack", subtitle: [Centered subtitle]))
#mosaic.slide(grid: mosaic.layouts.title([Accent-block title], variant: "accent-block", subtitle: [Workshop]))
#mosaic.slide(grid: mosaic.layouts.title([Image-right title], variant: "image-right", image: path("/docs/assets/images/title-river.webp")))
#mosaic.slide(grid: mosaic.layouts.title([Image-top title], variant: "image-top", image: (path: path("/docs/assets/images/title-river.webp"), alt: "Wetlands")))
#mosaic.slide(grid: mosaic.layouts.title([Image-background title], variant: "image-background", image: path("/docs/assets/images/title-city.webp")))

#mosaic.slide(grid: mosaic.layouts.section())[Plain section]
#mosaic.slide(grid: mosaic.layouts.section(number: [01]))[Numbered section]
#mosaic.slide(grid: mosaic.layouts.section(variant: "image-bottom", image: path("/docs/assets/images/dog.webp")))[Image-bottom section]
#mosaic.slide(grid: mosaic.layouts.section(variant: "image-background", image: dog))[Image-background section]
