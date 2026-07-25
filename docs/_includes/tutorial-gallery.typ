#let padded-page(page, total) = {
  let width = str(total).len()
  let value = str(page)
  ("0" * calc.max(width - value.len(), 0)) + value
}

// Keep each tutorial listing byte-for-byte aligned with the source that
// `make tutorial-slides` compiles into its slideshow.
#let verbatim-example(path) = raw(
  read("/tutorial-examples/" + path),
  block: true,
  lang: "typ",
)

#let gallery-items(slug, frames, title, start: 1) = {
  let last = start + frames - 1
  range(start, start + frames).map(page => (
    "/assets/tutorials/" + slug + "-" + padded-page(page, last) + ".svg",
    title + ", frame " + str(page - start + 1) + " of " + str(frames),
    [Frame #(page - start + 1) of #frames],
  ))
}

#let thumbnail-gallery(
  gallery,
  slug,
  frames,
  title,
  start: 1,
  columns: 2,
  max-width: 42em,
  show-captions: true,
) = gallery(
  gallery-items(slug, frames, title, start: start),
  columns: columns,
  gap: 0.75em,
  max-width: max-width,
  show-captions: show-captions,
)

#let thumbnail-gallery-items(
  gallery,
  items,
  columns: 2,
  max-width: 42em,
  show-captions: true,
) = gallery(
  items,
  columns: columns,
  gap: 0.75em,
  max-width: max-width,
  show-captions: show-captions,
)

#let slideshow(
  gallery,
  slug,
  frames,
  title,
  start: 1,
  max-width: none,
) = {
  let width = if max-width != none {
    max-width
  } else {
    42em
  }

  if frames > 1 and sys.inputs.at("calepin-target", default: "paged") == "html" {
    let id = "tutorial-deck-" + slug.replace("/", "-")
    let label-id = id + "-label"
    let pdf = "assets/tutorials/" + slug + ".pdf"
    let cover = "assets/tutorials/" + slug + "-cover.svg"
    return html.elem("div", attrs: (
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
        style: "max-width: " + repr(width) + ";",
      ))[
        #html.elem("img", attrs: (
          class: "tutorial-deck-preview__image",
          src: cover,
          alt: title + ", first frame of " + str(frames),
          loading: "lazy",
          decoding: "async",
        ))
        #html.elem("span", attrs: (
          class: "tutorial-deck-preview__caption",
        ))[
          Open slideshow · #frames frames
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

  let items = gallery-items(slug, frames, title, start: start)
  items.at(0).at(2) = [
    Open slideshow · #frames #if frames == 1 { [frame] } else { [frames] }
  ]
  let rendered = gallery(
    items,
    columns: 1,
    gap: 0pt,
    max-width: width,
    show-captions: true,
  )
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    html.elem("div", attrs: (
      class: "tutorial-slideshow",
      "data-frames": str(frames),
    ))[
      #rendered
    ]
  } else {
    rendered
  }
}
