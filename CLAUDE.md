# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Mosaic is a slide package for Typst (0.15+). The `mosaic/` directory is the package itself; everything else (tests, scripts, docs, Makefile) is repository tooling around it. Python tooling runs through `uv run python`.

## Commands

- `make install` — copy `mosaic/` into Typst's local package index as `@local/mosaic:0.0.1`. Tests and docs import the installed copy, so run this after any package source change and before compiling anything by hand.
- `make check` — full test suite: `api-contract`, `core-tests`, `layout-tests`, `negative-tests`, `doc-integrity`.
- `make core-tests` / `make layout-tests` / `make negative-tests` — one manifest group (`uv run python scripts/run-tests.py core|layout|negative --typst typst` under the hood).
- `make api-contract` — exact facade export checks: `cd tests && uv run python -m unittest test_check_api_exports test_theme_architecture`, plus `scripts/check-api-exports.py`.
- Single positive test: `make install`, then `typst compile --root . tests/<name>.typ /tmp/out.pdf` from the repo root. Many core tests also have output assertions in `scripts/run-tests.py` (pdftotext/SVG greps), so a clean compile is necessary but not always sufficient.
- Single negative test: `typst compile --root . tests/invalid/<name>.typ /tmp/out.pdf` must fail with the exact diagnostic listed in `tests/invalid/expected-diagnostics.txt`.
- `make website` (or `docs`) — build the Calepin documentation site; `make build` = doctor + install + check + website. `make doctor` checks prerequisites.

Test manifests are exhaustive and enforced: every `tests/*.typ` must appear in `tests/positive-manifest.json` (groups `core`, `layout`, `responsive`), and every `tests/invalid/*.typ` needs a `stem|expected diagnostic` line in `tests/invalid/expected-diagnostics.txt`. Adding or renaming a fixture without updating the manifest fails the run.

## Conventions

`CONVENTIONS.md` is authoritative for all `.typ` code: kebab-case everywhere, the `is-`/`validate-`/`require-`/`resolve-`/`render-` verb families, the one-word-per-concept vocabulary (node/cell/track/grid, fields/options/settings/record, gap vs gutter vs spacing vs inset), and signature shape (one positional subject, named booleans, native-superset shadows). Read it before writing package code.

Two project-specific rules worth restating:
- Hard-coded visual constants belong in a theme's `apply` function as `set`/`show` rules, not as new token records.
- Themes deliberately repeat structure; do not factor a shared base `apply` across themes.

## Architecture

**Facades.** `mosaic/lib.typ` is the root import and is the light theme facade (`src/themes/light.typ`), re-exporting `src/shared-api.typ` (`slide`, `note`, `fit`, `surface`, `grids`, `layouts`, `steps`, `components`) plus `themes` as a namespace holding the built-in facades and the theme-extension API (`themes.setup`, `themes.light-palette`, `themes.light-roles`). `pause` lives in `steps`. Every theme (`light`, `dark`, `cream`, `metropolis`, `minimalist`) is a thin facade file next to a directory, all exposing the identical API. `scripts/check-api-exports.py` and the tests in `tests/test_check_api_exports.py` pin these exports exactly.

**Deck record.** `src/deck-state.typ` holds one Typst `state` value for everything `setup` declares (settings, layouts, handout, paper, output, freezing). It is written exactly once by `setup` and never mutated; `write-deck-record` enforces this. Readers that can run outside a deck treat `none` as "no deck" and fall back to library defaults.

**Compilation pipeline.** `#show: m.setup` routes the document through `src/setup-core.typ` → `src/deck-compiler.typ`, which turns top-level content into slides using a heading policy (default: `=` opens a section slide, `==` a content slide; user-overridable). Explicit `m.slide(...)` commands (`src/slide/command.typ`) and automatic heading slides both render through `src/slide/runtime.typ`.

**Theme engine.** Themes are passive definition dictionaries (`name`, `colors`, `roles`, `defaults`, `layouts`, `options`, `apply`) consumed by the private engine in `src/themes/engine.typ`, which validates them and wires them into `setup-core`. `src/themes/extension.typ` is the public theme-extension API.

**Major subsystems under `mosaic/src/`:**
- `grid/` — the named-cell layout tree: `model` (node/cell/track dicts), `constructors` (`h`, `v`, `cell`, `t`), `validation`, `traversal`, `render`.
- `layout/` — the named layouts (`title`, `section`, `content`, `image`) plus `config`/`resolver` for per-deck layout configuration.
- `incremental/` — pauses and reveal steps (`pause`, `analysis`, `transform`).
- `component/` — user-facing components (frame, callout, tag, quote, divider, progress, figure, image).
- `note/` — speaker notes; `shared.typ` — `fail()` (prefixes `mosaic: `, which negative tests rely on) and `key()` for state keys.

**Docs.** `docs/` is a Calepin website. Embedded examples live in `docs/examples/embedded/` and full decks in `docs/examples/decks/<slug>/` (each with its own Makefile); the top-level Makefile renders them into `docs/assets/examples/` and `scripts/check-doc-assets.py` validates that pages, artifacts, and frame counts stay in sync. API reference pages stage package sources into `docs/api/modules/` via the `API_MODULE_MAP` in the Makefile; adding a public module means adding a mapping there.

**Authoring skill.** `skills/mosaic/SKILL.md` is the tutorial for writing decks with Mosaic; use it when authoring or debugging user-facing slide code rather than package internals.
