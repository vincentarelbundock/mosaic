// A reference target keeps its label on the canonical frame only. Repeated on
// every frame, `@label` fails with "occurs multiple times in the document".
// Labels that are not reference targets stay on every frame, because
// label-targeted show rules must keep applying.
#import "@local/mosaic:0.0.3" as m

#show: m.setup
#set math.equation(numbering: "(1)")
#show <label-styled>: set text(fill: red)

#m.slide[
  #block[LABEL STYLED] <label-styled>
  #figure(rect(), caption: [LABEL CAPTION]) <label-figure>
  $ x = 1 $ <label-equation>
  See @label-figure.
  #m.steps.pause
  See @label-equation.
]

#context {
  assert(counter(page).final().first() == 2)
  assert(query(<label-figure>).len() == 1)
  assert(query(<label-equation>).len() == 1)
  assert(query(<label-styled>).len() == 2)
}
