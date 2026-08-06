#import "/_calepin/calepin.typ" as calepin
#import "@preview/tidy:0.4.3"

#set document(title: [API reference])
#metadata((
  title: "API reference",
  description: "Every exported Mosaic function, grouped by reference page.",
)) <website-metadata>

#title()

Every exported function and variable, grouped by reference page. Each name
links to its full documentation: signature, parameter types, defaults, and
descriptions.

#let pages = (
  (
    title: "Document setup",
    href: "api/setup.html",
    sources: ("/api/modules/setup.typ",),
  ),
  (
    title: "Theme authoring",
    href: "api/theme.html",
    sources: ("/api/modules/theme-extension.typ",),
  ),
  (
    title: "Slides",
    href: "api/slides.html",
    sources: (
      "/api/modules/slide-command.typ",
      "/api/modules/note-command.typ",
      "/api/modules/surface.typ",
      "/api/modules/fit.typ",
    ),
  ),
  (
    title: "Incremental steps",
    href: "api/steps.html",
    sources: (
      "/api/modules/incremental-command.typ",
      "/api/modules/pause-command.typ",
    ),
  ),
  (
    title: "mosaic.grids constructors",
    href: "api/grids.html",
    sources: ("/api/modules/grid-constructors.typ",),
  ),
  (
    title: "Semantic layouts",
    href: "api/layouts.html",
    sources: (
      "/api/modules/author.typ",
      "/api/modules/layout-content.typ",
      "/api/modules/layout-image.typ",
      "/api/modules/layout-title.typ",
      "/api/modules/layout-section.typ",
    ),
  ),
  (
    title: "Components and furniture",
    href: "api/components.html",
    sources: (
      "/api/modules/component-card.typ",
      "/api/modules/component-callout.typ",
      "/api/modules/component-badge.typ",
      "/api/modules/component-quote.typ",
      "/api/modules/component-divider.typ",
      "/api/modules/component-progress.typ",
      "/api/modules/image.typ",
      "/api/modules/component-figure.typ",
    ),
  ),
)

#let page-entries(page) = {
  let module = tidy.parse-module(page.sources.map(read).join("\n"))
  let entries = ()
  for fn in module.functions {
    if fn.name.starts-with("_") { continue }
    entries.push(link(page.href + "#" + fn.name, raw(fn.name + "()", lang: none)))
  }
  for variable in module.variables {
    if variable.name.starts-with("_") { continue }
    entries.push(link(page.href + "#" + variable.name, raw(variable.name, lang: none)))
  }
  entries
}

#list(..pages.map(page => [
  #link(page.href)[*#page.title*]
  #list(..page-entries(page))
]))

#link("api/labels.html")[*Labels*] lists every label a rendered slide emits, which is the surface a deck or a theme writes `show` rules against.
