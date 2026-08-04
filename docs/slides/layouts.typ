#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  thumbnail-gallery,
)

#set document(title: [Layouts])
#metadata((title: "Layouts")) <website-metadata>

#title()

A layout is a ready-made slide arrangement. Start with Mosaic's content layout:

```typ
#m.slide(layout: "content")[Slide content]
```

The other recognized names are `"title"`, `"section"`, and `"image"`. Because `"content"` is the default, you can usually omit it. Pass `m.layouts.*` to build a layout from scratch, or one of the #link("grids.html")[custom grids] described elsewhere.

= Layout fields on a slide

Any named argument `slide` does not recognize is a field of the selected layout. So a single slide can change one aspect of the configured layout without restating it:

```typ
#m.slide(layout: "title", variant: "academic")
#m.slide(layout: "section", number: [03])[Methods]
#m.slide(layout: "image", variant: "right", image: path("fig/photo.jpg"))[== Title][Body]
#m.slide(columns: 2)[== Comparison][Left column][Right column]
```

This differs from passing `m.layouts.title(variant: "academic")`, which *replaces* the configured layout. Named arguments *refine* it: whatever the theme or `m.setup` set for that layout, such as an accent color or a background image, survives. Only the fields you name change.

The two forms are mutually exclusive on one slide. With an explicit `m.layouts.*` value, pass the fields to that constructor instead:

```typ
// Refines the configured title layout.
#m.slide(layout: "title", variant: "academic")

// Replaces it; the fields go to the constructor.
#m.slide(layout: m.layouts.title(variant: "academic"))
```

Field names are checked against the selected layout, so `m.slide(layout: "title", columns: 2)` fails at compile time rather than being silently ignored. Fields also require a layout chosen by name: if `m.setup` configures that layout as a raw grid rather than an `m.layouts.*` value, there are no fields to refine and Mosaic says so. The #link("../api/layouts.html")[Layouts API] lists the fields each layout accepts.

= `content()`

Use `m.layouts.content()` to choose a structure with a header, footer, or multiple columns. Mosaic also uses the active content layout for `==` slides. A text-heavy deck usually configures this once:

```typ
#show: m.setup.with(
  layouts: (content: m.layouts.content(variant: "header-body")),
)
```

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-full",
  frames: 1,
  title: "A slide with header, body, and footer cells",
  renderer: thumbnail-gallery,
)

For a side-by-side comparison, set `columns: 2` and supply three positional blocks: header, left, right. Write the header as a `==` heading so the slide keeps its place in the outline:

```typ
#m.slide(layout: "content", columns: 2)[== Three exams, equal weight][
  Exam 1:

  - In class.
  - Multiple choice.
  - Short answers: 3-5 sentences.
][
  Exam 2:

  - Take-home reading.
  - Define five concepts from the book.
]
```

Add `tracks: (2fr, 1fr)` for an uneven split. See #link("../furniture/footer.html#default-footer-content")[Footer and progress] for recurring footer content and #link("../appearance/styling.html#styling-cells")[Styling cells] for cell styling.

= `title()`

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

To change one field for one slide, name it on `slide`: `m.slide(layout: "title", variant: "academic")`. Pass `m.layouts.title(...)` directly when the slide needs a title layout built from scratch rather than a refinement of the configured one.

The text variants each borrow a classic minimalist tradition: `swiss` (the default) rests the title mass on a full-width baseline rule with author, affiliation, and date in aligned columns beneath it; `centered` holds the mass at the slide's center with the metadata at the bottom edge; `plate` fills the slide with the deck's text color and knocks the type out in the canvas color; and `frame` closes a centered stack inside one thin border. `academic` is the conference-poster arrangement with superscript affiliations and a contact line. The gallery then moves to layouts that place an image beside, above, below, or behind the title.

Every variant composes its title, subtitle, and metadata inside one `<mosaic-cell-title>` cell, and a native rule on that label reaches all three. Color it and the whole stack follows, which is what a light-on-dark title over a photograph needs; size it and the whole stack scales as a unit, which is how to ask for quiet type in a corner:

```typ
#[
  #show label("mosaic-cell-title"): set text(fill: white, size: 0.45em)
  #m.slide(layout: "title", variant: "image-background", image: path("fig/cover.webp"))
]
```

The proportions hold because the display line carries its own `<mosaic-title-display>` label, which is where a theme states the title's display size. The tiers beneath it are ordinary ems of the cell, so they never compound with that size and never outgrow the title.

#embedded-example(
  calepin.elements.gallery,
  "structure/title-layout",
  frames: 9,
  title: "Nine structural title variants with inline academic metadata and images",
  renderer: thumbnail-gallery,
)

= `section()`

Use `layout: "section"` for a section divider. Its configured `section()` layout may include a subtitle, number, or image. The frames below grow the same divider one argument at a time: plain, numbered, then the designed text variants, then each image placement. The last frame pairs an `image-background` carrying a #link("../content/images.html#scrims")[scrim] with white text through the `<mosaic-cell-section>` label, scoped to that slide alone.

The designed text variants each borrow a classic minimalist tradition: `rule` hangs the title beneath a heavy full-width rule, `numeral` bleeds an enormous ghost number off the top-right edge, `baseline` ties title and number to one baseline with a hairline, and `toc` lists every section with the current one alive. They build their composition around the section number, so an omitted `number:` reads the automatic section counter.

#embedded-example(
  calepin.elements.gallery,
  "structure/section-layout",
  frames: 11,
  title: "Section divider variants",
  renderer: thumbnail-gallery,
)

= `image()`

Use `layout: "image"` for any slide whose main content is a picture. In many decks this is the most common explicit slide. The default `figure` variant places a header above a contained picture, with an optional `caption:` beneath. It never crops, which is what a chart or screenshot needs:

```typ
#m.slide(layout: "image", image: path("fig/gdp.png"))[== Growth since 1950]

#m.slide(
  layout: "image",
  image: path("fig/pie.png"),
  caption: [Teaching, research, admin],
)[== My job]
```

The `figure` variant has header, image, and caption cells but no body, so a single line of commentary belongs in `caption:`. The caption produces a native Typst `figure`, so it follows the deck's `show figure.caption` rules.

The directional variants `left`, `right`, `top`, and `bottom` pair a full-bleed picture cell with header and body cells, filled by two positional blocks. Pass `[]` as the second block when the picture needs a title but no body:

```typ
#m.slide(
  layout: "image",
  variant: "right",
  image: path("fig/book.jpg"),
)[== Readings][
  - Almost every week.
  - PDFs on the course site.
]
```

Two arguments control the picture cell:

- `tracks:` sizes it. The value is independent of the side, so `tracks: 40%` means the same thing under `left` and `right`, and the two stay mirror images.
- `fit:` controls cropping. The directional variants default to `"cover"`, which fills the cell by cropping the picture. Pass `fit: "contain"` for a chart, a book cover, or any picture whose edges carry meaning.

The `full` variant puts the picture behind a single body cell that covers the whole slide. The cell inherits the deck's ordinary text color, so text over a photograph needs two things: a `scrim:` in the image specification to darken the picture, and a text fill override in the body:

```typ
#m.slide(
  layout: "image",
  variant: "full",
  image: (
    path: path("fig/auditorium.jpg"),
    scrim: black.transparentize(45%),
  ),
)[
  #set text(fill: white)
  == Who are you?
]
```

Omit the body entirely for a bare picture slide with no text at all. The `full` variant also works for a custom opening slide: when no title variant fits, write the title as ordinary text over a full-bleed picture.

#embedded-example(
  calepin.elements.gallery,
  "structure/image-layout",
  frames: 4,
  title: "The figure, right, bottom, and full variants of the image layout",
  renderer: thumbnail-gallery,
)

Image paths inside layout arguments cross the package boundary, so wrap every asset path in Typst's `path()`; a bare string is searched for inside the installed Mosaic package.

= Reusing a layout

To replace a named layout throughout a deck, configure it once in `m.setup`:

```typ
#show: m.setup.with(layouts: (
  section: m.layouts.section(variant: "image-background", image: "chapter.jpg"),
))
```

To reuse a layout for selected slides, bind it with `m.slide.with`:

```typ
#let myslide = m.slide.with(
  layout: m.layouts.content(
    variant: "header-body",
  ),
)

#myslide(content: (header: [== Slide title], body: [Slide content]))
```

See the #link("../api/layouts.html")[Layouts API] for all variants, cell IDs, and arguments.
