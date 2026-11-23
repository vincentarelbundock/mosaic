// One slide asks to break while the deck default stays off. The explicit
// `breakable: false` on a short slide is the same fixed frame as the default.
#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup

#mosaic.slide(breakable: true)[== Long][#for index in range(1, 13) [Line #index of the long slide.\ ]]

#mosaic.slide(breakable: false)[== Short][Fits.]
