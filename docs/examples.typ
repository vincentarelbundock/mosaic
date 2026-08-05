#import "/.calepin/calepin.typ" as calepin
#import "/_includes/pdf-slideshow.typ": pdf-slideshow

#set document(title: [Examples])
#metadata((
  title: "Examples",
  description: "Complete slide decks built with Mosaic's bundled themes and layouts.",
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

This page hosts eight complete slide decks: four are built on one of Mosaic's bundled themes, some leaning on the themes' own layouts and others hand-crafting every slide from named cells and custom palettes, and the last four define a theme of their own to re-create an outside design. Click a thumbnail to page through its slides. The #link(repo)[GitHub repository] contains every deck's full Typst source, assets, Makefile, and compiled PDF.

#calepin.elements.callout(kind: "warning", title: [Start with the tutorials])[
  These are complete, fairly intricate decks: they combine custom palettes, hand-built grids, and theme extensions, so their source is not the gentlest introduction to Mosaic. If you are new to the package, read #link("start/first-deck.html")[Get started] first, then the guides on #link("slides/content.html")[writing slides] and #link("appearance/themes.html")[themes and colors]. The code below reads much more easily afterwards.
]

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
