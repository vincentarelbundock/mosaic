#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  thumbnail-gallery,
)

#set document(title: [Content slides])
#metadata((title: "Content slides")) <website-metadata>

#title()

Content slides carry the body of a talk: a title and some prose, a bulleted list, a two-column comparison. They are the most common slide in almost every deck, and Mosaic makes them the default. A slide with no `layout:` argument is a content slide, and so is every `==` heading in the document.

```typ
== Three exams, equal weight

Each exam counts for a third of the grade.
```

```typ
#m.slide[== Three exams, equal weight][Each exam counts for a third of the grade.]
```

Both forms render the same slide through the same layout. Write headings for the ordinary case and reach for `m.slide` when a slide needs arguments a heading cannot express.

Mosaic recognizes four layouts by name: `"content"`, `"title"`, `"section"`, and `"image"`. Because `"content"` is the default you can usually omit it. This page covers the content layout and, in its last two sections, the rules for configuring and refining any of the four.

= Choosing a structure

Use `m.layouts.content()` to choose a structure with a header, footer, or multiple columns. A text-heavy deck usually configures this once so that every `==` slide picks it up:

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

See #link("../furniture/footer.html#default-footer-content")[Footer and progress] for recurring footer content and #link("../appearance/styling.html#styling-cells")[Styling cells] for cell styling.

= Two columns

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

Add `tracks: (2fr, 1fr)` for an uneven split.

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

This section applies to every named layout, not only to `content`. The #link("title.html")[title], #link("section.html")[section], and #link("image.html")[image] pages refer back to it.

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

#myslide(cells: (header: [== Slide title], body: [Slide content]))
```

See the #link("../api/layouts.html")[Layouts API] for all variants, cell IDs, and arguments.
