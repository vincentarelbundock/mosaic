// Two edges of the appendix marker. A styled automatic slide right before the
// marker keeps its styles around the whole slide, footer included: the marker
// closes the slide without narrowing its style wrappers. And a talk with no
// sections, whose first section opens after the marker, reports a section
// total of 0 from both `info()` and `progress`, which prints "1/0".
#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(
  layouts: (content: m.layouts.content(variant: "header-body-footer")),
  cells: (footer: context [
    LANG-#text.lang #h(1em)
    #m.components.progress(count: "sections", quiet: false)
  ]),
)

#[
  #set text(lang: "fr")
  == Styled
  Body
]
#m.appendix

= Backup
== Backup slide
#context {
  let section = m.info().section
  assert((section.number, section.total) == (1, 0), message: repr(section))
}
