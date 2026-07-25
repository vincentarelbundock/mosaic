#import "/.calepin/calepin.typ" as calepin

#set document(title: [Examples])
#metadata((
  title: "Examples",
  description: "Complete slide decks built with Mosaic, adapted from real-world presentation templates.",
)) <website-metadata>

// A thumbnail that opens the deck's PDF in the shared slideshow lightbox.
// Reuses the theme's `data-pdf-slideshow` markup and the inlined
// `pdf-slideshow.js` viewer, so no page-specific script is required. On the
// paged (PDF) target it degrades to a plain cover image.
#let deck(slug, title, frames, alt) = {
  let dir = "examples/" + slug
  let pdf = dir + "/" + slug + ".pdf"
  let cover = dir + "/cover.jpg"

  if sys.inputs.at("calepin-target", default: "paged") != "html" {
    // Root-absolute path: calepin evaluates this file from a wrapper location,
    // so a path relative to the source would not resolve.
    return align(center, image("/" + cover, width: 70%, alt: alt))
  }

  let id = "example-deck-" + slug
  let label-id = id + "-label"
  html.elem("div", attrs: (
    class: "tutorial-slideshow",
    "data-frames": str(frames),
  ))[
    #html.elem("a", attrs: (
      class: "tutorial-deck-preview",
      href: pdf,
      "data-pdf-slideshow-trigger": "",
      "data-pdf-dialog": id,
      "aria-haspopup": "dialog",
      "aria-controls": id,
      "aria-label": "Open slideshow: " + title,
      style: "max-width: 42em;",
    ))[
      #html.elem("img", attrs: (
        class: "tutorial-deck-preview__image",
        src: cover,
        alt: alt,
        loading: "lazy",
        decoding: "async",
      ))
      #html.elem("span", attrs: (class: "tutorial-deck-preview__caption"))[
        Open slideshow · #frames slides
      ]
    ]
    #html.elem("dialog", attrs: (
      id: id,
      class: "tutorial-deck-dialog",
      "data-pdf-slideshow": "",
      "data-pdf-src": pdf,
      "data-pdf-title": title,
      "data-pdf-pages": str(frames),
      "aria-labelledby": label-id,
    ))[
      #html.elem("div", attrs: (class: "tutorial-deck-dialog__shell"))[
        #html.elem("header", attrs: (class: "tutorial-deck-dialog__header"))[
          #html.elem("div", attrs: (
            id: label-id,
            class: "tutorial-deck-dialog__title",
          ))[#title]
          #html.elem("button", attrs: (
            class: "tutorial-deck-dialog__close",
            type: "button",
            "data-pdf-close": "",
            "aria-label": "Close slideshow",
          ))[×]
        ]
        #html.elem("div", attrs: (
          class: "tutorial-deck-dialog__stage",
          "data-pdf-stage": "",
        ))[
          #html.elem("canvas", attrs: (
            class: "tutorial-deck-dialog__canvas",
            "data-pdf-canvas": "",
            role: "img",
            "aria-label": title,
          ))
          #html.elem("p", attrs: (
            class: "tutorial-deck-dialog__message",
            "data-pdf-message": "",
            "aria-live": "polite",
          ))[Loading slideshow…]
        ]
        #html.elem("footer", attrs: (class: "tutorial-deck-dialog__controls"))[
          #html.elem("div", attrs: (class: "tutorial-deck-dialog__group"))[
            #html.elem("button", attrs: (
              type: "button",
              "data-pdf-previous": "",
              "aria-label": "Previous frame",
            ))[← Previous]
            #html.elem("span", attrs: (
              class: "tutorial-deck-dialog__status",
              "data-pdf-status": "",
              "aria-live": "polite",
            ))[Page 1 of #frames]
            #html.elem("button", attrs: (
              type: "button",
              "data-pdf-next": "",
              "aria-label": "Next frame",
            ))[Next →]
          ]
          #html.elem("div", attrs: (class: "tutorial-deck-dialog__group"))[
            #html.elem("button", attrs: (
              type: "button",
              "data-pdf-zoom-out": "",
              "aria-label": "Zoom out",
            ))[−]
            #html.elem("button", attrs: (
              type: "button",
              "data-pdf-zoom-reset": "",
              "aria-label": "Reset zoom",
            ))[100%]
            #html.elem("button", attrs: (
              type: "button",
              "data-pdf-zoom-in": "",
              "aria-label": "Zoom in",
            ))[+]
            #html.elem("a", attrs: (
              class: "tutorial-deck-dialog__open",
              href: pdf,
              target: "_blank",
              rel: "noopener",
            ))[Open PDF]
          ]
        ]
      ]
    ]
  ]
}

#let repo = "https://github.com/vincentarelbundock/mosaic/tree/main/docs/examples"

#title()

These are complete, real-world slide decks built with Mosaic. Each one adapts a
freely licensed presentation into a single self-contained Typst file, so you can
read the source to see how templates, grids, colors, and image placement come
together across a full deck rather than one slide at a time.

Every deck lives in its own directory under
#link(repo)[`docs/examples/`] on GitHub. That directory holds the complete data
for the deck — the `main.typ` source, the `assets/` images, a `Makefile`, and
the compiled PDF. Build a deck locally by running `make` from its directory.
Click any thumbnail below to page through the deck as a slideshow, or open its
PDF directly.

Each deck is adapted from a freely licensed source. See the
#link("acknowledgments.html#example-decks")[Acknowledgments] page for the sources,
attribution, and licenses.

= Cream, Green, and Black

A 21-slide minimal deck of cream, sage-green, and black geometric blocks with
full-bleed photography.

#deck("cream-green-black-mosaic", "Cream, Green, and Black", 21, "Cream, Green, and Black deck, first slide")

#link(repo + "/cream-green-black-mosaic")[Source and assets on GitHub]

= Minimalist White

A 19-page presentation on a clean white background with a red accent and serif
display type.

#deck("minimalist-white-mosaic", "Minimalist White", 19, "Minimalist White deck, first slide")

#link(repo + "/minimalist-white-mosaic")[Source and assets on GitHub]

= Photojournalist Portfolio

A 14-slide photo-forward portfolio deck pairing large images with restrained
black-and-white typography.

#deck("photojournalist-mosaic", "Photojournalist Portfolio", 14, "Photojournalist Portfolio deck, first slide")

#link(repo + "/photojournalist-mosaic")[Source and assets on GitHub]

= Metropolis

A 33-page adaptation of the Metropolis Beamer theme demo, covering incremental
reveals, plots, the standout slide, appendix, and a split bibliography.

#deck("metropolis-mosaic", "Metropolis", 33, "Metropolis deck, first slide")

#link(repo + "/metropolis-mosaic")[Source and assets on GitHub]
