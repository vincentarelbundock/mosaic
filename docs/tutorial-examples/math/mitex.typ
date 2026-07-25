#import "@local/mosaic:0.0.1" as m
#import "@preview/mitex:0.2.7": mi, mitex

#show: m.setup
#set text(size: 20pt)

#m.deck(default-grid: m.grid.cell("body"))
#let slide = m.slide.with(cell-styles: (body: (inset: 1.5em)))

#slide[
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
