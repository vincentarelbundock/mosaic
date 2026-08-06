#import "/_calepin/calepin.typ" as calepin
#set document(title: [Speaker notes])
#metadata((title: "Speaker notes")) <website-metadata>

#title()

Attach speaker notes with `m.note[...]`. Notes never appear in the presentation and never add a frame:

```typ
#m.slide[
  #m.note[Introduce the result.]

  #m.steps.reveal(
    [
      The estimate is positive.
      #m.note[Explain the sign and magnitude.]
    ],
    [
      The interval excludes zero.
      #m.note[Discuss uncertainty.]
    ],
  )
]
```

A note outside a timing command applies to every frame. A note inside `m.steps.on`, `m.steps.reveal`, or `m.steps.replace` appears with that content.

Notes also hold material that supports a slide without belonging on it: the source URL of a figure, a reminder of what to say, or the link behind an image slide.

= Printed outputs

To print a companion document, choose an output in `m.setup`:

```typ
// Slide thumbnail followed by its notes.
#show: m.setup.with(output: "speaker")

// Notes without a slide thumbnail.
#show: m.setup.with(output: "notes")
```

On those printed pages, the frame heading renders under the `<mosaic-note-heading>` label and the note text under `<mosaic-note-body>`. Both default to plain black type that reads against paper whatever the theme does. Restyle them with ordinary rules after `m.setup`:

```typ
#show label("mosaic-note-body"): set text(size: 11pt)
#show label("mosaic-note-heading"): set text(fill: rgb("#0072B2"))
```

The note outputs are independent of `handout:`, so a deck can print a #link("../incremental/handouts.html")[handout], a speaker script, or both.
