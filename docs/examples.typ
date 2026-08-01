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

Explore four complete decks built with Mosaic. Click a thumbnail to page through
its slides. The #link(repo)[GitHub repository] contains every deck's full Typst
source, assets, Makefile, and compiled PDF. Each deck builds its slides from
bespoke grids and paints every cell with native `show` rules on its
`<mosaic-cell-ID>` label, so the source doubles as a worked example of Mosaic's
targeting model. Each deck's reusable look is a single-module theme; three ship
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

    .examples-grid > .tutorial-slideshow {
      min-width: 0;
    }

    .examples-grid .tutorial-slideshow,
    .examples-grid .tutorial-deck-preview {
      width: 100%;
      max-width: none !important;
      margin: 0;
    }

  ")

  html.elem("div", attrs: (class: "examples-grid"))[
    #deck(
      "cream",
      "Cream, Green, and Black",
      21,
      "Cream, Green, and Black deck, first slide",
    )
    #deck(
      "metropolis",
      "Metropolis",
      25,
      "Metropolis deck, first slide",
    )
    #deck(
      "minimalist",
      "Minimalist White",
      19,
      "Minimalist White deck, first slide",
    )
    #deck(
      "portfolio",
      "Photojournalist Portfolio",
      14,
      "Photojournalist Portfolio deck, first slide",
    )
  ]
} else {
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    deck(
      "cream",
      "Cream, Green, and Black",
      21,
      "Cream, Green, and Black deck, first slide",
    ),
    deck(
      "minimalist",
      "Minimalist White",
      19,
      "Minimalist White deck, first slide",
    ),
    deck(
      "portfolio",
      "Photojournalist Portfolio",
      14,
      "Photojournalist Portfolio deck, first slide",
    ),
    deck(
      "metropolis",
      "Metropolis",
      25,
      "Metropolis deck, first slide",
    ),
  )
}
