# Mosaic architecture

Mosaic keeps its public surface small while separating deferred data models from
rendering and document compilation. Public callers should import
`@local/mosaic:0.0.1`; files under `mosaic/src/` are implementation modules
unless explicitly staged for API docs.

## Dependency layers

Dependencies flow downward through these layers:

1. **Shared values and parsing** — `shared.typ`, `incremental-core.typ`,
   `color.typ`
2. **Canonical models** — `grid-model.typ`, `layout-core.typ`,
   `deck-state.typ`
3. **Layout implementation** — `layout-support.typ` and the cohesive
   `layout-default.typ`, `layout-title.typ`, `layout-section.typ`,
   `layout-image.typ`, and `layout-table.typ` modules
4. **Commands and rendering** — `deck-commands.typ`, `layout-resolver.typ`,
   `incremental.typ`, `fit.typ`, `render.typ`, `slide-runtime.typ`
5. **Document compilation and setup** — `deck-compiler.typ`, `setup.typ`
6. **Bundled themes** — `themes/metropolis.typ`, `themes/cream.typ`, and
   `themes/minimalist.typ`; each imports lower-layer modules directly (never
   `lib.typ`, which would be circular) and exports the theme convention
   surface (`apply`, layout factories, `colors`, `palette`)
7. **Public facades** — `grid-api.typ`, `component-api.typ`,
   `layout-api.typ`, `theme-api.typ`, and `mosaic/lib.typ`

A lower layer must not import a higher layer. Internal modules import the owner
of each definition directly; facades exist only for intentional public namespaces.

## Styling model: structural cells, native rules

Mosaic owns structure; Typst owns appearance. Grid cells are structural
records (id, optional fixed content, inset, sizing and fit behavior, plus
layout-internal fill/background paint for image variants). They carry no text
styles, alignment, or user-facing surface fields, and `mosaic.slide` accepts
no styling arguments.

Every rendered cell is one block labeled `<mosaic-cell-ID>` (with placed
`<mosaic-cell-ID-{center,top,...}>` anchor points inside it). Appearance is
supplied with ordinary label-targeted rules:

```typst
#show label("mosaic-cell-header"): set text(weight: "medium")
#show label("mosaic-cell-body"): set align(horizon)
#show label("mosaic-cell-body"): it => block(fill: luma(240), it)
```

Precedence is native rule nesting: `setup` emits defaults for the canonical
cell vocabulary (`section`, `title`, `authors`, `details`, `footer`,
`table-title`, `caption`, `source`, `highlight`); a theme's `apply` rules are
defined inside them and win; deck-level rules after `#show: setup` win over
both; rules scoped in a block around a single slide command override
everything for that slide only. The compiler captures top-level set/show
wrappers and re-applies them around rendered slides (automatic and explicit),
so label rules always see the rendered cell structure.

Two mechanics keep this predictable: em insets are resolved against the text
size just outside the label, so typography rules cannot scale cell geometry;
and the inset lives inside the label, so wrapping rules paint edge to edge.
When overriding a size the defaults already set (for example the section or
title display size), prefer absolute sizes; em sizes compound across nested
rules.

## Grid subsystem

- `grid-model.typ` owns the canonical cell/split records, constructor
  implementations, validation, traversal, and cell/body counting.
- `grid-api.typ` exposes those constructors through the public `mosaic.grid`
  namespace.
- `render.typ` consumes valid grid trees; it does not construct or mutate them.

## Layout subsystem

- `layout-core.typ` owns the common deferred record shape and shared contract
  primitives.
- `layout-support.typ` owns shared content, image, track, and surface helpers.
- Each `layout-{name}.typ` module owns one layout's public constructor,
  field validation, and grid resolution. The larger `layout-title.typ`
  remains cohesive around its nine variants.
- `layout-resolver.typ` verifies the common record shape, applies local color
  roles, and dispatches to the owning layout module.
- `layout-api.typ` defines the public `mosaic.layouts` namespace.

`component-api.typ` similarly keeps component styling helpers private while
exposing only the documented `mosaic.components` namespace.

Layout resolvers must return canonical grid trees through `cell`, `h`, `v`,
and `t`. They must not bypass those constructors with hidden native layout
geometry or direct split records.

## Deck subsystem

- `deck-state.typ` owns deck planes, logical-slide state, slide/page numbering,
  and heading queries.
- `deck-commands.typ` validates and constructs deferred deck/slide commands.
- `slide-runtime.typ` owns handout mode, frozen counters/states, current-step
  state, physical-frame planning, and logical-slide rendering.
- `deck-compiler.typ` walks top-level document content and groups headings/body
  content into automatic or explicit slide commands.
- `setup.typ` owns document-wide Typst defaults and starts deck compilation.

## Incremental subsystem

- `incremental-core.typ` is a dependency leaf for step-range parsing and
  visibility-state evaluation. It remains separate because both
  `grid-model.typ` and `incremental.typ` depend on it.
- `incremental.typ` owns the public `on`, `reveal`, `replace`, and `reduce`
  constructors together with maximum-step discovery and incremental content
  transformation.
- `render.typ` consumes an already-resolved grid tree at one incremental step;
  it does not own frame selection or handout policy.

## Tests and generated API sources

`tests/internal-architecture.typ` verifies that the internal boundaries remain
importable and expose their intended responsibilities. Behavioral tests continue
to exercise the public facade.

`make api-sources` stages only documentation-bearing source modules into
`docs/api/modules/`. API pages map explicitly to those cohesive modules rather
than import-only facades, because Tidy parses source text without following
re-exports. `make clean` removes every staged `.typ` file so obsolete copies
cannot mask missing declarations.

## Adding code

- Add layout-specific construction, validation, and resolution to the
  layout's own vertical-slice module.
- Add grid traversal beside the canonical grid model; keep public grid mutation
  out of the API.
- Add visual composition to the relevant resolver or renderer.
- Add top-level grouping and command sequencing to the compiler.
- Keep facade files declarative; they should import/re-export, not implement.
- Preserve public behavior with a failing test before changing implementation.
