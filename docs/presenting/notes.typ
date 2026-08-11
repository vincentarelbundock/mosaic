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

Where the notes go is an argument to `m.setup`. The rest of this page is the four answers: two printed, and two that put them on a second screen while you present.

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

= On a second screen

#calepin.elements.callout(kind: "warning", title: [Requires Mosaic 0.0.2])[
  Everything below is new in 0.0.2, which is not on Typst Universe yet, so the rest of this documentation pins the released `0.0.1`. To use these outputs, clone #link("https://github.com/vincentarelbundock/mosaic")[the repository], run `make install`, and import the development version:

  ```typ
  #import "@local/mosaic:0.0.2" as m
  ```

  See #link("https://github.com/vincentarelbundock/mosaic#install")[Install] for the full instructions. Everything above works with the package as published.
]

A presenter console drives two displays: the projector shows the slide, your laptop shows the same slide with its notes, the next slide, and a clock. Typst produces a PDF, so the console is a separate program. Two of them read the formats Mosaic writes: #link("https://pympress.xyz/")[pympress] and #link("https://pdfpc.github.io/")[pdfpc]. Both are free, both run on Linux, macOS, and Windows, and neither needs anything installed alongside your deck.

Mosaic offers two routes to them. The first changes the PDF's shape and needs no files beside it; the second keeps the deck a plain slide-shaped PDF and puts the notes in a companion file. Pick one.

#table(
  columns: 3,
  align: (left, left, left),
  table.header[][*Notes beside the slide*][*pdfpc sidecar*],
  [In `m.setup`], [`output: "split"`], [nothing],
  [Files to carry], [the PDF alone], [the PDF and its `.pdfpc`],
  [Works with], [pympress and pdfpc], [pdfpc only],
  [Notes keep], [full Typst layout], [Markdown text],
  [The PDF alone is], [double-width], [an ordinary deck],
)

== Notes beside the slide

Compile the deck with the `split` output:

```typ
#show: m.setup.with(output: "split")
```

Every frame becomes one page, twice the slide's width: the slide at its true size on the left half, its notes on the right. This is the layout Beamer calls notes on a second screen, and both consoles recognize it by the page's proportions alone, so there is nothing to configure in the deck beyond that one argument.

```bash
typst compile talk.typ            # talk.pdf, now double-width
pympress talk.pdf                 # splits automatically
pdfpc --notes=right talk.pdf      # tell pdfpc where the notes are
```

pympress treats any page more than twice as wide as it is tall as a slide beside its notes and needs no flag. pdfpc wants `--notes=right`, or the equivalent `beamerNotePosition` entry in a sidecar.

Because the page carries no margin of its own and the slide half is drawn unscaled, the cut falls exactly on the slide's edge: the projector shows the deck as it would look in the ordinary `slides` build, not a rescaled copy of it.

The notes half stays black on white whatever polarity the deck carries, because it is read off a laptop under house lights rather than projected. It uses the same labels the printed outputs do, so the rules above restyle it too.

If the notes on a frame do not fit their half, the compile fails and names the frame, the same way the `speaker` and `notes` outputs do. Shorten the note, or raise `notes: (split-inset: 6mm)` in `m.setup` to give it more room.

Keep both builds if you want a clean deck to hand out afterwards: the `split` PDF is for presenting, and `output: "slides"` gives you the file to circulate.

== A pdfpc sidecar

pdfpc can instead read notes from a JSON file named after the PDF and sitting next to it: present `talk.pdf` and pdfpc looks for `talk.pdfpc`. This route leaves the deck an ordinary slide-shaped PDF, which is what you want when the same file has to be projected without a console, emailed, or posted.

Nothing goes in `m.setup` for this. Mosaic builds the sidecar's contents from `m.note` while compiling the ordinary `slides` output; a script writes them out:

```bash
typst compile talk.typ                    # talk.pdf
scripts/mosaic-pdfpc.py talk.typ          # talk.pdfpc
pdfpc talk.pdf                            # finds the notes beside it
```

Frames after the first of a logical slide are marked as continuations of it, so pdfpc's next-slide preview skips past an incremental build to the slide that actually follows.

The format is JSON holding plain strings, so notes are flattened out of Typst content on the way in. Emphasis, inline code, lists, and paragraph breaks survive as Markdown, which is how pdfpc renders a note. Anything with no textual reading — an image, a diagram, a table's structure — does not. A note whose layout matters belongs in the `split` output.

pympress does not read this format at all. If you present with pympress, use `split`.

== Notes carried inside the PDF

The same payload is also attached to every `slides` build that has notes, under the name `speaker-notes.pdfpc`, so a deck handed to a colleague still carries what you would have said. No console reads that attachment on its own; it is transport, not installation. Recover it with poppler's `pdfdetach` and give it the PDF's name:

```bash
pdfdetach -saveall talk.pdf
mv speaker-notes.pdfpc talk.pdfpc
```

The attachment and its `<mosaic-pdfpc>` metadata appear only in the `slides` build. The `speaker`, `notes`, and `split` outputs already show on the page what it would carry.
