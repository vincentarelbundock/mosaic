#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 20pt)

// Enlarge the display equation so the annotations are easy to read.
#show math.equation.where(block: true): set text(size: 1.5em)

#let reward = rgb("#c2410c")
#let discount = rgb("#2563eb")
#let future = rgb("#15803d")

// A zero-width strut carrying a fixed descender depth. Adding it to each term
// gives every `underbrace` body the same depth, so all braces sit at the same
// level regardless of the term's own descenders.
#let dstrut = context { hide($j$) + h(-measure($j$).width) }

// Draw the annotated term, but constrain its measured footprint to the bare
// term's height. The brace and label then hang below the baseline instead of
// inflating the box, so `replace` keeps every term on the equation's baseline
// and nothing shifts when later annotations appear.
#let explained(color, term, label) = context {
  let braced = text(fill: color, $underbrace(#term #dstrut, #label)$)
  box(height: measure(text(fill: color, $#term$)).height, braced)
}

// The heading goes in the layout's header cell (anchored at the top) and the
// equation fills the body cell, which we align on the horizon to center it
// through the body cell's <mosaic-cell-body> label.
#show label("mosaic-cell-body"): set align(center + horizon)

#m.slide(layout: m.layouts.content(variant: "header-body"))[
  == Bellman optimality equation
][
  #math.equation(
    block: true,
    alt: "V star of s equals the maximum over a of: the immediate reward for state s and action a, plus the discount factor gamma times the sum over next states s prime of the transition probability times the optimal value of s prime.",
    $
      V^star(s) = max_a
        #m.steps.replace(
          align: top + center,
          [$R(s, a)$],
          [#explained(reward, $R(s, a)$, [immediate reward])],
          [#explained(reward, $R(s, a)$, [immediate reward])],
          [#explained(reward, $R(s, a)$, [immediate reward])],
        )
        + #m.steps.replace(
          align: top + center,
          [$gamma$],
          [$gamma$],
          [#explained(discount, $gamma$, [discount factor])],
          [#explained(discount, $gamma$, [discount factor])],
        )
        #m.steps.replace(
          align: top + center,
          [$sum_(s') P(s' | s, a) V^star(s')$],
          [$sum_(s') P(s' | s, a) V^star(s')$],
          [$sum_(s') P(s' | s, a) V^star(s')$],
          [#explained(
            future,
            $sum_(s') P(s' | s, a) V^star(s')$,
            [expected optimal future value],
          )],
        )
    $,
  )
]
