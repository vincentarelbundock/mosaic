#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(layouts: (content: m.layouts.content(variant: "body")))
#set text(size: 18pt)

// One style governs both the in-text citations and the reference list.
#set bibliography(style: "chicago-author-date")

#m.slide[
  == Citing sources on a slide

  Small multiples repeat one design across panels @tufte1990.

  #cite(<cleveland1993>, form: "prose") measured how accurately readers
  decode position, length, and area.
]

#m.slide[
  == References

  // `title: none` drops the generated heading, so the slide's own heading
  // names the list.
  #bibliography("references.bib", title: none)
]
