# Changelog

Notable changes to Mosaic. The development version in `mosaic/typst.toml` moves ahead of what Typst Universe serves, so an entry lands here before it is published.

## 0.0.3

### Breaking

- A compact cell in a hand-built grid, one directly in an `auto` row, now pads like the built-in header and footer: full `inset` left and right, `compact-inset` above and below. Before, a custom header was deeper than the header of an image slide in the same deck. Pass `inset:` on the cell to keep the old padding. Thanks to [@eddelbuettel](https://github.com/eddelbuettel) for the report.
- Under the root and default facades, `m.layouts.content()` is now `header-body` and `m.layouts.section()` is `baseline`, the layouts heading slides already used. Pass `variant: "header-body-footer"` or `variant: "plain"` for the old ones.
- A layout image given as a bare string is rejected: write `image: path("cover.webp")`. The string could only resolve inside the installed package.
- `#footnote` on a slide is a compile error. The entry used to spill onto an extra page; put the note in a footer cell.
- A positional slide body must be content. `none` is still an empty cell.
- `pause`, `steps`, and `note` inside a component (`card`, `callout`, `quote`), a `context` block, a `layout` callback, or show-rule output now fail the compile; they used to be dropped without a frame. A pause or step in a section tagline fails the same way.
- The subtitle of a `plain` or `image-*` section slide is caption-sized, like the designed variants. It used to be larger than the title.
- `install.sh` keeps a single development version: installing removes every other `@local/mosaic` version, and `--uninstall` removes them all.

### New

- `setup(spacing: (compact-inset: ..))` sets the depth of every compact cell (header, footer, or any cell in an `auto` row), built-in or hand-built. Raise it to `inset` for a deeper painted header.
- `components.quote(role:)` and `quote(accent:)` draw a rail down the left edge. A plain quotation is unchanged.
- The section layout's `accent:` colors the number in the `baseline` and `numeral` variants.
- `title(variant: "centered", rule: true)` adds a short accent rule under the heading.

### Improved

- A partial `spacing:` or `notes:` keeps the theme's other values: `setup(spacing: (gap: ..))` under editorial no longer resets its wider `inset`.
- Steps, pauses, and notes work inside tables, term lists, shapes, transforms, `columns`, and math.
- A list timed with `pause` or `on` is drawn like a revealed one, with the deck's own marker, numbering, spacing, and indents.
- A long title shrinks to fit instead of overprinting the byline.
- `fit` validates its arguments, resolves relative sizes such as `50% + 1cm`, and offers prose a wider measure before scaling it, so fitted text fills its cell's width.
- A theme's text takes the palette's `text` color before `apply` runs, so a theme only states what it overrides.
- `themes.setup` checks a definition where it is bound: a missing color is named, and unknown `defaults` keys and incomplete `layouts` are reported there.
- `slide(invert: true)` flips code highlighting with the ground, and the inverted ground reaches the page edge in a deck with a page margin.
- `set heading(offset: 1)` and constructed `heading(level: ..)` headings are styled consistently under every theme.
- New diagnostics replace raw Typst errors or silent output: a nested `slide`, a second `setup`, `setup.with(theme: ..)`, a custom `paper` side that is not a positive absolute length, an empty title, a misspelled cell `inset` or `stroke` key, a pause at the end of a list item, and a `progress` circle painted with a gradient.

### Fixed

- An `auto` track now sizes to its content whatever it holds. A nested `columns` or `rows` in an `auto` row filled the whole slide and pushed the tracks after it off the page, and a cell in an `auto` column took the full width and squeezed its siblings to nothing. Cells side by side in an `auto` row share its height, so a header beside a logo cell paints one strip, and every cell below an `auto` row takes the compact inset.
- Numbered lists (`+`, `1.`) compile under Editorial, Metropolis, Manifesto, and Mono, and keep their `start`, `numbering`, and `marker`.
- `place` without an alignment no longer aborts the slide.
- A handout keeps its headings, outline entries, and labels.
- A hidden list item hides its marker.
- A labeled figure or equation on a multi-frame slide resolves `@label` instead of reporting a duplicate.
- `steps.replace` measures its alternatives at the width it is offered and stays inline.
- A cell wrapped in `steps.on` hides its fill and stroke with its content.
- Embedded pdfpc notes count pages from zero, so each note lands on its own page rather than one late, and styled runs, symbols, and math keep their words.
- An apostrophe or other punctuation in an author name no longer empties the PDF author field.
- A neutral callout sets its title in the text color rather than the line color.
- A heading inside a scoped block no longer spreads that block's styles over the content after it.
- Speaker notes written in a section tagline are collected.

## 0.0.2

### Breaking

- `m.surface` is removed. Paint cells with native rules: `show label("mosaic-cell-header"): set block(fill: ..)`.
- Metropolis drops `font-mono`. Use `show raw: set text(font: ..)`.

### New

- Presenter console support: `output: "split"` for pdfpc and pympress, and speaker notes embedded in every PDF.
- `components.progress(quiet:)`.

### Improved

- Font fallbacks that work on macOS and Windows.
- Tidier spacing for nested lists and below headings.
- Accessible PDF export (`--pdf-standard ua-1`). Thanks to [@eddelbuettel](https://github.com/eddelbuettel) ([#7](https://github.com/vincentarelbundock/mosaic/issues/7)).
- Many bug fixes, including bold speaker notes ([#2](https://github.com/vincentarelbundock/mosaic/issues/2)) and quote credits ([#1](https://github.com/vincentarelbundock/mosaic/issues/1)), thanks to [@rlridenour](https://github.com/rlridenour).

## 0.0.1

Initial release on Typst Universe.
