# Changelog

Notable changes to Mosaic. The development version in `mosaic/typst.toml` moves ahead of what Typst Universe serves, so an entry lands here before it is published.

## Unreleased (0.0.2)

### Fixed

- Accessible export. The title slide is now tagged as the level-one heading, so a deck of `==` content slides compiles under `--pdf-standard ua-1` without a filler `=` section; the title stays out of the outline and the bookmarks. Every theme's chrome (the progress ring, line, folio, and statusline) and mono's `$` heading prompt are marked as decoration, so a screen reader no longer announces the slide number on every slide or reads the prompt as part of the heading. Thanks to [@eddelbuettel](https://github.com/eddelbuettel) for the report ([#7](https://github.com/vincentarelbundock/mosaic/issues/7)).
- Speaker notes no longer render bold in the `notes` and `split` outputs. The frame heading's `·` splits its markup into several text elements, so the `<mosaic-note-heading>` label attached to a bare sequence and carried the heading's bold weight into everything the code-mode joins placed after it. Thanks to [@rlridenour](https://github.com/rlridenour) for reporting this ([#2](https://github.com/vincentarelbundock/mosaic/issues/2)).
- `components.quote` no longer sets a space before the comma separating `attribution` from `source`; the credit now reads `Aristotle, Politics`. The three parts of the credit were joined across separate markup lines, and the newline between them became a space. Thanks to [@rlridenour](https://github.com/rlridenour) for reporting this ([#1](https://github.com/vincentarelbundock/mosaic/issues/1)).

## 0.0.1

Initial release on Typst Universe.
