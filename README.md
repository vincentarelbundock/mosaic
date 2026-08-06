<p align="center">
  <img src="docs/assets/mosaic-slide.svg" alt="Mosaic" width="150">
</p>

<h1 align="center">Mosaic</h1>

<p align="center"><em>Beautiful slides for <a href="https://typst.app/">Typst</a>.</em></p>

Write your talk as an ordinary Typst document and Mosaic makes the slides for you. Style them with the `set` and `show` rules you already know, because Mosaic is a thin layer on Typst rather than a framework: it adds slides, named cells, and sensible defaults, then leaves the rest of the document to the language itself. Batteries included: modern themes, ready-made layouts, nested grids, incremental reveals, speaker notes, handouts, callouts, cards, quotes, and progress indicators.

## Install

Mosaic 0.0.1 requires Typst 0.15 or newer. It is currently installed from source as a local Typst package:

```sh
git clone https://github.com/vincentarelbundock/mosaic.git
cd mosaic
make install
```

## A complete deck

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(title: [A short talk])

#m.slide(layout: "title")

= Methods

== Data

One slide.

== Model

Another slide.
```

Compile it with `typst compile talk.typ`. A level-one heading opens a section slide, a level-two heading a content slide, and everything between them is ordinary Typst content.

## Features

- Automatic slides from `=` and `==` headings, or explicit `m.slide(..)` commands when you want control.
- Title, section, content, and image layouts, each with visual variants.
- Nested row and column grids whose cells carry stable names.
- Native styling throughout: `set page`, `set text`, and `show label("mosaic-cell-body")` all work as written, with no framework-specific arguments to learn.
- Five interchangeable themes (`default`, `editorial`, `metropolis`, `manifesto`, `mono`) exposing an identical API, so switching is a one-line edit.
- Curated palettes, including dark, passed to `setup` as one argument; any single slide inverts with `slide(invert: true)`.
- Incremental reveals and pauses in five commands.
- Speaker notes, with `speaker` and `notes` outputs for printing, plus a handout mode that collapses every build to its final frame.
- Components for callouts, cards, badges, quotes, dividers, figures, and progress indicators.
- Overflow detection that names the cell and the slide when content is clipped.
- An [agent skill](skills/mosaic/SKILL.md) that teaches coding agents to write Mosaic decks.

## Why Mosaic

For an ordinary deck, Mosaic and [Touying](https://github.com/touying-typ/touying), the most established Typst presentation framework, are very similar: import the package, pick a theme, write headings, get slides. They diverge once a deck needs something the published themes do not provide. A framework stands between you and Typst, so changing something starts with finding the function or argument that controls it. Mosaic exports about thirty commands and twenty setup options, and adds exactly one concept: a slide is a grid of cells, and each cell has a name. Those names are Typst labels, so a cell is styled with the same `show` rule syntax as any other labelled element, and a custom slide is an ordinary Typst function with no framework state to thread through.

## Documentation

The full documentation site, including the API reference and runnable examples, builds with `make website` and opens at `docs/index.html`. `make check` runs the test suite.

## Gallery

One slide per beat from the example decks, in the order the showcase reel plays them.

![Contact sheet of slides from the Mosaic example decks, three across](docs/assets/images/showcase-contact-sheet.webp)

---

Mosaic is licensed under MIT; see [`mosaic/typst.toml`](mosaic/typst.toml).
