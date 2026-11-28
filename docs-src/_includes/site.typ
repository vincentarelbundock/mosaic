// Relative URL prefix from the current page back to the site root.
//
// Calepin resolves leading-slash paths itself when they pass through its own
// elements (`calepin.elements.gallery` and friends). Raw `html.elem` attributes
// and the PDF slideshow markup bypass that resolution, so pages nested in a
// directory must apply the prefix by hand. Returns "" for a root-level page.
#let root-prefix() = {
  let href = sys.inputs.at("calepin-current-href", default: "")
  let depth = href.split("/").filter(part => part != "").len() - 1
  if depth <= 0 { "" } else { "../" * depth }
}

// Site-root-relative URL for a static asset, usable from any page depth.
#let asset-url(path) = root-prefix() + path.trim("/", at: start)

// Link to one repository file on GitHub. Example sources are not published with
// the site, so a reader who wants to read one whole reads it there, in a new tab
// rather than losing the page they are on.
#let repo-file(path, body) = {
  let url = (
    "https://github.com/vincentarelbundock/mosaic/blob/main/"
      + path.trim("/", at: start)
  )
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    html.elem("a", attrs: (href: url, target: "_blank", rel: "noopener"), body)
  } else {
    link(url, body)
  }
}

// The warning every page that documents the development version carries.
//
// The released package and the development version differ, and this site
// documents both: a page whose snippets and examples need the development
// version says so once, here, in one wording. `what` is the sentence naming
// what on the page needs it. An example such a page shows imports the same
// `@local` version; one that compiles under both stays on the released import. The version is stated in this one place, next to
// the `@local` imports of the examples such a page shows.
#let development-version = "0.0.3"
#let unreleased(callout, what) = callout(
  kind: "warning",
  title: [Requires Mosaic #development-version],
)[
  #what This is the development version, which is not on Typst Universe yet: a deck that uses it imports #raw("@local/mosaic:" + development-version) rather than the released #raw("@preview/mosaic:0.0.2"). One command installs it; see #link(root-prefix() + "start/install.html")[Install].
]
