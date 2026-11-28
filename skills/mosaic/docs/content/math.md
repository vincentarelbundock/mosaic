# Math

Typst's native math notation works inside Mosaic slides. Incremental commands can then focus attention on one part of an equation at a time without changing its layout.

## Incremental equations

The timing commands documented on the [Reveal and replace](../incremental/reveals.md) page work inside math as well. Wrapping each term in `m.steps.replace` annotates one part of an equation at a time, and because the largest alternative sets the slot, the surrounding math never moves.

```typ
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
```

## LaTeX

The [MiTeX package](https://typst.app/universe/package/mitex/) converts LaTeX math source into Typst content. Import `mi` for inline equations and `mitex` for display equations, useful when reusing existing equations or collaborating with LaTeX authors.

```typ
#import "@preview/mosaic:0.0.1" as m
#import "@preview/mitex:0.2.7": mi, mitex

#show: m.setup
#set text(size: 20pt)
#let slide = m.slide

#slide("content", variant: "body")[
  == LaTeX equations with MiTeX

  Write inline LaTeX such as #mi("\int_{-\infty}^{\infty} e^{-x^2}\,dx = \sqrt{\pi}") in ordinary text.

  #mitex(`
    \begin{aligned}
      \operatorname{Var}(X)
        &= \mathbb{E}\!\left[(X - \mathbb{E}[X])^2\right] \\
        &= \mathbb{E}\!\left[X^2 - 2X\,\mathbb{E}[X] + \mathbb{E}[X]^2\right] \\
        &= \mathbb{E}[X^2] - 2\,\mathbb{E}[X]^2 + \mathbb{E}[X]^2 \\
        &= \underbrace{\mathbb{E}[X^2]}_{\text{second moment}}
           - \big(\mathbb{E}[X]\big)^2 .
    \end{aligned}
  `)
]
```

## Theorem

The [ctheorems package](https://typst.app/universe/package/ctheorems/) provides numbered, referenceable theorem and proof environments. Define the environments once, install its `thmrules` show rule, and use them normally inside a Mosaic slide.

```typ
#import "@preview/mosaic:0.0.1" as m
#import "@preview/ctheorems:1.1.3": thmbox, thmproof, thmrules

#show: thmrules.with(qed-symbol: $square$)
#show: m.setup
#set text(size: 18pt)

#let theorem = thmbox(
  "theorem",
  "Theorem",
  fill: rgb("#eff6ff"),
)
#let proof = thmproof("proof", "Proof")

#let slide = m.slide

#slide("content", variant: "body")[
  == A theorem environment

  #theorem("Pythagoras")[
    For a right triangle with legs $a$, $b$ and hypotenuse $c$,
    #math.equation(alt: "a squared plus b squared equals c squared", $a^2 + b^2 = c^2$).
  ]

  #proof[
    Rearranging four congruent triangles inside a square shows that the
    uncovered area is both $c^2$ and $a^2 + b^2$.
  ]
]
```

## Accessible math

Typst does not describe an equation's meaning to a screen reader or a PDF/UA-1 export on its own: give `math.equation` an `alt` string that reads the formula aloud in words. This is required for accessible export, not optional polish.

```typ
#math.equation(
  alt: "a squared plus b squared equals c squared",
  block: true,
  $ a^2 + b^2 = c^2 $,
)
```

Reserve this for equations that carry meaning on their own, such as the Bellman equation above or the Pythagorean identity in the theorem example; a lone symbol referenced in running text or a table header, such as $N$ for a sample size, does not need one.
