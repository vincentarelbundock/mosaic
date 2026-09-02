# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Mosaic is a slide package for Typst (0.15+). The `mosaic/` directory is the package itself; everything else (tests, scripts, docs, Makefile) is repository tooling around it. Python tooling runs through `uv run python`.

## Commands

- `make install` — copy `mosaic/` into Typst's package index as `@local/mosaic:0.0.2` (the version comes from `mosaic/typst.toml`). Every test imports that spelling, so the working tree is what the suite exercises; run this after any package source change and before compiling anything by hand. `make uninstall` removes the copy. Both delegate to `install.sh`, which resolves the package path cross-platform (`TYPST_PACKAGE_PATH`, then `typst info`, then the per-OS default) and, when piped from the network, fetches a GitHub snapshot instead of copying a working tree — that curl one-liner is what the README and docs give readers who want the unreleased version.
- `make check` — the whole test suite in one target: the facade export contract (`cd tests && uv run python -m unittest test_check_api_exports test_theme_architecture test_palettes`, plus `scripts/check-api-exports.py`), the `core` and `layout` and `negative` manifest groups, and `scripts/check-doc-assets.py`.
- One manifest group, without a make target: `uv run python scripts/run-tests.py core|layout|negative --typst typst`.
- Single positive test: `make install`, then `typst compile --root . tests/<name>.typ /tmp/out.pdf` from the repo root. Many core tests also have output assertions in `scripts/run-tests.py` (pdftotext/SVG greps), so a clean compile is necessary but not always sufficient.
- Single negative test: `typst compile --root . tests/invalid/<name>.typ /tmp/out.pdf` must fail with the exact diagnostic listed in `tests/invalid/expected-diagnostics.txt`.
- `make website` — render `docs-src/` into `docs/` from the committed example artifacts; `make build` = doctor + install + check + website. `make doctor` checks prerequisites. Calepin owns `docs/` and wipes it on every build, so never edit anything there and never add a file to it by hand.
- `make publish-docs` — `docs/` is gitignored so routine commits never carry a rebuild. This target rebuilds the site and force-stages it (`git add -f`, minus Calepin's manifest and Syncthing conflict copies) for a deliberate GitHub Pages commit; it stages only, and never commits or pushes.
- `make artifacts` — re-render the committed example artifacts (embedded PDFs and SVGs, deck PDFs and covers, the showcase reel). The website build no longer does this, so run it deliberately after changing an example or the package's visual output.
- `make release-stage` — sync the README and its illustrations into the package, then stage the Typst Universe file set in `dist/packages/preview/mosaic/{version}/`, ready to copy into a `typst/packages` fork.
- `make clean` removes every generated file: build stamps, the generated API manuals, Calepin's caches, the rendered site, and all example artifacts. The artifacts are committed, so a clean shows up as deletions in `git status` until `make artifacts` re-renders them (minutes of work); restore them from git if all you wanted was a fresh cache. `make help` lists all eleven commands.

Test manifests are exhaustive and enforced: every `tests/*.typ` must appear in `tests/positive-manifest.json` (groups `core`, `layout`, `responsive`), and every `tests/invalid/*.typ` needs a `stem|expected diagnostic` line in `tests/invalid/expected-diagnostics.txt`. Adding or renaming a fixture without updating the manifest fails the run.

## Versions

Two version numbers are in play and they move independently. `mosaic/typst.toml` holds the *development* version, currently 0.0.2: what this source tree is. The *released* version, currently 0.0.1, is what Typst Universe serves, and publishing to Universe takes days, so it lags deliberately.

That split decides which spelling a file imports:

- **`tests/**` and the package's own files import the development version** (`@local/mosaic:0.0.2`). They must exercise the working tree; left on the released version they would resolve from Universe and pass while the source was broken.
- **`docs-src/**` imports the released version** (`@preview/mosaic:0.0.1`), so every snippet and example deck on the website copy-pastes for a reader who has installed nothing. This is also why `make artifacts` renders the examples against the published package rather than the working tree — the website documents what is released.
- **A documentation page describing an unreleased feature** is the one exception: it pins `@local/mosaic:0.0.2` in its own snippets and carries a `calepin.elements.callout(kind: "warning", ...)` naming the version and pointing at the README's install instructions. `docs-src/presenting/notes.typ` is the worked example.

Bumping the development version is one `sed` over the non-`docs-src` tree plus `typst.toml`; it also rewrites `mosaic/src/shared.typ`'s `tag`, which is the state-key namespace and is meant to move with the version. Releasing is a separate act (`make release-stage`), and the website only reaches the public through `make publish-docs`, so a source change is never live before you choose.

## Conventions

`CONVENTIONS.md` is authoritative for all `.typ` code: kebab-case everywhere, the `is-`/`validate-`/`require-`/`resolve-`/`render-` verb families, the one-word-per-concept vocabulary (node/cell/track/grid, fields/options/settings/record, gap vs gutter vs spacing vs inset), and signature shape (one positional subject, named booleans, native-superset shadows). Read it before writing package code.

Two project-specific rules worth restating:
- Hard-coded visual constants belong in a theme's `apply` function as `set`/`show` rules, not as new token records.
- Themes deliberately repeat structure; do not factor a shared base `apply` across themes.

Documentation prose is never hard-wrapped. Write each paragraph as one long line and let the editor soft-wrap it; do not insert artificial line breaks at a column limit. This applies to prose in `docs-src/`, `skills/`, and Markdown files. Code blocks and code comments wrap normally.

## Architecture

**Facades.** `mosaic/lib.typ` is the root import and is the default theme facade (`src/themes/default.typ`), re-exporting `src/shared-api.typ` (`slide`, `note`, `fit`, `surface`, `grids`, `layouts`, `steps`, `components`, `palettes`) plus `themes` as a namespace holding the built-in facades and the theme-extension API (`themes.setup`). `pause` lives in `steps`. Every theme (`default`, `editorial`, `metropolis`, `manifesto`, `mono`) is a thin facade file next to a directory, all exposing the identical API, and each is a design voice: editorial (magazine serif, kicker title, numeral sections), metropolis (beamer homage with progress chrome), manifesto (red poster, bordered title, rule sections), mono (terminal, toc sections, statusline). There is no dark theme: polarity is a palette, passed through `setup(colors: palettes.dark)`, and each theme's `apply` derives dark adaptations (the syntax highlighting theme, via `src/themes/polarity.typ`) from the canvas luminance. A single slide inverts with `slide(invert: true)`, which swaps canvas and text for that slide and derives muted/line/surface to match. `src/palettes.typ` is the curated palette collection every facade exports as `palettes` (`light`/`dark` plus six schemes); `tests/test_palettes.py` enforces a contrast contract on the bundled palettes, including invertibility, while user palettes passed to `setup(colors: ..)` are deliberately never validated. `scripts/check-api-exports.py` and the tests in `tests/test_check_api_exports.py` pin these exports exactly.

**Deck record.** One Typst `state` value carries everything `setup` declares, split across two files: `src/deck-state.typ` is the channel (the state, the write-once guard `write-deck-record`, and the logical-slide counters), and `src/deck-record.typ` is the shape (the seven fields documented field by field at the top of that file, the no-deck fallback `default-deck-record`, the reader `read-deck-record`, and `configure-deck`, the single validating writer). The split keeps `deck-state.typ` importing nothing but `shared.typ`, so subsystems whose validators the writer depends on can still read the channel. The record is written exactly once by `setup` and never mutated. Readers that can run outside a deck take the fallback; `info()` deliberately does not, and fails instead.

**Compilation pipeline.** `#show: m.setup` routes the document through `src/setup-core.typ` → `src/deck-compiler.typ`, which turns top-level content into slides using a heading policy (default: `=` opens a section slide, `==` a content slide; user-overridable). Explicit `m.slide(...)` commands (`src/slide/command.typ`) and automatic heading slides both render through `src/slide/runtime.typ`.

**Theme engine.** Themes are passive definition dictionaries (`name`, `colors`, `roles`, `defaults`, `layouts`, `options`, `apply`) consumed by the private engine in `src/themes/engine.typ`, which validates them and wires them into `setup-core`. `src/themes/extension.typ` is the public theme-extension API.

**Major subsystems under `mosaic/src/`:**
- `grid/` — the named-cell layout tree: `model` (node/cell/track dicts), `constructors` (`cell`, `columns`, `rows`, `track`), `validation`, `traversal`, `render`.
- `layout/` — the named layouts (`title`, `section`, `content`, `image`) plus `config`/`resolver` for per-deck layout configuration.
- `incremental/` — pauses and reveal steps (`pause`, `analysis`, `transform`).
- `component/` — user-facing components (card, callout, badge, quote, divider, progress, figure, image).
- `note/` — speaker notes; `shared.typ` — `fail()` (prefixes `mosaic: `, which negative tests rely on) and `key()` for state keys.

**Docs.** The website is split in two. `docs-src/` is the Calepin source: every authored page, `calepin.toml`, the `theme/`, the `_includes/`, the `diagrams/`, the `assets/`, and the example projects, plus the rendered example artifacts that are committed alongside them. `docs/` is the site Calepin writes from it: build output end to end, including the `.typ` copies and the `assets/` and `examples/` payloads Calepin stages there, so every edit belongs in `docs-src/`. It is gitignored and enters the index only through `make publish-docs`, which force-adds it; GitHub Pages serves whatever that last publish commit contained, so a source change is not live until the site is rebuilt and published. Embedded examples live in `docs-src/examples/embedded/` and full decks in `docs-src/examples/decks/<slug>/` (each with its own Makefile); the top-level Makefile renders them into `docs-src/assets/examples/` and `scripts/check-doc-assets.py` validates that pages, artifacts, and frame counts stay in sync, then re-checks links against the rendered `docs/`. API reference pages are generated: the `typst-doc` CLI reads the `///` comments out of the package sources and writes one entry file per documented function into `docs-src/api/generated/<group>/`, plus the `index.typ` the page includes. The `API_GROUP_<group>` variables in the Makefile name each page's inputs, in the order the page presents them, and one typst-doc run per page is what lets a cross-reference between two entries on the same page resolve to a real link. Adding a public function to an existing page needs nothing; a new page means a new `API_GROUP_*` variable, a name in `API_GROUPS`, a `docs-src/api/<group>.typ` that calls `api-page` and includes its index, and a sidebar entry in `calepin.toml`. The generated tree is gitignored build output; `docs-src/api/sources/setup.typ` is the one hand-written input, because `setup` is documented separately from its implementation.

**Authoring skill.** `skills/mosaic/SKILL.md` is the tutorial for writing decks with Mosaic; use it when authoring or debugging user-facing slide code rather than package internals.
