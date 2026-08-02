// Setup-aware dispatch for validated semantic layout records.
#import "layout-core.typ": is-layout-grid
#import "layout-default.typ": resolve-default
#import "layout-title.typ": resolve-title
#import "layout-section.typ": resolve-section
#import "shared.typ": fail

#let resolve-layout(command, settings) = {
  if not is-layout-grid(command) {
    fail("invalid layout grid record")
  }
  if command.name == "default" {
    resolve-default(command, settings)
  } else if command.name == "title" {
    resolve-title(command, settings)
  } else if command.name == "section" {
    resolve-section(command, settings)
  } else {
    fail("unsupported layout grid " + repr(command.name))
  }
}
