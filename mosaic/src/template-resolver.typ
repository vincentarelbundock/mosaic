// Setup-aware dispatch for validated semantic template records.
#import "shared.typ": fail
#import "template-core.typ": is-template-grid
#import "template-default.typ": resolve-default
#import "template-title.typ": resolve-title
#import "template-section.typ": resolve-section
#import "template-image.typ": resolve-image
#import "template-table.typ": resolve-table

#let with-role-color(fields, settings) = {
  let role = fields.at("role", default: settings.colors.accent)
  let role-color = if type(role) == color {
    role
  } else if type(role) == str and role in settings.colors {
    settings.colors.at(role)
  } else {
    fail("template role must be a setup color name or a color")
  }
  settings + (colors: settings.colors + (accent: role-color))
}

#let resolve-template(command, settings) = {
  if not is-template-grid(command) {
    fail("invalid template grid record")
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
