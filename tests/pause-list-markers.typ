// A hidden list item hides its marker too. Typst merges adjacent items into
// one list and draws every marker with the list's own style, so a timed run
// of items is drawn as a marker grid instead, with the deck's own marker and
// numbering. scripts/run-tests.py counts the markers on each page.
#import "@local/mosaic:0.0.3" as m

#show: m.setup
#set list(marker: ([§], [¶]))
#set enum(numbering: "a)")

// Three pages: a pause between items.
#m.slide[][
  - PAUSE-ONE
  #m.steps.pause
  - PAUSE-TWO
    - PAUSE-NESTED
  #m.steps.pause
  - PAUSE-THREE
]

// Two pages: `on` around an item joins the surrounding list.
#m.slide[][
  + ON-ONE
  #m.steps.on("2-")[+ ON-TWO]
  + ON-THREE
]

// Two pages: `reveal` takes the same marker and numbering.
#m.slide[][
  #m.steps.reveal[
    + REVEAL-ONE
    + REVEAL-TWO
  ]
]

// One page: an untimed list stays native.
#m.slide[][
  - NATIVE-ONE
  - NATIVE-TWO
]

#context assert(counter(page).final().first() == 8)
