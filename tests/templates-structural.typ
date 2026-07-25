#import "@local/mosaic:0.0.1" as mosaic
#show: mosaic.setup
#let bonsai = image("/docs/assets/images/bonsai.webp", alt: "Bonsai tree", width: 100%, height: 100%, fit: "cover")
#let dog = image("/docs/assets/images/dog.webp", alt: "Dog", width: 100%, height: 100%, fit: "cover")
#let institute-a = (id: "a", name: [Institute A])
#let institute-b = (id: "b", name: [Institute B])
#let institute-c = (id: "c", name: [Institute C])

#mosaic.slide(grid: mosaic.templates.title(
  variant: "academic",
  subtitle: [A replication study],
  authors: (
    mosaic.author([Ada], affiliations: (institute-a,)),
    mosaic.author([Grace], affiliations: (institute-b,)),
    mosaic.author([Katherine], affiliations: (institute-c,)),
    mosaic.author([Dorothy], affiliations: (institute-a,)),
  ),

  date: [July 2027],
))[Academic title]
#mosaic.slide(grid: mosaic.templates.title(variant: "left-aligned", subtitle: [Conference · Left subtitle]))[Left-aligned title]
#mosaic.slide(grid: mosaic.templates.title(variant: "centered-stack", subtitle: [Centered subtitle]))[Centered-stack title]
#mosaic.slide(grid: mosaic.templates.title(variant: "accent-block", subtitle: [Workshop]))[Accent-block title]
#mosaic.slide(grid: mosaic.templates.title(variant: "image-right", image: path("/docs/assets/images/title-river.webp")))[Image-right title]
#mosaic.slide(grid: mosaic.templates.title(variant: "image-top", image: (path: path("/docs/assets/images/title-river.webp"), alt: "Wetlands")))[Image-top title]
#mosaic.slide(grid: mosaic.templates.title(variant: "image-background", image: path("/docs/assets/images/title-city.webp")))[Image-background title]

#mosaic.slide(grid: mosaic.templates.section())[Plain section]
#mosaic.slide(grid: mosaic.templates.section(number: [01]))[Numbered section]
#mosaic.slide(grid: mosaic.templates.section(variant: "image-bottom", image: path("/docs/assets/images/dog.webp")))[Image-bottom section]
#mosaic.slide(grid: mosaic.templates.section(variant: "image-background", image: dog))[Image-background section]
