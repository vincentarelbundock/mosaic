#import "@local/mosaic:0.0.1" as mosaic

#let lab = (id: "lab", name: [Lab])
#let ada = mosaic.author(
  [Ada],
  affiliations: (lab,),
  email: "ada@example.org",
)
#ada.insert("email", "not-an-email")

#show: mosaic.setup
#mosaic.slide(grid: mosaic.templates.title(
  variant: "academic",
  authors: (ada,),
))[Title]
