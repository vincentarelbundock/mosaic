// A section slide draws the same title on every frame. The real heading
// exists on one frame only; the others repeat its appearance, so whatever
// composes the title (the theme's depth-1 rule, the section cell's rule, the
// variant's own treatment, a theme's transforming rule) must reach the repeat
// as it reaches the heading. Compiled per theme and section variant through
// `--input theme=..` and `--input variant=..`; scripts/run-tests.py compares
// the title's words and bounding boxes on frames 1 and 2. `theme` is the
// theme's own section layout on an explicit slide, `automatic` the same
// layout reached through a `=` heading whose tagline holds the pause.
#import "@local/mosaic:0.0.3": themes

#let m = dictionary(themes).at(sys.inputs.at("theme", default: "default"))
#let variant = sys.inputs.at("variant", default: "theme")
#show: m.setup

// The checks ride inside a slide: content after the last slide is not part of
// any slide and is never laid out, so an assertion there would not run.
#let checks = context {
  let automatic = variant == "automatic"
  assert(counter(page).final().first() == if automatic { 3 } else { 2 })
  assert(
    query(heading).len() == if automatic { 2 } else { 1 },
    message: "expected one heading per slide, found " + str(query(heading).len()),
  )
}

// The pause lives on the foreground plane, so the section cell itself is the
// same on both frames and only the heading's two renderings can differ.
#let frames = [#checks FRAMEONE #m.steps.pause FRAMETWO]

#if variant == "automatic" {
  // The automatic form: the heading opens the section slide, the tagline
  // below it carries the pause, and the next `==` closes it. Here the frames
  // come from the section cell itself.
  [
    = Sectionword title

    TAGLINEONE #m.steps.pause TAGLINETWO

    == Slide

    Body #checks
  ]
} else if variant == "theme" {
  // The theme's own section layout, as an automatic `=` heading selects it.
  m.slide(layout: "section", foreground: frames)[= Sectionword title]
} else {
  m.slide(
    layout: m.layouts.section(
      variant: variant,
      ..if variant.starts-with("image") {
        (image: path("/docs-src/assets/images/dog.webp"))
      },
    ),
    foreground: frames,
  )[= Sectionword title]
}
