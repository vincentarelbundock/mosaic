# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Mosaic is a slide package for Typst (0.15+). The `mosaic/` directory is the package itself; everything else (tests, scripts, docs, Makefile) is repository tooling around it. Python tooling runs through `uv run python`.

## Commands

- `make install` — copy `mosaic/` into Typst's package index as `@preview/mosaic:0.0.1`. Tests, docs, and example decks all import that published spelling, so the working tree shadows the Universe copy while developing; run this after any package source change and before compiling anything by hand. `make uninstall` removes the shadow.
- `make check` — full test suite: `api-contract`, `core-tests`, `layout-tests`, `negative-tests`, `doc-integrity`.
- `make core-tests` / `make layout-tests` / `make negative-tests` — one manifest group (`uv run python scripts/run-tests.py core|layout|negative --typst typst` under the hood).
- `make api-contract` — exact facade export checks: `cd tests && uv run python -m unittest test_check_api_exports test_theme_architecture`, plus `scripts/check-api-exports.py`.
- Single positive test: `make install`, then `typst compile --root . tests/<name>.typ /tmp/out.pdf` from the repo root. Many core tests also have output assertions in `scripts/run-tests.py` (pdftotext/SVG greps), so a clean compile is necessary but not always sufficient.
- Single negative test: `typst compile --root . tests/invalid/<name>.typ /tmp/out.pdf` must fail with the exact diagnostic listed in `tests/invalid/expected-diagnostics.txt`.
- `make website` (or `docs`) — build the Calepin documentation site from the committed example artifacts; `make build` = doctor + install + check + website. `make doctor` checks prerequisites.
- `make artifacts` — re-render the committed example artifacts (embedded PDFs and SVGs, deck PDFs and covers, the showcase reel). The website build no longer does this, so run it deliberately after changing an example or the package's visual output.
- `make release-stage` — stage the Typst Universe file set in `dist/packages/preview/mosaic/{version}/`, ready to copy into a `typst/packages` fork.

Test manifests are exhaustive and enforced: every `tests/*.typ` must appear in `tests/positive-manifest.json` (groups `core`, `layout`, `responsive`), and every `tests/invalid/*.typ` needs a `stem|expected diagnostic` line in `tests/invalid/expected-diagnostics.txt`. Adding or renaming a fixture without updating the manifest fails the run.

## Conventions

`CONVENTIONS.md` is authoritative for all `.typ` code: kebab-case everywhere, the `is-`/`validate-`/`require-`/`resolve-`/`render-` verb families, the one-word-per-concept vocabulary (node/cell/track/grid, fields/options/settings/record, gap vs gutter vs spacing vs inset), and signature shape (one positional subject, named booleans, native-superset shadows). Read it before writing package code.

Two project-specific rules worth restating:
- Hard-coded visual constants belong in a theme's `apply` function as `set`/`show` rules, not as new token records.
- Themes deliberately repeat structure; do not factor a shared base `apply` across themes.

Documentation prose is never hard-wrapped. Write each paragraph as one long line and let the editor soft-wrap it; do not insert artificial line breaks at a column limit. This applies to prose in `docs/`, `skills/`, and Markdown files. Code blocks and code comments wrap normally.

## Architecture

**Facades.** `mosaic/lib.typ` is the root import and is the default theme facade (`src/themes/default.typ`), re-exporting `src/shared-api.typ` (`slide`, `note`, `fit`, `surface`, `grids`, `layouts`, `steps`, `components`, `palettes`) plus `themes` as a namespace holding the built-in facades and the theme-extension API (`themes.setup`). `pause` lives in `steps`. Every theme (`default`, `editorial`, `metropolis`, `manifesto`, `mono`) is a thin facade file next to a directory, all exposing the identical API, and each is a design voice: editorial (magazine serif, kicker title, numeral sections), metropolis (beamer homage with progress chrome), manifesto (red poster, bordered title, rule sections), mono (terminal, toc sections, statusline). There is no dark theme: polarity is a palette, passed through `setup(colors: palettes.dark)`, and each theme's `apply` derives dark adaptations (the syntax highlighting theme, via `src/themes/polarity.typ`) from the canvas luminance. A single slide inverts with `slide(invert: true)`, which swaps canvas and text for that slide and derives muted/line/surface to match. `src/palettes.typ` is the curated palette collection every facade exports as `palettes` (`light`/`dark` plus six schemes); `tests/test_palettes.py` enforces a contrast contract on the bundled palettes, including invertibility, while user palettes passed to `setup(colors: ..)` are deliberately never validated. `scripts/check-api-exports.py` and the tests in `tests/test_check_api_exports.py` pin these exports exactly.

**Deck record.** One Typst `state` value carries everything `setup` declares, split across two files: `src/deck-state.typ` is the channel (the state, the write-once guard `write-deck-record`, and the logical-slide counters), and `src/deck-record.typ` is the shape (the seven fields documented field by field at the top of that file, the no-deck fallback `default-deck-record`, the reader `read-deck-record`, and `configure-deck`, the single validating writer). The split keeps `deck-state.typ` importing nothing but `shared.typ`, so subsystems whose validators the writer depends on can still read the channel. The record is written exactly once by `setup` and never mutated. Readers that can run outside a deck take the fallback; `info()` deliberately does not, and fails instead.

**Compilation pipeline.** `#show: m.setup` routes the document through `src/setup-core.typ` → `src/deck-compiler.typ`, which turns top-level content into slides using a heading policy (default: `=` opens a section slide, `==` a content slide; user-overridable). Explicit `m.slide(...)` commands (`src/slide/command.typ`) and automatic heading slides both render through `src/slide/runtime.typ`.

**Theme engine.** Themes are passive definition dictionaries (`name`, `colors`, `roles`, `defaults`, `layouts`, `options`, `apply`) consumed by the private engine in `src/themes/engine.typ`, which validates them and wires them into `setup-core`. `src/themes/extension.typ` is the public theme-extension API.

**Major subsystems under `mosaic/src/`:**
- `grid/` — the named-cell layout tree: `model` (node/cell/track dicts), `constructors` (`h`, `v`, `cell`, `t`), `validation`, `traversal`, `render`.
- `layout/` — the named layouts (`title`, `section`, `content`, `image`) plus `config`/`resolver` for per-deck layout configuration.
- `incremental/` — pauses and reveal steps (`pause`, `analysis`, `transform`).
- `component/` — user-facing components (card, callout, badge, quote, divider, progress, figure, image).
- `note/` — speaker notes; `shared.typ` — `fail()` (prefixes `mosaic: `, which negative tests rely on) and `key()` for state keys.

**Docs.** `docs/` is a Calepin website. Embedded examples live in `docs/examples/embedded/` and full decks in `docs/examples/decks/<slug>/` (each with its own Makefile); the top-level Makefile renders them into `docs/assets/examples/` and `scripts/check-doc-assets.py` validates that pages, artifacts, and frame counts stay in sync. API reference pages stage package sources into `docs/api/modules/` via the `API_MODULE_MAP` in the Makefile; adding a public module means adding a mapping there.

**Authoring skill.** `skills/mosaic/SKILL.md` is the tutorial for writing decks with Mosaic; use it when authoring or debugging user-facing slide code rather than package internals.
