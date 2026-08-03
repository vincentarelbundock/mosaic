# Mosaic architecture

Mosaic keeps its public surface small while separating deferred records,
validation, rendering, document compilation, and documentation production.
Public callers import `@local/mosaic:0.0.1`; files under `mosaic/src/` are private
unless a public facade deliberately re-exports them.

## Dependency layers

Dependencies flow downward through these layers:

1. **Shared leaves**: `shared.typ`, `incremental/core.typ`, and
   `color-defaults.typ` own tags, errors, parsing primitives, visibility status,
   and color defaults.
2. **Canonical models**: the modules under `grid/`, `layout/core.typ`, `author.typ`, and
   `deck-state.typ` own validated records and state.
3. **Focused transformation support**: `incremental/command.typ`,
   `incremental/heading.typ`, `incremental/analysis.typ`,
   `incremental/transform.typ`, `note/command.typ`, `note/analysis.typ`,
   `layout/support.typ`, and
   `layout/image-support.typ` own one transformation concern each.
4. **Vertical implementations**: `layout/content.typ`, `layout/title.typ`,
   `layout/section.typ`, `components.typ`, `fit.typ`, and `grid/render.typ` implement
   complete semantic features against canonical models.
5. **Slide orchestration**: `slide/command.typ`, `layout/resolver.typ`, and
   `slide/runtime.typ` validate deferred slide commands, resolve layouts, plan
   physical frames, and invoke rendering.
6. **Document compilation**: `deck-compiler.typ` groups top-level Typst content
   into slides; private `setup-core.typ` installs resolved semantic defaults and
   starts compilation.
7. **Theme interpretation**: `themes/engine.typ` validates passive theme
   definitions, resolves their palette/defaults/options/layout hooks, applies
   their native-rule callback, and invokes `setup-core.typ`. Themes never call
   setup, settings, or compiler helpers.
8. **Bundled themes**: Light, Dark, Cream, Minimalist, and Metropolis provide
   passive definitions, callable layout modules, and thin facades that bind
   those definitions directly through the public theme extension. Light owns
   the canonical implementation; root Mosaic re-exports its facade exactly.
9. **Public facades**: `grid/api.typ`, `component/api.typ`, `layout/api.typ`,
   `incremental/api.typ`, `themes/extension.typ`, `themes/api.typ`, `shared-api.typ`, and
   `mosaic/lib.typ` assemble intentional namespaces without implementing
   behavior.

A lower layer must not import a higher layer. Implementation modules normally
import the module that owns a definition. Curated `*-api.typ` modules may also be
used by themes when the dependency is intentionally the complete internal
namespace rather than one implementation symbol.

## Public contract

The neutral facade exports exactly:

```text
setup, slide, note, pause, surface, grid, layouts, steps, components, theme, themes
```

A themed facade exports exactly:

```text
setup, slide, note, pause, surface, grid, layouts, steps, components, theme
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
through `grid/content.typ` to one cell-ID-to-content dictionary before rendering.
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

- `grid/model.typ` owns canonical values and node predicates.
- `grid/validation.typ` validates node shape, tracks, styles, and unique IDs.
- `grid/constructors.typ` owns public and layout-internal constructors.
- `grid/traversal.typ` owns tree folds, cell-ID collection, and track inspection.
- `grid/content.typ` normalizes positional and named slide content.
- `grid/render.typ` consumes valid trees and never constructs ad hoc split records.
- `grid/api.typ` exposes the curated constructors through `mosaic.grid`.

Layout resolvers must return trees built through `cell`, `h`, `v`, and `t`; they
must not hide native layout geometry behind noncanonical records.

## Layout and author subsystem

- `layout/core.typ` owns the deferred layout record and common contract checks.
- `layout/config.typ` owns the standard `content`, `title`, and `section` layout
  names, validates layout dictionaries, and supplies neutral complete defaults.
- `layout/support.typ` owns shared content, image, track, and surface mechanics.
- `layout/image-support.typ` owns private title/section image composition and
  side-effect-only image/track assertions.
- Each `layout/{name}.typ` module owns one constructor, its field contract, and
  grid resolution.
- `layout/resolver.typ` verifies the common shape and dispatches to the owner.
- `layout/api.typ` defines `mosaic.layouts`.

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
rendering therefore have one owner. `component/api.typ` exposes only documented
component constructors, not style dictionaries or state helpers.

## Slide and deck subsystem

- `deck-state.typ` owns the active named-layout dictionary and logical
  slide/section counters.
- `slide/command.typ` constructs and validates deferred slide commands.
- `slide/runtime.typ` owns output and handout modes, frozen counters/states,
  physical-frame planning, queryable frame-note metadata, plane inheritance,
  and logical-slide rendering.
- `deck-compiler.typ` groups headings and body content into automatic or explicit
  slide commands while preserving surrounding native Typst rules. Level-1
  headings select the `section` layout; level-2 headings select `content`, so
  automatic and explicit slides share one runtime path.
- `setup-core.typ` owns private semantic defaults, compiler configuration,
  standard document metadata, and the queryable `<mosaic-deck-metadata>` record;
  `themes/engine.typ` feeds it resolved definitions and root `lib.typ` re-exports
  Light's complete facade directly.
- `settings.typ` stores the resolved six-role semantic palette, canonical deck
  identity (`title`, `subtitle`, `authors`, and `date`), partial cell-content
  defaults, and the reserved default `background`/`foreground` planes. Theme
  defaults are complete; public `setup(colors: ...)` accepts
  validated partial overrides. At slide resolution, fixed grid content wins,
  explicit slide content overrides setup defaults, and defaults apply only to
  matching content-bearing cell IDs. `none` resolves an inherited cell default
  to empty content. Footers use this cell mechanism; logos are user-authored
  placed foreground content rather than a feature setting. Runtime-aware
  components such as `components.progress()` read logical counters but return
  ordinary content; authors place that content through the same cell/plane
  mechanism rather than enabling layout or setup furniture. Thus cells own
  measured structure, planes own page-wide authored visuals, and runtime state
  only supplies dynamic values. Deferred title
  layouts use `auto` fields to inherit deck
  identity at resolution time, while explicit layout values override or suppress
  them.

## Incremental subsystem

Incremental behavior is split by responsibility rather than kept in one large
module:

- `incremental/core.typ`: step-range parsing and visibility-state evaluation;
- `incremental/command.typ`: public `on`, `reveal`, `replace`, and `reduce`
  constructors plus canonical deferred records;
- `incremental/pause.typ`: the public non-rendering `pause` marker, canonical
  validation, and source-order segment splitting;
- `incremental/heading.typ`: heading inspection, style capture, inert
  continuations, and state application;
- `incremental/analysis.typ`: maximum-step discovery;
- `incremental/transform.typ`: command reduction and content reconstruction for
  one step;
- `note/command.typ`: canonical non-rendering `mosaic.note` records;
- `note/analysis.typ`: frame-aware note extraction through the same temporal
  command model;
- `incremental/api.typ`: the curated public `mosaic.steps` namespace.

`slide/runtime.typ` selects frames and invokes analysis/transformation.
`grid/render.typ` consumes an already-resolved grid at one step; it does not own
handout/output policy or public commands. Notes are collected once per physical
frame, stripped from visual content, and emitted both as printable note content
and `<mosaic-speaker-notes>` metadata. Note-only timing does not contribute to
maximum-step discovery. A private absolute logical-slide counter identifies every
emitted slide, including unnumbered title and section slides, independently of
the presentation-number counter used by furniture. Printable outputs enforce a
single bounded A4 page per emitted frame and fail explicitly when notes overflow.
Pause-separated segments are scheduled serially: each segment starts after the
complete incremental duration of the previous nonempty segment. Analysis,
transformation, and note extraction consume the same split segments and local
step offsets; empty markers therefore contribute neither content nor frames.

## Bundled themes

`themes/engine.typ` owns positional-option rejection, setup/default merging,
semantic color resolution, complete named-layout selection, and list
normalization. It consumes an exact passive definition with
design colors, setup defaults, theme-specific option defaults, optional text
arguments, layout factories, and one native-rule callback. Definition files do
not import setup internals.

The public `theme.setup(definition)` extension returns a setup function bound to
an external passive definition. A definition may provide static text arguments
or a function of its theme-specific options. Built-in facades bind directly;
there are no setup forwarding modules. Their callable layout namespaces contain
their implementations directly rather than forwarding through parallel
`layouts-impl` files. Dark, Cream, Minimalist, and Metropolis definitions retain
their typography, colors, heading rules, labels, and deliberate decoration.
Light is the simplest complete definition and the canonical implementation
re-exported by root Mosaic. Theme layout modules may consume curated
layout/component facades, while tokens remain private.

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
- Add incremental public syntax to `incremental/command.typ`, analysis to
  `incremental/analysis.typ`, heading mechanics to `incremental/heading.typ`, and
  reconstruction to `incremental/transform.typ`.
- Add frame and handout policy to `slide/runtime.typ`, not the renderer.
- Keep facade files declarative: import and re-export, never implement behavior.
- Add a fixture to the appropriate explicit manifest before implementation.
- Add an embedded example through one canonical slug and make the integrity
  checker pass; add a complete deck through the deck manifest.
- Prefer small semantic owners over abstraction driven only by clone metrics.
