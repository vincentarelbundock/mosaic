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
  (title: "Document setup", group: "setup"),
  (title: "Theme authoring", group: "theme"),
  (title: "Slides", group: "slides"),
  (title: "Incremental steps", group: "steps"),
  (title: "mosaic.grids constructors", group: "grids"),
  (title: "Semantic layouts", group: "layouts"),
  (title: "Components and furniture", group: "components"),
)

// Each group's manual labels every entry heading with the entry's name, and
// the build step that generates the manual queries those labels into
// entries.json. That query, not a second manifest, is what keeps this summary
// exhaustive: a function documented in a package source appears here as soon as
// its page has it, and the name is also the anchor, because typst-doc names the
// heading label after the topic.
#let page-entries(page) = {
  let href = "api/" + page.group + ".html"
  json("/api/generated/" + page.group + "/entries.json").map(name => link(
    href + "#" + name,
    raw(name + "()", lang: none),
  ))
}

#list(..pages.map(page => [
  #link("api/" + page.group + ".html")[*#page.title*]
  #list(..page-entries(page))
]))

#link("api/labels.html")[*Labels*] lists every label a rendered slide emits, which is the surface a deck or a theme writes `show` rules against.
