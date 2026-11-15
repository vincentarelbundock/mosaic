#import "@local/mosaic:0.0.3" as mosaic

// A partial positional list is an error: two columns with one body used to
// leave the second column silently empty.
#show: mosaic.setup
#mosaic.slide(layout: mosaic.layouts.content(variant: "header-body", columns: 2))[Left only]
