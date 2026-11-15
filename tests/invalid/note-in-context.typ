#import "@local/mosaic:0.0.3" as m

#show: m.setup

// A context block of the deck's own is opaque: a note inside it, even in a
// component, is produced where no walk can find it.
#m.slide[][
  Lead
  #context { m.components.card[Card #m.note[Lost]] }
]
