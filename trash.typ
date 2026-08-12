// Speaker notes with the pdfpc sidecar. Build and inspect with:
//
//   typst compile trash.typ
//   pdfdetach -list trash.pdf                     # the attached sidecar
//   uv run python scripts/mosaic-pdfpc.py trash.typ   # writes trash.pdfpc
//   pdfpc trash.pdf                               # reads the notes beside it
//
// The sidecar rides along with this ordinary `slides` build; nothing in
// `setup` turns it on. For the notes-beside-the-slide layout instead, add
// `output: "split"` below and open the result in pympress or pdfpc.
#import "@local/mosaic:0.0.2" as m

#show: m.setup.with(
  title: [Speaker notes and the pdfpc sidecar],
  authors: [Vincent Arel-Bundock],
  date: [August 2026],
  output: "split",
)

#m.slide(layout: "title")

== Notes that apply to the whole slide

#m.note[
  Open by naming the question, not the method. Two sentences, then move on.
]

Every note on this slide is attached to the one frame it renders, so the
sidecar carries this text under page 2.

#m.note[
  A second note block accumulates after the first, in source order.
]

== Notes tied to individual frames

#m.note[Frame-independent: this shows on every frame of this slide.]

#m.steps.reveal(
  [
    The estimate is positive.
    #m.note[Give the point estimate before the interval.]
  ],
  [
    The interval excludes zero.
    #m.note[
      Now the uncertainty. Mention that this is _conditional_ on the
      specification in `model.R`, and that the appendix has the rest:

      - the fixed-effects variant
      - the clustered standard errors
    ]
  ],
)

Notes inside `m.steps.reveal` follow their content, so each physical frame
gets its own entry and pdfpc marks the later ones as continuations of the
first.

== A slide with nothing to say

Slides without notes are simply absent from the sidecar rather than present
and empty.
