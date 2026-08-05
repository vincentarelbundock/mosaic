#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#let estimates = table(
  columns: 8,
  align: (left, right, right, right, right, right, right, right),
  inset: 0.6em,
  table.header(
    [Specification], [Estimate], [Std. error], [$t$], [$p$],
    [CI lower], [CI upper], [Observations],
  ),
  [Baseline], [0.412], [0.081], [5.09], [$<$0.001], [0.253], [0.571], [12,480],
  [With covariates], [0.386], [0.079], [4.89], [$<$0.001], [0.231], [0.541], [12,480],
  [Region fixed effects], [0.344], [0.092], [3.74], [$<$0.001], [0.164], [0.524], [12,480],
  [Region and year effects], [0.351], [0.095], [3.69], [$<$0.001], [0.165], [0.537], [12,480],
)

// The table is wider than the cell. `wrap: false` keeps its columns as written
// and scales the whole block, instead of letting the table re-lay out narrower.
#m.slide[
  == Regression results

  #m.fit(wrap: false, estimates)
]

// The other direction: display type scaled up until it fills the cell.
#m.slide[
  == Response rate

  #m.fit(grow: true)[42%]
]
