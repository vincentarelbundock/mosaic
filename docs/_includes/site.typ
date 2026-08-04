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
