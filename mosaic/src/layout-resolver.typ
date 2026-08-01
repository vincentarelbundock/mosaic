// Setup-aware dispatch for validated semantic layout records.
#import "shared.typ": fail
#import "layout-core.typ": is-layout-grid
#import "layout-default.typ": resolve-default
#import "layout-title.typ": resolve-title
#import "layout-section.typ": resolve-section
#import "layout-image.typ": resolve-image
#import "layout-table.typ": resolve-table

#let with-role-color(fields, settings) = {
  let role = fields.at("role", default: settings.colors.accent)
  let role-color = if type(role) == color {
    role
  } else if type(role) == str and role in settings.colors {
    settings.colors.at(role)
  } else {
    fail("layout role must be a setup color name or a color")
  }
  settings + (colors: settings.colors + (accent: role-color))
}

#let resolve-layout(command, settings) = {
  if not is-layout-grid(command) {
    fail("invalid layout grid record")
  }
  let settings = with-role-color(command.fields, settings)
  if command.name == "default" {
    resolve-default(command, settings)
  } else if command.name == "image" {
    resolve-image(command, settings)
  } else if command.name == "title" {
    resolve-title(command, settings)
  } else if command.name == "section" {
    resolve-section(command, settings)
  } else {
    resolve-table(command, settings)
  }
}
