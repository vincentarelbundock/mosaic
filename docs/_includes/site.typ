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
