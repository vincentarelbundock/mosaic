# Mosaic architecture

Mosaic keeps its public surface small while separating deferred data models from
rendering and document compilation. Public callers should import
`@local/mosaic:0.0.1`; files under `mosaic/src/` are implementation modules
unless explicitly staged for API docs.

## Dependency layers

Dependencies flow downward through these layers:

1. **Shared values and parsing** — `shared.typ`, `incremental-core.typ`,
   `color.typ`
2. **Canonical models** — `grid-model.typ`, `template-core.typ`,
   `deck-state.typ`
3. **Template implementation** — `template-support.typ` and the cohesive
   `template-default.typ`, `template-title.typ`, `template-section.typ`,
   `template-image.typ`, and `template-table.typ` modules
4. **Commands and rendering** — `deck-commands.typ`, `template-resolver.typ`,
   `incremental.typ`, `fit.typ`, `render.typ`, `slide-runtime.typ`
5. **Document compilation and setup** — `deck-compiler.typ`, `setup.typ`
6. **Public facades** — `grid-api.typ`, `component-api.typ`,
   `template-api.typ`, and `mosaic/lib.typ`

A lower layer must not import a higher layer. Internal modules import the owner
of each definition directly; facades exist only for intentional public namespaces.

## Grid subsystem

- `grid-model.typ` owns the canonical cell/split records, constructor
  implementations, validation, traversal, and cell/body counting.
- `grid-api.typ` exposes those constructors through the public `mosaic.grid`
  namespace.
- `render.typ` consumes valid grid trees; it does not construct or mutate them.

## Template subsystem

- `template-core.typ` owns the common deferred record shape and shared contract
  primitives.
- `template-support.typ` owns shared content, image, track, and surface helpers.
- Each `template-{name}.typ` module owns one template's public constructor,
  field validation, and grid resolution. The larger `template-title.typ`
  remains cohesive around its nine variants.
- `template-resolver.typ` verifies the common record shape, applies local color
  roles, and dispatches to the owning template module.
- `template-api.typ` defines the public `mosaic.templates` namespace.

`component-api.typ` similarly keeps component styling helpers private while
exposing only the documented `mosaic.components` namespace.

Template resolvers must return canonical grid trees through `cell`, `h`, `v`,
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

- Add template-specific construction, validation, and resolution to the
  template's own vertical-slice module.
- Add grid traversal beside the canonical grid model; keep public grid mutation
  out of the API.
- Add visual composition to the relevant resolver or renderer.
- Add top-level grouping and command sequencing to the compiler.
- Keep facade files declarative; they should import/re-export, not implement.
- Preserve public behavior with a failing test before changing implementation.
