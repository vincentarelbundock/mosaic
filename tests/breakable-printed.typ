// The printed outputs draw each frame as a fixed thumbnail, so a breakable
// slide renders there as one ordinary frame: one notes page per frame.
#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup.with(breakable: true, output: "notes")

== Long
#for index in range(1, 31) [Line #index.\ ]

== Short
Fits.
