// The planes and an inverted ground reach every continuation page: the
// background and foreground ride the repeated rows, and the inverted ground
// rides with the background. The runner checks the plane text on each page
// and the page-sized inverted rectangle on each page of the inverted slide.
#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup.with(
  breakable: true,
  paper: (width: 240pt, height: 135pt),
  spacing: (inset: 5pt),
  background: place(top + right)[Backmark],
  foreground: place(bottom + right)[Foremark],
)
#set text(size: 7pt)

== Plain
#for index in range(1, 25) [Line #index.\ ]

#mosaic.slide(invert: true)[== Inverted][#for index in range(1, 25) [Line #index.\ ]]
