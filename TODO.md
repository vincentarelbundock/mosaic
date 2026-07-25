# Mosaic roadmap

This backlog records capabilities found in the Touying 0.7.4 and Polylux
0.4.0 feature review that Mosaic does not currently provide. It is a feature
inventory, not a commitment to reproduce either framework. New APIs should
preserve Mosaic's small, Typst-native grid model.

The comparison does not repeat features Mosaic already has: heading-driven
and explicit slides, automatic section slides, logical/step/page counters,
background and foreground planes, native outlines and bookmarks, range-based
visibility, item-by-item reveals, space-preserving alternatives, math
overlays, CeTZ/Fletcher reducers, composable grids, or per-slide inherited
grid and visual-plane configuration.

## Images

- [ ] #img() helper which is the same as #image() but with lighten/darken and some other helpers for common behaviors in slides.

## Incremental content

- [ ] Add concise sequential and parallel advancement primitives comparable
  to `pause`, `meanwhile`, `jump`, or independent reveal strands.
- [ ] Add progressive raw-code display with configurable reveal points and
  styling for past, current, and future lines.

## Handouts

- [ ] Allow a slide to retain the first, last, selected, ranged, or
  waypoint-selected frames in handout mode.
- [ ] Support handout-only slides and inline handout-only content.

## Speaker notes and presenting

- [ ] Attach speaker notes to a logical slide or selected frames; accumulate
  multiple note blocks rather than silently replacing earlier notes.
- [ ] Support progressive note content and automatic frame assignment based
  on where a note occurs in the reveal sequence.
- [ ] Provide presenter grids such as notes on a second screen, a slide
  thumbnail beside notes, and a notes-only document.

## Structure, navigation, and configuration

- [ ] Make the heading depth that creates slides configurable and support
  subsection/subsubsection structure plus optional automatic divider slides.
- [ ] Add structural controls for hidden, skipped-divider, unnumbered,
  unoutlined, unbookmarked, and handout-only headings/slides.
- [ ] Add appendix mode with an appendix-aware main-slide count and
  denominator.
- [ ] Support short heading/title variants for navigation furniture without
  changing the visible or semantic heading.
- [ ] Expose a progress ratio for custom navigation furniture.
- [ ] Add adaptive and progressive outline helpers, including multi-column
  outlines.
- [ ] Add clickable previous/next controls and distinguish navigation by
  logical slide, physical frame, or both.
- [ ] Add a next-slide configuration scope with predictable inheritance and
  reset behavior.

## Academic content

- [ ] Allow footnote numbering to reset per logical slide.

## Documentation

- [ ] Document MiTeX and Pinit composition using Mosaic's native content and
  generic reducer extension points.
- [ ] Document theorem-package use, including frozen theorem counters on
  incremental slides.
- [ ] Document citation workflows using native Typst footnotes and
  bibliographies.
- [ ] Document compatible presentation workflows without adding
  viewer-specific integrations to Mosaic.
