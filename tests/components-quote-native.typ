// `components.quote` is a superset of the native `quote`: `block`, `quotes`,
// and `attribution` keep their native meaning, and the quoted text is a native
// quote element inside the panel.
#import "@local/mosaic:0.0.3" as m

#show: m.setup
#show quote: set text(style: "italic")

#m.slide[][
  // The default: a block panel with no quotation marks.
  #m.components.quote(attribution: [PANELWHO], source: [PANELSOURCE])[PANELQUOTE]

  // Native `quotes: true` wraps the text in marks.
  #m.components.quote(quotes: true)[MARKEDQUOTE]

  // Native `block: false` is the inline quotation, with its marks and no panel.
  She said #m.components.quote(block: false)[INLINEQUOTE] and left.

  // Every other component override defaults to `auto`; so does a badge's radius.
  #m.components.badge(radius: auto)[BADGE]
]

#context {
  // One native quote element per quotation.
  assert(query(quote).len() == 3)
  assert(query(quote).map(it => it.block) == (false, false, false))
}
