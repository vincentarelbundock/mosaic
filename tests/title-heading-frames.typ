// A title slide carries one real heading however many frames it has, and
// draws the same title on each. The title layout builds its heading itself,
// so it keeps the canonical-frame contract on its own: the first frame holds
// the element, the others repeat its appearance. Compiled per theme and
// title variant through `--input theme=..` and `--input variant=..`;
// scripts/run-tests.py compares the title's words and bounding boxes on
// frames 1 and 2. `theme` is the theme's own title layout. `--input
// handout=true` renders the handout, whose one frame must hold the heading.
#import "@local/mosaic:0.0.3": themes

#let m = dictionary(themes).at(sys.inputs.at("theme", default: "default"))
#let variant = sys.inputs.at("variant", default: "theme")
#let handout = sys.inputs.at("handout", default: "false") == "true"
#show: m.setup.with(
  handout: handout,
  title: [Titleword heading],
  subtitle: [A subtitle],
  authors: ([Ada Lovelace], [Charles Babbage]),
  date: [2026],
)

// The pause lives on the foreground plane, so the title cell itself is the
// same on both frames and only the heading's two renderings can differ.
#let frames = [FRAMEONE #m.steps.pause FRAMETWO]

#if variant == "theme" {
  m.slide(layout: "title", foreground: frames)
} else {
  m.slide(
    layout: m.layouts.title(
      variant: variant,
      ..if variant.starts-with("image") {
        (image: path("/docs-src/assets/images/title-river.webp"))
      },
    ),
    foreground: frames,
  )
}

// A second title slide with a single frame has a heading of its own. The
// checks ride on its foreground: content after the last slide is not part of
// any slide and is never laid out, so an assertion there would not run. In
// handout mode the first slide has a single frame, the last step, and that
// frame is the canonical one: it carries the real heading.
#m.slide(layout: "title", title: [Second], foreground: context {
  assert(counter(page).final().first() == if handout { 2 } else { 3 })
  assert(
    query(heading).len() == 2,
    message: "expected one heading per logical title slide, found "
      + str(query(heading).len()),
  )
})
