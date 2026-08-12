#import "/.calepin/calepin.typ" as calepin

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

Where the notes go is an argument to `m.setup`. The rest of this page is the three answers: two printed, and one that puts them on a second screen while you present.

= Printed outputs

To print a companion document, choose an output in `m.setup`:

```typ
// Slide thumbnail followed by its notes.
#show: m.setup.with(output: "speaker")

// Notes without a slide thumbnail.
#show: m.setup.with(output: "notes")
```

On those printed pages, the frame heading renders under the `<mosaic-note-heading>` label and the note text under `<mosaic-note-body>`. Both default to plain black type that reads against paper whatever the theme does. Neither states a size: the note text inherits the deck's own base size, so a theme with larger slide type gets proportionally larger notes, and the heading sits slightly above it. Restyle them with ordinary rules after `m.setup`:

```typ
#show label("mosaic-note-body"): set text(size: 18pt)
#show label("mosaic-note-heading"): set text(fill: rgb("#0072B2"))
```

The note outputs are independent of `handout:`, so a deck can print a #link("../incremental/handouts.html")[handout], a speaker script, or both.

= On a second screen

#calepin.elements.callout(kind: "warning", title: [Requires Mosaic 0.0.2])[
  Everything below is new in 0.0.2, which is not on Typst Universe yet, so the rest of this documentation pins the released `0.0.1`. To use these outputs, clone #link("https://github.com/vincentarelbundock/mosaic")[the repository], run `make install`, and import the development version:

  ```typ
  #import "@local/mosaic:0.0.2" as m
  ```

  See #link("https://github.com/vincentarelbundock/mosaic#install")[Install] for the full instructions. Everything above works with the package as published.
]

A presenter console drives two displays: the projector shows the slide, your laptop shows the same slide with its notes, the next slide, and a clock. Typst produces a PDF, so the console is a separate program. Several free ones exist — #link("https://pympress.xyz/")[pympress], #link("https://pdfpc.github.io/")[pdfpc], #link("https://github.com/beamerpresenter/BeamerPresenter")[BeamerPresenter] — and they run on Linux, macOS, and Windows.

Mosaic takes the route that works with all of them and needs no companion file, no sidecar format, and no configuration: the notes go on the page, and the console cuts the page in half.

Compile the deck with the `split` output:

```typ
#show: m.setup.with(output: "split")
```

Every frame becomes one page, twice the slide's width: the slide at its true size on the left half, its notes on the right. This is the layout Beamer calls notes on a second screen, and the consoles recognize it by the page's proportions alone, so there is nothing to configure in the deck beyond that one argument.

```bash
typst compile talk.typ            # talk.pdf, now double-width
pympress talk.pdf                 # splits automatically
pdfpc --notes=right talk.pdf      # tell pdfpc where the notes are
```

pympress treats any page more than twice as wide as it is tall as a slide beside its notes and needs no flag. pdfpc wants `--notes=right`. BeamerPresenter reads the same layout through its own notes-on-second-screen mode.

Because the page carries no margin of its own and the slide half is drawn unscaled, the cut falls exactly on the slide's edge: the projector shows the deck as it would look in the ordinary `slides` build, not a rescaled copy of it.

The notes half stays black on white whatever polarity the deck carries, because it is read off a laptop under house lights rather than projected. It uses the same labels the printed outputs do, so the rules above restyle it too.

If the notes on a frame do not fit their half, the compile fails and names the frame, the same way the `speaker` and `notes` outputs do. Shorten the note, or raise `notes: (split-inset: 6mm)` in `m.setup` to give it more room.

Keep both builds if you want a clean deck to hand out afterwards: the `split` PDF is for presenting, and `output: "slides"` gives you the file to circulate.
