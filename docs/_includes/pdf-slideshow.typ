// Accessible PDF slideshow markup shared by embedded examples and full decks.
#let pdf-slideshow(
  pdf,
  cover,
  id,
  title,
  pages,
  alt,
  max-width: 42em,
  unit: "frames",
) = {
  let label-id = id + "-label"
  let singular = if unit == "frames" { "frame" } else { "slide" }
  let count-label = if pages == 1 { singular } else { unit }
  html.elem("div", attrs: (
    class: "pdf-slideshow",
    "data-frames": str(pages),
  ))[
    #html.elem("a", attrs: (
      class: "pdf-slideshow-preview",
      href: pdf,
      "data-pdf-slideshow-trigger": "",
      "data-pdf-dialog": id,
      "aria-haspopup": "dialog",
      "aria-controls": id,
      "aria-label": "Open slideshow: " + title,
      style: "max-width: " + repr(max-width) + ";",
    ))[
      #html.elem("img", attrs: (
        class: "pdf-slideshow-preview__image",
        src: cover,
        alt: alt,
        loading: "lazy",
        decoding: "async",
      ))
      #html.elem("span", attrs: (
        class: "pdf-slideshow-preview__caption",
      ))[
        Open slideshow · #pages #count-label
      ]
    ]
    #html.elem("dialog", attrs: (
      id: id,
      class: "pdf-slideshow-dialog",
      "data-pdf-slideshow": "",
      "data-pdf-src": pdf,
      "data-pdf-title": title,
      "data-pdf-pages": str(pages),
      "aria-labelledby": label-id,
    ))[
      #html.elem("div", attrs: (class: "pdf-slideshow-dialog__shell"))[
        #html.elem("header", attrs: (class: "pdf-slideshow-dialog__header"))[
          #html.elem("div", attrs: (
            id: label-id,
            class: "pdf-slideshow-dialog__title",
          ))[#title]
          #html.elem("button", attrs: (
            class: "pdf-slideshow-dialog__close",
            type: "button",
            "data-pdf-close": "",
            "aria-label": "Close slideshow",
          ))[×]
        ]
        #html.elem("div", attrs: (
          class: "pdf-slideshow-dialog__stage",
          "data-pdf-stage": "",
        ))[
          #html.elem("canvas", attrs: (
            class: "pdf-slideshow-dialog__canvas",
            "data-pdf-canvas": "",
            role: "img",
            "aria-label": title,
          ))
          #html.elem("p", attrs: (
            class: "pdf-slideshow-dialog__message",
            "data-pdf-message": "",
            "aria-live": "polite",
          ))[Loading slideshow…]
        ]
        #html.elem("footer", attrs: (class: "pdf-slideshow-dialog__controls"))[
          #html.elem("div", attrs: (class: "pdf-slideshow-dialog__group"))[
            #html.elem("button", attrs: (
              type: "button",
              "data-pdf-previous": "",
              "aria-label": "Previous frame",
            ))[← Previous]
            #html.elem("span", attrs: (
              class: "pdf-slideshow-dialog__status",
              "data-pdf-status": "",
              "aria-live": "polite",
            ))[Page 1 of #pages]
            #html.elem("button", attrs: (
              type: "button",
              "data-pdf-next": "",
              "aria-label": "Next frame",
            ))[Next →]
          ]
          #html.elem("div", attrs: (class: "pdf-slideshow-dialog__group"))[
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
              class: "pdf-slideshow-dialog__open",
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
