#import "/.calepin/calepin.typ" as calepin
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

Mosaic recognizes four layouts by name: `"content"`, `"title"`, `"section"`, and `"image"`. Because `"content"` is the default you can usually omit it. This page covers the content layout. Content reaches the cells of every layout the same two ways, described in #link("custom.html#filling-cells")[Filling cells].

= Choosing a structure

The content layout comes in four variants: `body`, `header-body`, `body-footer`, and `header-body-footer`. Each theme picks one; the default theme uses `header-body`. Ask a slide for another with `variant:`. The `==` heading then fills the header, the next block fills the body, and a third block fills the footer:

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-full",
  frames: 1,
  title: "A slide with header, body, and footer cells",
  renderer: thumbnail-gallery,
)

See #link("../presenting/footer.html#default-footer-content")[Footer and progress] for recurring footer content and #link("../appearance/styling.html#styling-cells")[Styling cells] for cell styling.

= Two columns

For a side-by-side comparison, set `columns: 2` and supply three #link("custom.html#filling-cells")[positional blocks]: header, left, right. Write the header as a `==` heading so the slide keeps its place in the outline:

#embedded-example(
  calepin.elements.gallery,
  "structure/content-columns",
  frames: 1,
  title: "A two-column comparison under one header",
  renderer: thumbnail-gallery,
)

Add `tracks: (2fr, 1fr)` for an uneven split.

Every layout takes its fields this way, and a deck can adopt one throughout instead of naming it slide by slide. #link("custom.html#refine-a-layout")[Refine a layout] and #link("custom.html#replace-or-reuse-a-layout")[Replace or reuse a layout] cover both; the #link("../api/layouts.html")[Layouts API] lists all variants, cell IDs, and arguments.
