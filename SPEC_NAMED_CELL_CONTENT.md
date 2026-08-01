# Named cell content (as built)

**Status:** Implemented
**Scope:** Content assignment for `mosaic.slide` and custom grids
**Compatibility:** Positional content preserved as shorthand; named form added

This records what shipped. It deliberately differs from the original review
proposal in a few places; those deviations and their rationale are listed
under "Decisions" below.

## What shipped

`mosaic.slide` gains one named parameter, `cells:`, a dictionary mapping each
content-bearing cell's ID to its content:

```typst
#mosaic.slide(
  grid: mosaic.grid.h(mosaic.grid.v("heading", "left"), "right"),
  cells: (
    heading: [Heading],
    left: [Left argument],
    right: [Right argument],
  ),
)
```

Positional bodies remain the terse shorthand and are unchanged:

```typst
#mosaic.slide[Ordinary body content]
```

The cell ID is now the single handle across all three cell operations:

- `mosaic.grid.cell("body")` defines the structural destination;
- `cells: (body: [...])` supplies its content;
- `label("mosaic-cell-body")` targets its appearance.

### Assignment

- A content-bearing cell is one whose grid record has `content: none`. Fixed
  cells are owned by the grid and are not destinations.
- Positional: bodies fill content-bearing cells in the grid's depth-first
  declaration order (unchanged behavior).
- Named: `cells` assigns by ID; dictionary order is irrelevant. Every
  content-bearing cell must have an entry.
- Named and positional cannot be combined in one call.

### Validation

`resolve-named-content` (in `grid-model.typ`) validates a `cells` dictionary
against the resolved grid and returns the bodies in traversal order. The
diagnostics:

```text
mosaic: slide cells must be a dictionary
mosaic: slide cells contains unknown cell id "sidebar"
mosaic: slide cells cannot supply fixed-content cell "logo"
mosaic: slide cell content for "body" must be content
mosaic: slide cells is missing content for cell "footer"     (all missing IDs reported at once)
mosaic: slide cannot combine named and positional cell content
```

The not-a-dictionary and mixed-content checks fire in `slide()` at the call
site; unknown, fixed, type, and missing checks fire in the slide runtime once
the inherited or explicit grid is resolved.

## Decisions (deviations from the original proposal)

1. **One internal model; positional and named both normalize to the ordered
   body array the renderer already consumes.** The original outline kept "the
   positional cursor path for positional commands" alongside a new by-ID
   lookup, i.e. two routing implementations. Instead, `cells:` is validated and
   ordered by `body-cell-ids` traversal order into the same array a positional
   call produces, then handed to the unchanged renderer. This keeps one render,
   overflow, and incremental path; makes "named and positional render
   identically" true by construction rather than by matching; and touches the
   renderer not at all.

2. **Dropped the "unnamed content-bearing cell" diagnostic.** Grid cell IDs are
   already mandatory and unique (`resolve-cell-id` rejects empty/non-string
   IDs), so an unnamed content-bearing cell cannot exist. The proposed
   diagnostic guarded an unreachable state; removing it also means named
   assignment is always well-defined.

3. **`order:` / semantic reading order deferred entirely**, with no hook left
   behind. Render order stays grid-traversal order. Named routing changes only
   how content reaches a cell, not the order cells are emitted.

4. **Positional content stays fully supported, not a deprecated legacy form.**
   It is the desugaring source, the right default for the one-cell slide, and
   what every layout factory uses internally.

## Answers to the review questions

1. **Parameter name:** `cells:`. `content:` collides with `cell(content:)` and
   the Typst `content` type; `cell-content:` is longer. `cells:` also mirrors
   the `(id: value)` shape decks knew from the removed `cell-styles`.
2. **Require all cells vs. omitted-empty:** require all, matching the existing
   exact-count contract. Omitted-means-empty would reintroduce a silent hole.
3. **Reject mixed input:** yes. One assignment model per call; relaxable later.
4. **Positional as legacy:** no; fully supported (see decision 4).
5. **Fixed-cell override:** none. The grid owns fixed content.
6. **Semantic order before shipping:** no; deferred (decision 3).
7. **Factories exposing `cells:`:** factories keep their semantic arguments and
   translate internally; they may use positional or named as they prefer.

## Non-goals (unchanged from the proposal)

- Styling through `cells:`. Appearance remains native rules on
  `<mosaic-cell-ID>` labels.
- Replacing fixed cell content used internally by layouts.
- Optional content-bearing cells (every `content: none` cell must be supplied).
- Arbitrary cell IDs as direct `mosaic.slide` parameters.

## Tests

- `tests/named-cells.typ`: `body-cell-ids` order; `resolve-named-content`
  order-independence and equivalence to positional; the command record's
  `cells` field; fixed cells excluded from destinations; incremental
  destinations; and rendered named vs. positional slides.
- `tests/invalid/slide-cells-{type,unknown,fixed,missing,content-type,mixed}.typ`
  with matching entries in `expected-diagnostics.txt`.
