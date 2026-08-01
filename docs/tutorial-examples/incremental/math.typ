#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 20pt)

#m.deck()

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
// equation fills the body cell, which we align on the horizon to center it.
#m.slide(m.layouts.default(
  variant: "header-body",
  align: (body: center + horizon),
))[
  == Bellman optimality equation
][
  $
    V^star(s) = max_a
      #m.replace(
        align: top + center,
        [$R(s, a)$],
        [#explained(reward, $R(s, a)$, [immediate reward])],
        [#explained(reward, $R(s, a)$, [immediate reward])],
        [#explained(reward, $R(s, a)$, [immediate reward])],
      )
      + #m.replace(
        align: top + center,
        [$gamma$],
        [$gamma$],
        [#explained(discount, $gamma$, [discount factor])],
        [#explained(discount, $gamma$, [discount factor])],
      )
      #m.replace(
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
  $
]
