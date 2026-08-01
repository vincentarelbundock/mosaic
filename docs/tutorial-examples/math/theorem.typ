#import "@local/mosaic:0.0.1" as m
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

#m.deck(default-grid: m.grid.cell("body", inset: 1.5em))
#let slide = m.slide

#slide[
  == A theorem environment

  #theorem("Pythagoras")[
    For a right triangle with legs $a$, $b$ and hypotenuse $c$,
    $a^2 + b^2 = c^2$.
  ]

  #proof[
    Rearranging four congruent triangles inside a square shows that the
    uncovered area is both $c^2$ and $a^2 + b^2$.
  ]
]
