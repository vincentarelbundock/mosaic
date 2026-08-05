#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  thumbnail-gallery,
)

#set document(title: [Section slides])
#metadata((title: "Section slides")) <website-metadata>

#title()

A section slide divides a talk into parts. It announces where the audience has arrived, carries no body content, and usually shows a number so the deck's shape stays legible.

= Sections from headings

After `#show: m.setup`, a level-one heading is a section slide. Any text between that heading and the next `==` becomes the section's subtitle, and the numbering is automatic:

```typ
= Methods

What the data can and cannot support.

== Data

This is one slide.
```

That is the whole mechanism for most decks. Sections declared this way also feed Typst's native `outline`, the `toc` variant described below, and the breadcrumbs on the #link("../furniture/navigation.html")[Navigation] page, because the headings stay native throughout.

= Explicit section slides

Write the slide with `m.slide` when it needs arguments a heading cannot carry. The section text is the slide's own content, so pass one positional block:

```typ
#m.slide(layout: "section")[Methods]

#m.slide(
  layout: "section",
  number: [02],
  subtitle: [How the grid resolves],
)[Structure]
```

An explicit `number:` overrides the automatic counter for that slide. Omit it and the designed variants read the counter themselves, which is what you want in the ordinary case. Named arguments here refine the configured section layout rather than replacing it; see #link("content.html#layout-fields-on-a-slide")[Layout fields on a slide].

= Variants

The designed text variants each borrow a classic minimalist tradition. `plain`, the default, centers the title alone. `rule` hangs the title beneath a heavy full-width rule with the number above it. `numeral` bleeds an enormous ghost number off the top-right edge behind a lower-left title stack. `baseline` ties title and number to one baseline with a hairline. `toc` lists every section in the deck with the current one alive and the others ghosted. Because they build their composition around the section number, an omitted `number:` reads the automatic counter.

The image variants place the section text beside a full-bleed picture (`image-left`, `image-right`, `image-top`, `image-bottom`, sized by `tracks:`) or directly over one (`image-background`). Every image variant requires `image:`.

The frames below grow the same divider one argument at a time: plain, numbered, then the designed text variants, then each image placement.

#embedded-example(
  calepin.elements.gallery,
  "structure/section-layout",
  frames: 11,
  title: "Section divider variants",
  renderer: thumbnail-gallery,
)

= Styling and text over pictures

Every variant composes its title, number, and subtitle inside one `<mosaic-cell-section>` cell, so a single native rule on that label reaches the whole stack. The number and subtitle carry `<mosaic-section-number>` and `<mosaic-section-subtitle>` labels of their own when one tier needs to differ from the rest.

Over a photograph the section text inherits the surrounding text color, so two things are needed: a #link("../content/images.html#scrims")[scrim] to quiet the picture, and a fill override on the cell. Scope both to the one slide that needs them:

```typ
#[
  #show label("mosaic-cell-section"): set text(fill: white)
  #m.slide(
    layout: "section",
    variant: "image-background",
    image: (path: path("fig/chapter.webp"), scrim: black.transparentize(55%)),
  )[Methods]
]
```

The last frame of the gallery above is exactly that slide. The directional image variants put the picture in its own `<mosaic-cell-image>` cell instead; `image-background` paints it as the section cell's background, so it has no image cell.

To give every section divider the same picture or variant, configure it once in `m.setup`; see #link("content.html#reusing-a-layout")[Reusing a layout]. The #link("../api/layouts.html")[Layouts API] lists every variant and field.
