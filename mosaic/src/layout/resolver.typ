// Setup-aware dispatch for validated semantic layout records.
#import "core.typ": is-layout
#import "content.typ": resolve-content-layout
#import "image.typ": resolve-image-layout
#import "title.typ": resolve-title
#import "section.typ": resolve-section
#import "../shared.typ": fail

#let resolve-layout(command, settings) = {
  if not is-layout(command) {
    fail("invalid layout record")
  }
  if command.name == "content" {
    resolve-content-layout(command, settings)
  } else if command.name == "image" {
    resolve-image-layout(command, settings)
  } else if command.name == "title" {
    resolve-title(command, settings)
  } else if command.name == "section" {
    resolve-section(command, settings)
  } else {
    fail("unsupported layout " + repr(command.name))
  }
}
