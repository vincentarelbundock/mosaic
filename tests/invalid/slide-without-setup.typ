#import "@local/mosaic:0.0.3" as mosaic

// No `#show: mosaic.setup`: the slide command would otherwise be realized as
// inert metadata and the deck would compile to an empty page.
#mosaic.slide[][A slide in a document that never applied setup]
