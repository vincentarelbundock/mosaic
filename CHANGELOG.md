# Changelog

Notable changes to Mosaic. The development version in `mosaic/typst.toml` moves ahead of what Typst Universe serves, so an entry lands here before it is published.

## 0.0.3

This version tightens the public API and breaks several older spellings to get there. Every removed spelling fails with a message that names its replacement.

### Breaking

- The title layout's picture variants are `image-left`, `image-right`, `image-top`, `image-bottom`, and `image-background`, the same names the section layout uses. `variant: "image", position: "right"` becomes `variant: "image-right"`, and a bare `variant: "image"`, which meant left, becomes `variant: "image-left"`. One word, `variant`, now selects a layout's arrangement everywhere; `position:` existed only for this one variant and is removed.
- A layout's `image:` is a `path(..)` or content. The dictionary form `image: (path: path("a.webp"), scrim: .., fit: .., alt: ..)` becomes `image: components.image(path("a.webp"), scrim: .., fit: .., alt: ..)`, so a picture is built by the one function that already builds pictures everywhere else. A bare string is rejected as well: it could only resolve inside the installed package.
- `setup(headings:)` is an array indexed by heading level. `headings: ("1": "section", "2": "slide")` becomes `headings: ("section", "slide")`, with `none` for a level that opens no slide, because levels are positions and a dictionary keyed by strings of digits only imitated one.
- Positional slide bodies follow one rule: a slide's opening heading is its header, and everything else fills the cells in order. `slide[== Title][Body]` is unchanged, and a heading that opens the first body is now lifted into the header, so the first body's destination no longer depends on how many bodies there are. `slide[Plain][Body]` on a layout with a header is an error; write `slide(cells: (header: [Plain], body: [Body]))`. A cell with a deck default from `setup(cells:)` is reached only through `cells:`; positional bodies pass over it.
- `slide` without `#show: m.setup` is an error. It used to compile to nothing.
- `info().slide.number` is `none` on an unnumbered slide. It used to carry the previous slide's number, which read as this slide's; test `slide.numbered`.
- Theme definitions state `font` and `base-size` under `defaults`, not `options`: `options: (font: "Inter", base-size: 20pt)` becomes `defaults: (font: "Inter", base-size: 20pt)`. They are deck options every theme accepts, so a custom theme no longer has to declare them for `setup(font: ..)` to work.
- `steps.on` with a body that is not content is a drawing command, valid only inside `steps.drawing`; anywhere else it fails instead of printing a dictionary. Write text as content: `on(2)[text]`.
- The label `<mosaic-section-title>` now marks the visible title text of a section slide, like every other tier label. The queryable record of each section, which carried that label, is `<mosaic-section-record>`. `<mosaic-section-subtitle>` now labels the subtitle in the `plain` and `image-*` variants too.
- A compact cell in a hand-built grid, one directly in an `auto` row, now pads like the built-in header and footer: full `inset` left and right, `compact-inset` above and below. Before, a custom header was deeper than the header of an image slide in the same deck. Pass `inset:` on the cell to keep the old padding. Thanks to [@eddelbuettel](https://github.com/eddelbuettel) for the report.
- Under the root and default facades, `m.layouts.content()` is now `header-body` and `m.layouts.section()` is `baseline`, the layouts heading slides already used. Pass `variant: "header-body-footer"` or `variant: "plain"` for the old ones.
- `#footnote` on a slide is a compile error. The entry used to spill onto an extra page; put the note in a footer cell.
- A positional slide body must be content. `none` is still an empty cell.
- `pause`, `steps`, and `note` inside a `context` block of your own, a `layout` callback, or show-rule output now fail the compile; they used to be dropped without a frame.
- The subtitle of a `plain` or `image-*` section slide is caption-sized, like the designed variants. It used to be larger than the title.
- `install.sh` keeps a single development version: installing removes every other `@local/mosaic` version, and `--uninstall` removes them all.

### New

- `setup(font: .., base-size: ..)` works under every theme, custom themes included. A theme's headings are multiples of the base size, so the deck scales with it.
- `themes.decorate-heading` declares a heading rule that rebuilds the heading (`show heading: it => ..`) so that it holds on every frame of an incremental slide.
- `setup(spacing: (compact-inset: ..))` sets the depth of every compact cell (header, footer, or any cell in an `auto` row), built-in or hand-built. Raise it to `inset` for a deeper painted header.
- `title(variant: "image-background")` sets the title stack over a full-slide picture.
- `none` suppresses any inherited field of a title slide: `title`, `subtitle`, `date`, or `authors`.
- `components.quote` is a superset of the native `quote`: `block:`, `quotes:`, and a label as `attribution:` keep their native meaning. `quote(role:)` and `quote(accent:)` draw a rail down the left edge; a plain quotation is unchanged.
- The section layout's `accent:` colors the number in the `baseline` and `numeral` variants, and the `baseline` hairline with it.
- `title(variant: "centered", rule: true)` adds a short accent rule under the heading, and `title(variant: "panel", rule: false)` hides the panel's.
- `badge(radius: auto)` is the default, like every other component override.

### Improved

- Everything Mosaic provides is transparent to its own commands. `pause`, `steps`, and `note` work inside `card`, `callout`, `quote`, `badge`, `divider`, and `figure`, and in the content a layout takes as a field, such as a section tagline or a title slide's title and subtitle, as they already did inside tables, term lists, shapes, transforms, `columns`, and math.
- A note never adds a frame and is never dropped: tied to a step the slide does not reach, it is shown on the last frame.
- A dimmed component mutes its fill, border, and rail along with its text, whether the step is written inside the cell or wraps the grid cell that holds it.
- `steps.drawing` needs `hide:` only when a command is actually hidden.
- A list timed with `pause`, `on`, or `reveal` keeps the exact position and shape of the same list untimed, with the deck's own marker, numbering, spacing, and indents.
- A title too long for its slide is scaled to fit instead of overprinting the byline. A title scaled this way fits, so `overflow:` does not report it.
- `fit` validates its arguments, resolves relative sizes such as `50% + 1cm`, and offers prose a wider measure before scaling it, so fitted text fills its cell's width.
- The engine states the base typography before a theme's `apply` runs (text color, font, and base size), so a theme only states what it adds.
- `themes.setup` checks a definition where it is bound: a missing color is named, and unknown `defaults` keys and incomplete `layouts` are reported there.
- `slide(invert: true)` flips code highlighting with the ground and keeps a `raw` theme the deck set for itself, and the inverted ground reaches the page edge in a deck with a page margin.
- Heading sizes hold under `set heading(offset: ..)`, and constructed `heading(level: ..)` headings are styled like written ones, under every theme. A `set text(size: ..)` after `setup` changes body text and no longer rescales the Default and Metropolis headings; use `base-size`.
- A partial `spacing:` or `notes:` keeps the theme's other values: `setup(spacing: (gap: ..))` under editorial no longer resets its wider `inset`.
- New diagnostics replace raw Typst errors or silent output: a nested `slide`, a second `setup`, `setup.with(theme: ..)`, a custom `paper` side that is not a positive absolute length, content written after an explicit slide, a picture given to a variant that takes none, an empty title, a misspelled cell `inset` or `stroke` key, a pause at the end of a list item, and a `progress` circle painted with a gradient.

### Fixed

- An `auto` track now sizes to its content whatever it holds. A nested `columns` or `rows` in an `auto` row filled the whole slide and pushed the tracks after it off the page, and a cell in an `auto` column took the full width and squeezed its siblings to nothing. Cells side by side in an `auto` row share its height, so a header beside a logo cell paints one strip, and every cell below an `auto` row takes the compact inset.
- Numbered lists (`+`, `1.`) compile under Editorial, Metropolis, Manifesto, and Mono, and keep their `start`, `numbering`, and `marker`.
- `place` without an alignment no longer aborts the slide.
- A handout keeps its headings, outline entries, and labels.
- Section and title headings look the same on every frame of a multi-frame slide, and a title slide carries one real heading, so one outline entry, however many frames it has.
- A hidden list item hides its marker.
- A labeled figure or equation on a multi-frame slide resolves `@label` instead of reporting a duplicate.
- `steps.replace` measures its alternatives at the width it is offered and stays inline.
- A cell wrapped in `steps.on` hides its fill and stroke with its content.
- A captioned figure built from ready-made content, such as a scrimmed picture, takes the region above its caption instead of collapsing.
- Embedded pdfpc notes count pages from zero, so each note lands on its own page rather than one late, and styled runs, symbols, and math keep their words.
- An apostrophe or other punctuation in an author name no longer empties the PDF author field.
- A neutral callout sets its title in the text color rather than the line color.
- A heading inside a scoped block no longer spreads that block's styles over the content after it.

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
