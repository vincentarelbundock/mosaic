#import "@local/mosaic:0.0.3" as m

#show: m.setup

// A component is built from context and layout, so a note inside it would
// never reach the speaker view.
#m.slide[
  #m.components.card[Card #m.note[Lost]]
]
