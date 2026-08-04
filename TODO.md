# Mosaic roadmap

This backlog records capabilities found in the Touying 0.7.4 and Polylux
0.4.0 feature review that Mosaic does not currently provide. It is a feature
inventory, not a commitment to reproduce either framework. New APIs should
preserve Mosaic's small, Typst-native grid model.

Sections below the feature inventory record findings from real deck-authoring
sessions rather than the framework comparison; each notes how it was observed.
Several come from one corpus in particular: twenty POL1025 lecture decks,
6,938 lines of Typst and 423 `m.slide` calls, converted from Quarto/reveal.js.
That is one author and one conversion event, so the counts quoted below are
evidence to check, not weight on their own.

The comparison does not repeat features Mosaic already has: heading-driven
and explicit slides with a configurable heading policy, automatic section
slides, speaker notes with thumbnail and notes-only outputs, logical
slide/section and step progress,
background and foreground planes, native outlines and bookmarks, range-based
visibility, item-by-item reveals, space-preserving alternatives, math
overlays, CeTZ/Fletcher reducers, composable grids, or per-slide inherited
grid and visual-plane configuration.

## Incremental content

- [ ] Add progressive raw-code display with optional line numbers,
  configurable reveal and highlight ranges, and styling for past, current,
  and future lines.

## Speaker notes and presenting

- [ ] Assign a note to a frame automatically, from where it occurs in the
  reveal sequence. Today a note reaches one frame only by being wrapped in
  `steps.on`, `steps.reveal`, or `steps.replace` by hand.

## Structure, navigation, and configuration

- [ ] Add appendix mode with an appendix-aware main-slide count and
  denominator.
- [ ] Support short heading/title variants for navigation furniture without
  changing the visible or semantic heading.
- [ ] Add adaptive and progressive outline helpers, including multi-column
  outlines.
- [ ] Add clickable previous/next controls and distinguish navigation by
  logical slide, physical frame, or both.

## Academic content

- [ ] Allow footnote numbering to reset per logical slide.

## Layout and styling

- [ ] Consider a captioned-image component, for example
  `m.components.figure(src, caption: ..)` defaulting to `fit: "contain"`.
  `m.components.image` defaults to `fit: "cover"`, which is right for background
  planes and wrong for a chart that must not be cropped, and no component pairs
  an image with a caption. In a 58-slide lecture deck ported from Quarto, nearly
  every slide was one centred, contained figure; the deck defines a local `fig()`
  helper and calls it about forty times. This is the most repeated helper in an
  image-heavy academic deck.

  The same gap shows up one step further in: a figure placed inside an ordinary
  content cell, rather than in a stacked image layout, has to be wrapped in
  `align(center, ..)` and given a hand-found height. The corpus uses twelve
  distinct values (30% through 88%), and the author documents at
  `04_politique_fiscale.typ:130` why the stacked layouts do not cover the case:
  four bullets plus a photograph is more than their body band holds. Worth
  deciding whether the component centres by default, whether `height: auto`
  should mean "fill the remaining cell", and whether a prose-plus-figure layout
  variant belongs beside the stacked ones.

## Documentation

- [ ] Document compatible presentation workflows without adding
  viewer-specific integrations to Mosaic.

## State

- [ ] A big promise of mosaic is that it has no hidden state and that everything is governed by standard show/set rules. That's not true now. We have `settings` and other objects to hold states and constants. Review them and make a proposal for consistency.
