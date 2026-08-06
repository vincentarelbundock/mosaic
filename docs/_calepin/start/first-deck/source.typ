#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Get started])
#metadata((title: "Get started")) <website-metadata>

#title()

First, import Mosaic and apply its setup rule:

```typ
#import "@preview/mosaic:0.0.1" as m
#show: m.setup
```

`m.setup` applies the page and theme defaults and turns headings and explicit `m.slide` commands into slides.

After `#show: m.setup`, every `==` starts a *content slide*: the heading becomes the title and the text that follows becomes its content. A single `=` starts an unnumbered *section slide* with a larger, centered title, and any text between it and the next `==` becomes that section's subtitle.

Most decks declare their shared settings once at the top with `m.setup.with(...)`: the deck's title and authors, the layout every content slide should use, and any recurring content such as a progress line. After that, the document is mostly headings, with explicit `m.slide` calls for slides a heading cannot express, such as a picture beside text or a two-column comparison.

The example below is a complete deck in that shape. It declares its title and authors once, opens with the built-in `title` layout, creates ordinary slides from headings, and finishes with two explicit slides: one `image` layout and one two-column content slide.

#embedded-example(
  calepin.elements.gallery,
  "getting-started/first-slideshow",
  frames: 6,
  title: "A complete deck: title slide, heading slides, an image slide, and two columns",
)

Read the #link("../reference/concepts.html")[Concepts] page next: it defines the vocabulary this documentation uses and the anatomy every slide shares. The #link("../slides/content.html")[Slides] section then takes each kind of slide in turn: ordinary #link("../slides/content.html")[content], the #link("../slides/title.html")[title] slide, #link("../slides/section.html")[section] dividers, #link("../slides/image.html")[image] slides, and #link("../slides/custom.html")[custom] compositions built from named cells.
