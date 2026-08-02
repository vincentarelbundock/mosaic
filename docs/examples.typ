#import "/.calepin/calepin.typ" as calepin
#import "/_includes/pdf-slideshow.typ": pdf-slideshow

#set document(title: [Examples])
#metadata((
  title: "Examples",
  description: "Complete slide decks built with Mosaic, adapted from real-world presentation templates.",
)) <website-metadata>

#let decks = json("/examples/decks/manifest.json").decks

#let deck(entry) = {
  let slug = entry.slug
  let dir = "examples/decks/" + slug
  let pdf = dir + "/" + slug + ".pdf"
  let cover = dir + "/cover.jpg"
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    pdf-slideshow(
      pdf,
      cover,
      "pdf-slideshow-example-" + slug,
      entry.title,
      entry.frames,
      entry.alt,
      max-width: 42em,
      unit: "slides",
    )
  } else {
    align(center, image("/" + cover, width: 70%, alt: entry.alt))
  }
}

#let repo = "https://github.com/vincentarelbundock/mosaic/tree/main/docs/examples/decks"

#title()

Explore four complete decks built with Mosaic. Click a thumbnail to page through
its slides. The #link(repo)[GitHub repository] contains every deck's full Typst
source, assets, Makefile, and compiled PDF. Each deck builds its slides from
custom grids and styles every cell with native `show` rules on its
`<mosaic-cell-ID>` label. Each deck's look is a single-module theme; three ship
inside the package under `m.themes`, and
#link("appearance.html#themes")[Appearance] explains how to write your own. See
#link("acknowledgments.html#example-decks")[Acknowledgments] for sources and
licenses.

#if sys.inputs.at("calepin-target", default: "paged") == "html" {
  html.elem("style", "
    .examples-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(min(100%, 24rem), 1fr));
      gap: 1.25rem;
      margin-block: 1.5rem;
    }

    .examples-grid > .pdf-slideshow {
      min-width: 0;
    }

    .examples-grid .pdf-slideshow,
    .examples-grid .pdf-slideshow-preview {
      width: 100%;
      max-width: none !important;
      margin: 0;
    }
  ")
  html.elem("div", attrs: (class: "examples-grid"))[
    #for entry in decks { deck(entry) }
  ]
} else {
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    ..decks.map(deck),
  )
}
