// With `toc` as the deck's section layout, a backup section never appears in
// the list, not even on its own section slide, where the talk's sections are
// listed and nothing is current. The backup heading itself stays in the
// document: the outline still finds it.
#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(layouts: (section: m.layouts.section(variant: "toc")))

= Talk alpha
== One
Body.

#m.appendix

= Backup omega
== Two
Body.

#context assert(
  query(heading.where(level: 1)).map(it => it.body) == ([Talk alpha], [Backup omega]),
)
