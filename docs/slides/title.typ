#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  thumbnail-gallery,
)

#set document(title: [Title slides])
#metadata((title: "Title slides")) <website-metadata>

#title()

Use `layout: "title"` for an opening slide. Declare the deck's title information once in `m.setup`, then create the slide where you want it:

```typ
#show: m.setup.with(
  title: [Reliable systems],
  authors: (m.layouts.author("Ada Lovelace"),),
  date: [2026],
)

#m.slide(layout: "title")
```

#embedded-example(
  calepin.elements.gallery,
  "appearance/setup-deck",
  frames: 2,
  title: "Title information shared across a deck",
)

To change one field for one slide, name it on `slide`: `m.slide(layout: "title", variant: "academic")`. Pass `m.layouts.title(...)` directly when the slide needs a title layout built from scratch rather than a refinement of the configured one. See #link("content.html#layout-fields-on-a-slide")[Layout fields on a slide] for the difference between refining and replacing.

= Variants

The text variants each borrow a classic minimalist tradition: `swiss` (the default) rests the title mass on a full-width baseline rule with author, affiliation, and date in aligned columns beneath it; `centered` holds the mass at the slide's center with the metadata at the bottom edge; `plate` fills the slide with the deck's text color and knocks the type out in the canvas color; and `bordered` closes a centered stack inside one thin border. `academic` is the conference-poster arrangement with superscript affiliations and a contact line. The gallery then moves to layouts that place an image beside, above, below, or behind the title.

#embedded-example(
  calepin.elements.gallery,
  "structure/title-layout",
  frames: 9,
  title: "Nine structural title variants with inline academic metadata and images",
  renderer: thumbnail-gallery,
)

= Styling the title stack

Every variant composes its title, subtitle, and metadata inside one `<mosaic-cell-title>` cell, and a native rule on that label reaches all three. Color it and the whole stack follows, which is what a light-on-dark title over a photograph needs; size it and the whole stack scales as a unit, which is how to ask for quiet type in a corner:

```typ
#[
  #show label("mosaic-cell-title"): set text(fill: white, size: 0.45em)
  #m.slide(layout: "title", variant: "image-background", image: path("fig/cover.webp"))
]
```

The proportions hold because the display line carries its own `<mosaic-title-display>` label, which is where a theme states the title's display size. The tiers beneath it are ordinary ems of the cell, so they never compound with that size and never outgrow the title.

Image paths inside layout arguments cross the package boundary, so wrap every asset path in Typst's `path()`; a bare string is searched for inside the installed Mosaic package.

When no title variant fits the talk, the #link("image.html")[image layout's] `full` variant gives you a full-bleed picture with a single body cell, and the title becomes ordinary text you place yourself.
