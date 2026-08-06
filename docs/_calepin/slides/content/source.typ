#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  thumbnail-gallery,
)

#set document(title: [Content slides])
#metadata((title: "Content")) <website-metadata>

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

Mosaic recognizes four layouts by name: `"content"`, `"title"`, `"section"`, and `"image"`. Because `"content"` is the default you can usually omit it. This page covers the content layout; the rules for filling, refining, and replacing any of the four live on the #link("configuring.html")[Configuring layouts] page.

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

See #link("../presenting/footer.html#default-footer-content")[Footer and progress] for recurring footer content and #link("../appearance/styling.html#styling-cells")[Styling cells] for cell styling.

= Two columns

For a side-by-side comparison, set `columns: 2` and supply three #link("configuring.html#filling-cells")[positional blocks]: header, left, right. Write the header as a `==` heading so the slide keeps its place in the outline:

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

A single slide can also change one aspect of the configured layout through named arguments, and a deck can replace a layout throughout with `m.setup(layouts:)` or reuse one with `m.slide.with`. The #link("configuring.html")[Configuring layouts] page covers those rules for every layout; the #link("../api/layouts.html")[Layouts API] lists all variants, cell IDs, and arguments.
