// Validation shared by setup, themes, slides, and the deck compiler.
#import "shared.typ": fail, reject-unknown-keys
#import "grid-model.typ": is-node
#import "layout-core.typ": is-layout
#import "layout-api.typ" as base-layouts

#let layout-names = ("content", "title", "section")
#let standard-layouts = (
  content: base-layouts.content(variant: "header-body"),
  title: base-layouts.title(),
  section: base-layouts.section(),
)

#let validate-layout-value(value, subject) = {
  if not is-node(value) and not is-layout(value) {
    fail(subject + " must be a Mosaic grid tree or layout")
  }
  value
}

#let validate-layouts(value, subject: "setup layouts", partial: false) = {
  if type(value) != dictionary {
    fail(subject + " must be a dictionary")
  }
  reject-unknown-keys(value, layout-names, subject)
  if not partial {
    for name in layout-names {
      if name not in value {
        fail(subject + " requires " + repr(name))
      }
    }
  }
  for (name, layout) in value {
    let _ = validate-layout-value(layout, subject + " " + repr(name))
  }
  value
}
