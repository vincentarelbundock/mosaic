// Shared setup protocol for bundled themes; visual rules remain theme-owned.
#import "../slide-command.typ": slide
#import "../shared.typ": fail

#let automatic-slide(layouts, title, body) = slide(
  grid: layouts.default(),
  content: (header: title, body: body),
)

#let configured-options(name, layouts, options, defaults: (:)) = {
  if options.pos().len() > 0 {
    fail(name + " setup accepts only its document body positionally")
  }
  defaults + (
    auto-slide: automatic-slide.with(layouts),
    section-grid: layouts.section(),
  ) + options.named()
}

#let normalize-lists(body) = {
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  body
}
