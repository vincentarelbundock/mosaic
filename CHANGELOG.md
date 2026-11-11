# Changelog

Notable changes to Mosaic. The development version in `mosaic/typst.toml` moves ahead of what Typst Universe serves, so an entry lands here before it is published.

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
