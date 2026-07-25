# SPEC: candidate helpers for Mosaic

Proposals distilled from rebuilding four real-world decks in `ppt/`. Each
entry lists the friction observed, a sketch of the API, and what it would
replace. Nothing below is implemented yet.

## 2. Page border overlay

The cream deck draws an inset border on most slides by hardcoding the page
geometry (`rect(width: 814pt, height: 446pt)` placed at `14pt, 14pt`), which
silently breaks if the paper size changes. `m.components.frame` is a content
block, not a page overlay.

```typst
m.components.border(margin: 14pt, stroke: 0.8pt + white)
```

Foreground content sized relative to the page.

## 4. Item and card components

The micro-pattern "bold title, linebreak, supporting text", mapped over a
stack or grid, appears at least eight times (topic grids, product lists,
stats, team rosters, exhibition cards):

```typst
m.components.item([Topic 1], [Elaborate on your topic here.])
m.components.items(pairs, columns: 2, gutter: 18pt)
m.components.card(image: path("assets/team1.png"), title: [Jane Doe],
  subtitle: [Director], body: [...])
```

Typography derived from `settings.type` so items follow the deck theme.

## 7. Keyed slide bodies (longer term)

Positional bodies force placeholder `[]` blocks and make body-to-cell mapping
fragile as grids grow. Cells already have ids; `slide` could optionally accept
bodies keyed by id:

```typst
#slide(grid: ..., bodies: (title: [...], photo: [...]))
```

Fixed-content cells (`content:`) already remove most of the pressure; this is
the root fix if it recurs.

## Rejected

- **Role-based text helpers** (`m.text.title` / `m.text.body`): resolved, not
  built. Typography is native Typst — the deck's `title()` / `copy()` shims were
  a documentation gap, not a missing API. Mosaic's own type defaults are applied
  as ordinary `set text` and `show heading` rules inside `m.setup`, so a deck
  styles itself with the same rules: `#set text(font: ...)` for the base and
  `#show heading.where(depth: 1): set text(...)` for titles. No `setup(type:)`
  argument, no `m.theme()` accessor, and no `m.text.*` namespace were added.
  Two changes made this real: (1) template body regions were changed to carry
  no text delta so ambient `set text` flows into template-driven cells
  (previously they re-applied the theme font and silently overrode native
  overrides), guarded by `tests/setup-inherited-font.typ`; (2) the approach is
  documented on the Typography page (`docs/typography.typ`). The supporting
  roles (`subtitle`, `caption`, `small`) stay private furniture defaults, not a
  public vocabulary.

- **Photo gallery grid** (`m.components.gallery`): the native pattern
  `grid(columns: ..., gutter: g, ..names.map(photo))` is already short, and a
  dedicated helper would add a third image entry point beside `m.image` and
  `templates.image`. If the friction recurs, extend `m.image` to accept an
  array of sources (`m.image((a, b, c), columns: 3, gutter: 8pt)`) instead of
  adding a new name; `templates.image` could accept an array `path` on the
  same helper for whole-slide galleries.

