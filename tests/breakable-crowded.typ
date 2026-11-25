// A breakable slide whose repeated rows alone outgrow the frame. A lone
// positional body fills the first cell, the header, which repeats on every
// page; paginated, the header would be cut at the page edge on each page and
// the rest of its text lost. Under the deck-wide switch the slide stays one
// ordinary frame instead, so the next slide is page 2.
#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup.with(breakable: true)

#mosaic.slide[#for index in range(1, 40) [Crowded line #index.\ ]]

#mosaic.slide[== Next][Afterward.]
