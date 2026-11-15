// The three themes whose level-two heading rule rebuilds the heading (the
// editorial kicker rule, the manifesto capitals, the mono prompt) draw the same
// slide title on every frame of an incremental slide. Each deck is compiled
// through `--input theme=..`; scripts/run-tests.py compares the title's words
// and position on frames 1 and 2. `--input offset=1` repeats the check under
// a heading offset, where the slide heading is depth 2 but native level 3:
// the themes select it by depth, on the real heading and on its replay alike.
#import "@local/mosaic:0.0.3": themes

#let m = dictionary(themes).at(sys.inputs.at("theme", default: "editorial"))
#set heading(offset: int(sys.inputs.at("offset", default: "0")))
#show: m.setup

== Frame title
FRAMEBODY #metadata(none) <frame-body>
#m.steps.pause
FRAMEMORE

#context {
  let marks = query(<frame-body>).map(it => it.location().position())
  assert(counter(page).final().first() == 2)
  assert(marks.first().y == marks.last().y, message: repr(marks))
  assert(query(heading).len() == 1)
}
