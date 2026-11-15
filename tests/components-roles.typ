#import "@local/mosaic:0.0.3" as mosaic

// Where a component's role shows. The palette uses colors that occur nowhere
// else, so the runner can tell from the SVG which paint reached the page.
#show: mosaic.setup.with(
  foreground: none,
  colors: (line: rgb("#abcdef"), accent: rgb("#123456")),
)

// Page 1: a neutral callout's title is type, so it takes the text color, not
// the line color its rail is drawn in. The rail is switched off so the line
// color has no other way onto the page.
#mosaic.slide[][
  #mosaic.components.callout(role: "neutral", stroke: none, title: [NEUTRAL TITLE])[Body]
]

// Page 2: an explicit accent still colors the title.
#mosaic.slide[][
  #mosaic.components.callout(
    role: "neutral", stroke: none, accent: rgb("#fedcba"), title: [ACCENT TITLE],
  )[Body]
]

// Page 3: a plain quotation draws no rail. Pages 4 and 5: a role or an accent
// hangs it on one.
#mosaic.slide[][#mosaic.components.quote[Plain]]
#mosaic.slide[][#mosaic.components.quote(role: "accent")[Role]]
#mosaic.slide[][#mosaic.components.quote(accent: rgb("#fedcba"))[Accent]]
