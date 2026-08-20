# Mosaic roadmap

This backlog records capabilities found in the Touying 0.7.4 and Polylux 0.4.0 feature review that Mosaic does not currently provide. It is a feature inventory, not a commitment to reproduce either framework. New APIs should preserve Mosaic's small, Typst-native grid model.

The comparison does not repeat features Mosaic already has: heading-driven and explicit slides with a configurable heading policy, automatic section slides, speaker notes with thumbnail and notes-only outputs, logical slide/section and step progress, background and foreground planes, native outlines and bookmarks, range-based visibility, item-by-item reveals, space-preserving alternatives, math overlays, CeTZ/Fletcher reducers, composable grids, or per-slide inherited grid and visual-plane configuration.

## Incremental content

- [ ] Add progressive raw-code display with optional line numbers, configurable reveal and highlight ranges, and styling for past, current, and future lines.

## Structure, navigation, and configuration

- [ ] Add appendix mode with an appendix-aware main-slide count and denominator.
- [ ] Support short heading/title variants for navigation furniture without changing the visible or semantic heading.
- [ ] Add adaptive and progressive outline helpers, including multi-column outlines.
- [ ] Add clickable previous/next controls and distinguish navigation by logical slide, physical frame, or both.

## Academic content

- [ ] Allow footnote numbering to reset per logical slide.
