# Mosaic architecture

Mosaic keeps its public surface small while separating deferred records,
validation, rendering, document compilation, and documentation production.
Public callers import `@local/mosaic:0.0.1`; files under `mosaic/src/` are private
unless a public facade deliberately re-exports them.

## Dependency layers

Dependencies flow downward through these layers:

1. **Shared leaves**: `shared.typ`, `incremental-core.typ`, and
   `color-defaults.typ` own tags, errors, parsing primitives, visibility status,
   and color defaults.
2. **Canonical models**: `grid-model.typ`, `layout-core.typ`, `author.typ`, and
   `deck-state.typ` own validated records and state.
3. **Focused transformation support**: `incremental-command.typ`,
   `incremental-heading.typ`, `incremental-analysis.typ`,
   `incremental-transform.typ`, `layout-support.typ`, and
   `layout-image-support.typ` own one transformation concern each.
4. **Vertical implementations**: `layout-default.typ`, `layout-title.typ`,
   `layout-section.typ`, `components.typ`, `fit.typ`, and `render.typ` implement
   complete semantic features against canonical models.
5. **Slide orchestration**: `slide-command.typ`, `layout-resolver.typ`, and
   `slide-runtime.typ` validate deferred slide commands, resolve layouts, plan
   physical frames, and invoke rendering.
6. **Document compilation**: `deck-compiler.typ` groups top-level Typst content
   into slides; `setup.typ` installs document defaults and starts compilation.
7. **Bundled themes**: the Cream, Minimalist, and Metropolis modules combine a
   themed setup with layouts and curated internal facades. They never import
   `lib.typ`, which would be circular. `themes/setup-common.typ` owns only the
   shared setup protocol; each theme owns its visual rules.
8. **Public facades**: `grid-api.typ`, `component-api.typ`, `layout-api.typ`,
   `steps-api.typ`, `theme-api.typ`, `shared-api.typ`, and `mosaic/lib.typ`
   assemble intentional namespaces without implementing behavior.

A lower layer must not import a higher layer. Implementation modules normally
import the module that owns a definition. Curated `*-api.typ` modules may also be
used by themes when the dependency is intentionally the complete internal
namespace rather than one implementation symbol.

## Public contract

The neutral facade exports exactly:

```text
setup, slide, grid, layouts, steps, components, themes
```

A themed facade exports exactly:

```text
setup, slide, grid, layouts, steps, components
```

The supported public components are `frame`, `callout`, `label`, `quote`,
`divider`, `progress`, and `image`. Exact exports are checked statically by
`scripts/check-api-exports.py`; its scanner removes Typst comments while
preserving strings before following re-exports. Parser unit tests cover line and
nested block comments, commented imports, strings, aliases, and cycles.

## Styling model: structural cells and native rules

Mosaic owns structure; Typst owns appearance. Grid cells are structural records:
an ID, optional fixed content, inset, sizing/fit behavior, and limited
layout-internal paint required by semantic image variants. They carry no public
text styles, alignment, or general surface fields, and `mosaic.slide` accepts no
styling arguments.

Every rendered cell is one block labeled `<mosaic-cell-ID>`, with placed
`<mosaic-cell-ID-{center,top,...}>` anchor points inside it. Appearance uses
ordinary label-targeted rules:

```typst
#show label("mosaic-cell-header"): set text(weight: "medium")
#show label("mosaic-cell-body"): set align(horizon)
#show label("mosaic-cell-body"): it => block(fill: luma(240), it)
```

Precedence is native rule nesting. `setup` emits baseline rules; themed setup
adds theme rules; deck-level rules after `#show: setup` override both; and rules
scoped around one slide override only that slide. The compiler captures
top-level set/show wrappers and reapplies them around automatic and explicit
slides so label rules always see rendered cells.

Em insets resolve against the text size outside the label, so typography cannot
accidentally scale cell geometry. The inset lives inside the label, allowing a
wrapping show rule to paint edge to edge.

## Content routing

`mosaic.slide` accepts positional bodies or a `content:` dictionary. Both normalize
through `grid-model.typ` to one cell-ID-to-content dictionary before rendering.
Positional bodies fill content-bearing cells in depth-first declaration order;
`content:` assigns cells by stable ID and addresses the planes through the
reserved `background` and `foreground` entries. `resolve-content` validates the
cell entries against
`body-cell-ids`. Rendering, overflow observation, and incremental processing
therefore consume one representation.

The cell ID is the common handle across definition, assignment, and styling:

```text
cell(id) → content: (id: ...) → label("mosaic-cell-id")
```

## Grid subsystem

- `grid-model.typ` owns canonical cell/split records, constructors, validation,
  traversal, track introspection, and content routing.
- `grid-api.typ` exposes constructors through `mosaic.grid`.
- `render.typ` consumes valid trees and never constructs ad hoc split records.

Layout resolvers must return trees built through `cell`, `h`, `v`, and `t`; they
must not hide native layout geometry behind noncanonical records.

## Layout and author subsystem

- `layout-core.typ` owns the deferred layout record and common contract checks.
- `layout-support.typ` owns shared content, image, track, and surface mechanics.
- `layout-image-support.typ` owns private title/section image composition and
  side-effect-only image/track assertions.
- Each `layout-{name}.typ` module owns one constructor, its field contract, and
  grid resolution.
- `layout-resolver.typ` verifies the common shape and dispatches to the owner.
- `layout-api.typ` defines `mosaic.layouts`.

`author.typ` owns the canonical author record and one `analyze-authors` pass. That
pass validates authors, rejects conflicting affiliation names, deduplicates
affiliations, and computes author-to-affiliation numbers. Ordinary and academic
title variants consume the same analysis; constructors and resolvers may still
revalidate because Typst dictionaries are mutable.

Validators are explicit about their role. Assertion procedures such as
`validate-accent`, `validate-semantic-image-use`, and
`validate-directional-tracks` return no value. Normalizers such as
`validate-visual-spec` return the canonical value their caller must consume.

## Components and furniture

`components.typ` owns component validation and rendering. Global progress
furniture and layout-supplied progress both call the same private implementation
behind `components.progress`; counter selection, percentage calculation, and line
rendering therefore have one owner. `component-api.typ` exposes only documented
component constructors, not style dictionaries or state helpers.

## Slide and deck subsystem

- `deck-state.typ` owns background/foreground planes and logical slide/section
  state.
- `slide-command.typ` constructs and validates deferred slide commands.
- `slide-runtime.typ` owns handout mode, frozen counters/states, physical-frame
  planning, global furniture, and logical-slide rendering.
- `deck-compiler.typ` groups headings and body content into automatic or explicit
  slide commands while preserving surrounding native Typst rules.
- `setup.typ` owns document defaults and compiler configuration.

## Incremental subsystem

Incremental behavior is split by responsibility rather than kept in one large
module:

- `incremental-core.typ`: step-range parsing and visibility-state evaluation;
- `incremental-command.typ`: public `on`, `reveal`, `replace`, and `reduce`
  constructors plus canonical deferred records;
- `incremental-heading.typ`: heading inspection, style capture, inert
  continuations, and state application;
- `incremental-analysis.typ`: maximum-step discovery;
- `incremental-transform.typ`: command reduction and content reconstruction for
  one step;
- `steps-api.typ`: the curated public `mosaic.steps` namespace.

`slide-runtime.typ` selects frames and invokes analysis/transformation.
`render.typ` consumes an already-resolved grid at one step; it does not own
handout policy or public commands.

## Bundled themes

`themes/setup-common.typ` owns the mechanical setup protocol: positional-option
rejection, base-option merging, automatic default-slide construction, section
layout selection, and tight-list normalization. Cream, Minimalist, and Metropolis
retain their own typography, colors, heading rules, labels, and furniture. This
extracts policy without turning visual differences into a generic theme engine.

Theme layout modules may consume curated internal layout/component facades when
they need the complete semantic namespace. Theme facade files remain declarative
and export the exact themed contract.

## Test architecture

`tests/positive-manifest.json` explicitly classifies every positive Typst fixture
as core, layout, or responsive. `scripts/run-tests.py` compiles those fixtures and
owns PDF text extraction, SVG color assertions, Typst query assertions, handout
checks, and overflow checks. Make only orchestrates the runner.

Every `tests/invalid/*.typ` fixture has exactly one entry in
`tests/invalid/expected-diagnostics.txt`. The runner rejects missing, duplicate,
or stale manifest entries and requires the fixture to fail with that exact Mosaic
diagnostic, preventing an unrelated earlier failure from passing the test.

Facade fixtures verify public use while focused helpers under `tests/support/`
inspect canonical records without adding production exports. The broad grid and
runtime integration deck is named `tests/grid-runtime.typ`; generic filename
classification is not used.

## Documentation and example pipeline

Authored documentation lives in `docs/*.typ`; executable examples are separated
by purpose:

```text
docs/examples/decks/       complete independently buildable decks
docs/examples/embedded/    page-owned executable snippets
docs/assets/examples/      generated embedded PDFs, covers, and SVG frames
docs/_includes/            shared documentation components
docs/api/modules/          generated API-source staging
```

`docs/_includes/embedded-examples.typ` binds each canonical embedded slug to both
the exact displayed source and its rendered artifact. Multi-frame slideshow
selection is parsed by `scripts/embedded_examples.py`; underscore-prefixed source
files are adjacent private dependencies, not entry points.

`docs/_includes/pdf-slideshow.typ` is the single accessible PDF viewer markup
owner for both embedded examples and complete decks. CSS uses neutral
`pdf-slideshow-*` classes, and `pdf-slideshow.js` binds only `data-pdf-*`
behavior attributes.

`docs/examples/decks/manifest.json` is the canonical complete-deck registry. It
owns slug, title, frame count, alt text, and showcase-page selection. The
Examples gallery reads it with Typst `json`, Make discovers deck slugs through
`scripts/deck_metadata.py`, and the showcase-video script reads the same
selection. Simple deck Makefiles share `docs/examples/decks/common.mk`; decks
with genuinely different compilers keep local recipes.

`scripts/check-doc-assets.py` enforces source/consumer completeness, renderer to
artifact selection, stale-output absence, embedded and complete-deck page counts,
and deck-manifest completeness. After Calepin renders the site it also validates
every local link and HTML anchor. `scripts/normalize-html.py` removes generator
trailing whitespace before those publication files are compared or committed.

## Generated-output policy

Generated files have three lifetimes:

1. `make clean` removes ephemeral API staging, Calepin working state, and build
   stamps.
2. `make clean-generated` additionally removes reproducible embedded assets,
   deck PDFs/covers, WebP derivatives, and the showcase video.
3. `make distclean` additionally removes published HTML and Calepin's generated
   cache.

Published HTML remains in `docs/` for the repository's deployment convention.
Calepin's regenerable `_calepin` cache is ignored and untracked except for the
published `favicon.svg` referenced by those HTML pages. Machine-local `.hermes/`
and `.claude/settings.local.json` state is ignored.

API documentation is staged from the implementation modules named in the
Makefile because Tidy parses source text without following re-exports. API pages
map explicitly to cohesive documentation-bearing modules.

## Tooling and prerequisites

`scripts/doctor.py` reports required tools for package checks and documentation
builds separately, followed by optional integrations and fonts. Core checks
require Python, Typst, `pdftotext`, and `pdfinfo`. Documentation builds add
Calepin, `pdftoppm`, FFmpeg, and Pillow. WebP conversion is implemented by the
small deterministic `scripts/convert-web-image.py` tool rather than an opaque
external image CLI.

## Adding code

- Add record invariants and traversal beside the canonical model that owns them.
- Add layout construction, validation, and resolution to that layout's vertical
  module; move a cross-layout relationship to one explicit shared owner.
- Add incremental public syntax to `incremental-command.typ`, analysis to
  `incremental-analysis.typ`, heading mechanics to `incremental-heading.typ`, and
  reconstruction to `incremental-transform.typ`.
- Add frame and handout policy to `slide-runtime.typ`, not the renderer.
- Keep facade files declarative: import and re-export, never implement behavior.
- Add a fixture to the appropriate explicit manifest before implementation.
- Add an embedded example through one canonical slug and make the integrity
  checker pass; add a complete deck through the deck manifest.
- Prefer small semantic owners over abstraction driven only by clone metrics.
