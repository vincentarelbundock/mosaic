# Title slides

A title slide takes its content from the deck rather than from the slide, and its arrangement from a variant.

> **Requires Mosaic 0.0.3.** Three things on this page are new: the five `image-*` variants, where the released version writes `variant: "image"` with a `position:`; `image-background`, which sets the title over a full-slide picture; and `none` for the title itself. The picture examples import the development version; the others compile under the released one as they stand. This is the development version, which is not on Typst Universe yet: a deck that uses it imports `@local/mosaic:0.0.3` rather than the released `@preview/mosaic:0.0.2`. See [Install](../start/install.md).

## A simple title slide

Declare the title information once in `m.setup`, then place `m.slide(layout: "title")` where the deck opens:

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup.with(
  title: [The Optimal Number of Naps],
  subtitle: [Findings from a subject who slept through the study],
  authors: [Ada Lovelace],
  date: [March 2026],
)

#m.slide(layout: "title")
```

The slide names no content of its own. It reads the title, subtitle, authors, and date straight from `setup`, so the deck states them once and a title slide, a handout header, and the PDF's own metadata all agree.

An author is usually just a name, and `authors:` takes one the way `title:` and `subtitle:` do. Several names go in parentheses, separated by commas:

```typ
authors: ([Ada Lovelace], [Charles Babbage])
```

Wrap a name in `m.layouts.author` when it carries more than itself: an affiliation, an ORCID iD, an email address. The next section does exactly that.

To change one field on one slide, name it on `slide`. This deck opens on a draft date without touching the deck's own:

```typ
#m.slide(layout: "title", date: [Draft])
```

Writing `none` drops an inherited field from that slide: the subtitle, the date, the authors (for which `()` means the same), and, from the development version, the title itself.

## Variants

Each variant borrows a classic minimalist tradition. Six of them are compositions of type alone, and need nothing beyond the deck's own information:

- `centered`: the heading stack at the slide's center, details at the bottom edge.
- `bordered`: a thin border closes around a centered stack.
- `ruled`, the default: the heading stack over a full-width accent rule, flush left at the vertical center. The beamer-metropolis title page.
- `kicker`: the magazine masthead: an opening rule, the subtitle as a tracked-caps eyebrow, details at the bottom edge.
- `panel`: an ink side panel carries the details; the heading stack takes the main field.
- `academic`: the conference poster: superscript affiliation numbers, a numbered legend, a contact line. Requires at least one author.

Five more variants set a compact title stack with a picture, and require an `image:`. They are the same five names the [section layout](section.md) uses: `image-left`, `image-right`, `image-top`, and `image-bottom` put a full-bleed picture beside or above the stack, sized by `tracks:`, and `image-background` sets the stack over a full-slide picture. A layout's variant selects its arrangement, a picture's place included, so there is no separate placement argument. [Pictures in layouts](../content/images.md#pictures-in-layouts) describes what `image:` accepts. Over a background picture the type keeps the deck's text color, so give the picture a [scrim](../content/images.md#scrims) and recolor the title cell:

```typ
#[
  #show label("mosaic-cell-title"): set text(fill: white)
  #m.slide(
    layout: "title",
    variant: "image-background",
    image: (path: path("cover.webp"), scrim: black.transparentize(55%)),
  )
]
```

Every variant renders every field the deck and its authors declare: the title and subtitle, each name with its linked ORCID icon and the corresponding asterisk, the affiliations, the contact addresses, and the date. Choosing a variant changes the arrangement, never the information. A title too long for the room its variant gives it is scaled down to fit rather than printed over the details.

The thumbnails below all render the same title information: one deck title and subtitle, and three authors over two institutions, one of which two of them share. Every author carries an affiliation and an ORCID iD, and one of them is marked corresponding with an email address, so the `academic` legend has something to number and the ORCID icons, the contact line, and the corresponding-author asterisk all have somewhere to land. The contact line lists every author who gave an address, so it can carry more than the corresponding one. Only the variant changes between them, so anything you see move, resize, or change color is the variant's doing rather than the content's.

Written out in full, one of those decks is this:

```typ
#import "@preview/mosaic:0.0.2" as m

#let ccp = [Centre for Comparative Politics]
#let eis = [European Institute for Social Data]

#show: m.setup.with(
  title: [The Optimal Number of Naps],
  subtitle: [Findings from a subject who slept through the study],
  authors: (
    m.layouts.author(
      [Priya Nair],
      affiliations: (ccp, eis),
      email: "priya.nair@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    m.layouts.author(
      [Elena García],
      affiliations: (eis,),
      orcid: "0000-0002-1825-0097",
    ),
    m.layouts.author(
      [Tomás Ferreira],
      affiliations: (ccp,),
      orcid: "0000-0003-4567-8901",
    ),
  ),
  date: [Toronto · July 2027],
)

#m.slide(layout: "title", variant: "academic")
```

An affiliation is the institution itself rather than an identifier for it, so two authors land on one legend number exactly when they name the same institution. Binding `ccp` and `eis` once and reusing the bindings is what makes that happen.

The remaining decks are that same file with a different variant on the last line, and the picture decks also pass an `image:` and import the development version.

In your own deck, write the title information directly in `setup`, as the listing above does. The decks on this page keep it in one shared [file](https://github.com/vincentarelbundock/mosaic/blob/main/docs-src/examples/embedded/structure/_title-info.typ) only so the page has a single copy to edit.

Open any thumbnail to see the slide at full size:

## Inverted

There is no inverted variant, because inversion is not an arrangement. Pass `invert: true` on any slide to swap that slide's canvas and text: the slide takes the deck's text color as its canvas, the type is knocked out in the canvas color, and the muted and line tones follow. Any variant composes with it, and so does any other layout, so an inverted section plate or an inverted big-number slide is the same one flag.

```typ
#m.slide(layout: "title", variant: "kicker", invert: true)
```

## Custom title page

When no variant draws the page you want, not even `image-background`, build the slide yourself. `m.info()` returns the `title`, `subtitle`, `authors`, and `date` you declared on `setup`, so the custom slide can use them without repeating them. Each author comes back as a dictionary with `name`, `affiliations`, `email`, `orcid`, and `corresponding` fields. Call `m.info()` inside a `context` block, as the example below does. The same reader also reports where the slide sits in the deck, in its `slide` and `section` fields, which is what hand-built chrome is made of; the [footer and progress](../presenting/footer.md) page covers that side of it.

The deck below composes a full-slide photograph on the slide's `background:` plane, anchors the heading to the top edge, and pins the byline to the bottom, an arrangement no built-in variant draws. The `scrim:` on the background image quiets the photograph exactly as it does on the image variants, and `numbered: false` keeps the cover out of the slide count the way named title layouts stay out of it automatically.

```typ
#import "@preview/mosaic:0.0.2" as m
#import "_title-info.typ": info

#show: m.setup.with(..info)

#m.slide(
  numbered: false,
  background: m.components.image(
    path("/docs-src/assets/images/title-city.webp"),
    scrim: black.transparentize(80%),
    alt: "Coastal city lights at night",
  ),
  // One cell for the whole slide; the two stacks are placed inside it.
  layout: m.grids.cell(id: "cover"),
)[
  #set text(fill: white)
  // m.info() is contextual, so it has to be read inside a context block.
  #context {
    let deck = m.info()
    place(top + left, {
      text(size: 1.9em, weight: "bold", deck.title)
      block(
        above: 0.9em,
        text(size: 1.05em, fill: white.transparentize(20%), deck.subtitle),
      )
    })
    place(bottom + left, {
      set par(leading: 0.5em)
      text(weight: "medium", deck.authors.map(author => author.name).join([, ]))
      linebreak()
      text(size: 0.75em, fill: white.transparentize(20%), deck.date)
    })
  }
]
```
