#import "@local/mosaic:0.0.1" as mosaic

#let lab = [Lab]
#let ada = mosaic.layouts.author(
  [Ada],
  affiliations: (lab,),
  email: "ada@example.org",
)
#ada.insert("email", "not-an-email")

#show: mosaic.setup
#mosaic.slide(layout: mosaic.layouts.title(
  title: [Title],
  variant: "academic",
  authors: (ada,),
))[Title]
