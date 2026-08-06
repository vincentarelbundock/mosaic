#import "@preview/mosaic:0.0.1" as mosaic

// Two consumers share one fitter. The section layouts fit content they generate
// themselves: the `toc` variant shrinks a section list whose length the deck
// decides, and the section title cell shrinks a name too wide for its width.
// A deck reaches the same fitter through `mosaic.fit` for a block it cannot
// divide. None of the three may overflow or clip. The control slide carries a
// body that genuinely overflows, so the single warning proves the fitters ran
// rather than that the content fit anyway.
#show: mosaic.setup.with(overflow: "record", title: [Fitting])

= Alpha
= Beta
= Gamma
= Delta
= Epsilon
= Zeta
= Eta
= Theta

#mosaic.slide(layout: "section", variant: "toc")[Theta]

#mosaic.slide(layout: "section")[
  MOSAIC-FIT-SECTION-TITLE-THAT-IS-FAR-TOO-WIDE-FOR-ANY-SLIDE-TO-HOLD
]

// The public helper in an ordinary body cell, on content identical to the
// control below. The cell is observed, so an unfitted block here would warn.
#mosaic.slide(layout: mosaic.layouts.content(variant: "body"))[
  #mosaic.fit(lorem(180))
]

// Control: an ordinary body cell has no fitter, so this one overflows.
#mosaic.slide(layout: mosaic.layouts.content(variant: "body"))[
  #lorem(180)
]
