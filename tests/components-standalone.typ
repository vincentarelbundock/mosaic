// A component outside a deck draws itself as it always has: nothing walks its
// content there, so a step or a note in its body is inert and the component
// still renders. scripts/run-tests.py asserts the words are on the page.
#import "@local/mosaic:0.0.3" as m

#set page(width: 12cm, height: 8cm, margin: 1cm)

#m.components.card[STANDALONECARD #m.note[Nowhere to go.]]

#m.components.callout(title: [STANDALONETITLE])[STANDALONECALLOUT]

#m.components.quote(attribution: [STANDALONEWHO])[STANDALONEQUOTE]

#m.components.badge[STANDALONEBADGE]
