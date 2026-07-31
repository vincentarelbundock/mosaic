#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Components])
#metadata((title: "Components")) <website-metadata>

#title()

The #link("grids.html")[Grids] guide controls where content is placed and how
cell surfaces are styled. `m.components` provides reusable Typst content
to place inside those cells—or inside any native Typst composition. Components
do not create slides or grids on their own.

Each function below has an independent example and gallery.

= `frame()`

Wrap arbitrary content in a clipped semantic frame.

#verbatim-example("libraries/components/frame.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/frame",
  2,
  "components.frame()",
)

= `callout()`

Emphasize content with a semantic side stripe and optional title.

#verbatim-example("libraries/components/callout.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/callout",
  1,
  "components.callout()",
)

= `label()`

Create a compact inline label with configurable corners and text styling.

#verbatim-example("libraries/components/label.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/label",
  1,
  "components.label()",
)

= `quote()`

Create a borderless quotation treatment with optional attribution.

#verbatim-example("libraries/components/quote.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/quote",
  1,
  "components.quote()",
)

= `divider()`

Separate content with an unlabeled or labeled horizontal divider.

#verbatim-example("libraries/components/divider.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/divider",
  1,
  "components.divider()",
)

= `progress()`

Show the current position in a deck. Progress follows Mosaic's logical slide
counter automatically, including when a slide has multiple incremental frames.
Each variant below is placed on the slide foreground near the bottom edge, but
the component can be used in any cell or native Typst container.

== Numeric

Use `"1/1"` when the exact current and total slide numbers matter, or `"1"`
to show only the current number without the total.

#verbatim-example("libraries/components/progress-numbers.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/progress-numbers",
  3,
  "templates.default(progress: \"1/1\")",
)

== Circle

Use `"circle"` for a compact visual indicator in a corner or narrow footer.

#verbatim-example("libraries/components/progress-circle.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/progress-circle",
  3,
  "templates.default(progress: \"circle\")",
)

== Line

Use `"line"` for a prominent edge-to-edge indication of deck progress.

#verbatim-example("libraries/components/progress-line.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/progress-line",
  3,
  "templates.default(progress: \"line\")",
)

== Foreground

You can add a progress indicator to any slide template, or to custom user-created grids, using the `foreground` argument. Here, we create a function called `slide-progress()` which creates a slide with two columns and a progress indicator.

#verbatim-example("libraries/components/custom-slide.typ")
#slideshow(
  calepin.elements.gallery,
  "libraries/components/custom-slide",
  3,
  "A reusable custom-grid slide function with foreground progress",
)
