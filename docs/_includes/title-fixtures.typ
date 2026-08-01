// Decorative fixtures shared by the title gallery and complete layout example.
#let mark(label, fill) = block(
  width: 2.4cm,
  height: 0.72cm,
  fill: fill,
  radius: 4pt,
  inset: 5pt,
  align(center + horizon, text(size: 8pt, weight: "bold", fill: white, label)),
)

#let dashboard = block(
  width: 100%,
  height: 100%,
  fill: rgb("#101827"),
  inset: 18pt,
  [
    #set text(fill: rgb("#f8fafc"), size: 9pt)
    #grid(
      columns: (1fr, auto),
      rows: (auto, 1fr),
      gutter: 12pt,
      [*Election Explorer*],
      [#text(fill: rgb("#94a3b8"), size: 7pt)[Updated 2027]],
      grid.cell(colspan: 2)[
        #grid(
          columns: (1fr, 1fr),
          gutter: 12pt,
          block(fill: rgb("#1e293b"), radius: 5pt, inset: 12pt)[
            #text(fill: rgb("#94a3b8"), size: 7pt)[National vote]
            #v(12pt)
            #rect(width: 88%, height: 11pt, fill: rgb("#38bdf8"), radius: 2pt)
            #v(7pt)
            #rect(width: 64%, height: 11pt, fill: rgb("#f59e0b"), radius: 2pt)
            #v(7pt)
            #rect(width: 42%, height: 11pt, fill: rgb("#a78bfa"), radius: 2pt)
          ],
          block(fill: rgb("#1e293b"), radius: 5pt, inset: 12pt)[
            #text(fill: rgb("#94a3b8"), size: 7pt)[Seats over time]
            #v(10pt)
            #grid(
              columns: (1fr,) * 8,
              align: bottom,
              gutter: 5pt,
              ..(20pt, 34pt, 27pt, 45pt, 52pt, 39pt, 60pt, 49pt).map(
                h => rect(width: 100%, height: h, fill: rgb("#34d399"), radius: 2pt),
              ),
            )
          ],
        )
      ],
    )
  ],
)
