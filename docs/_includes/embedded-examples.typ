#import "pdf-slideshow.typ": pdf-slideshow

#let padded-page(page, total) = {
  let width = str(total).len()
  let value = str(page)
  ("0" * calc.max(width - value.len(), 0)) + value
}

// Keep each listing byte-for-byte aligned with the embedded source compiled by
// `make embedded-examples`.
#let example-source(slug) = raw(
  read("/examples/embedded/" + slug + ".typ"),
  block: true,
  lang: "typ",
)

#let gallery-items(slug, frames, title, start: 1) = {
  let last = start + frames - 1
  range(start, start + frames).map(page => (
    "/assets/examples/" + slug + "-" + padded-page(page, last) + ".svg",
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
  let width = if max-width != none { max-width } else { 42em }
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    return pdf-slideshow(
      "assets/examples/" + slug + ".pdf",
      "assets/examples/" + slug + "-cover.svg",
      "pdf-slideshow-" + slug.replace("/", "-"),
      title,
      frames,
      title + ", first frame of " + str(frames),
      max-width: width,
    )
  }

  // Paged (non-HTML) targets render the frames as a plain gallery.
  let items = gallery-items(slug, frames, title, start: start)
  items.at(0).at(2) = [
    Open slideshow · #frames #if frames == 1 { [frame] } else { [frames] }
  ]
  gallery(
    items,
    columns: 1,
    gap: 0pt,
    max-width: width,
    show-captions: true,
  )
}

// Render one canonical slug as both source and visual output. `renderer` can
// be `slideshow` or `thumbnail-gallery`; remaining arguments are forwarded.
#let embedded-example(
  gallery,
  slug,
  frames: 1,
  title: none,
  renderer: slideshow,
  ..args
) = {
  example-source(slug)
  renderer(gallery, slug, frames, title, ..args)
}
