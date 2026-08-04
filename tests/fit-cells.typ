#import "@local/mosaic:0.0.1" as mosaic

// Fitting is internal, and the section layouts are its only consumers: the
// `toc` variant shrinks a section list whose length the deck decides, and the
// section title cell shrinks a name too wide for its width. Neither can be
// sized in advance by the author, so neither may overflow or clip. The control
// slide carries a body that genuinely overflows, so the single warning proves
// the fitters ran rather than that the content fit anyway.
#show: mosaic.setup.with(overflow: "warn", title: [Fitting])

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

// Control: an ordinary body cell has no fitter, so this one overflows.
#mosaic.slide(layout: mosaic.layouts.content(variant: "body"))[
  #lorem(180)
]
