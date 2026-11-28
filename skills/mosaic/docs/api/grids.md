# mosaic.grids constructors

Generated from the package sources, so it describes the development version (0.0.3) throughout; [the changelog](https://github.com/vincentarelbundock/mosaic/blob/main/CHANGELOG.md) lists what differs from the released one. Each entry shows the signature, a description, then the parameters with their types and defaults.

## grids.cell

Creates a structural leaf cell in a Mosaic grid tree.

```typ
cell(
  ..identifier,
  content: none,
  id: none,
  inset: auto
) -> dictionary
```

A cell is where slide content lands. Its id must be a non-empty string, unique within the tree, and may not be one of the reserved plane ids `background` or `foreground`. Pass it positionally or through `id:`, but not both.

```typ
#mosaic.grids.rows(
  mosaic.grids.track(auto, mosaic.grids.cell("header")),
  mosaic.grids.cell("body"),
)
```

**Styling**

Cells are structural only. Every rendered cell is labeled `<mosaic-cell-ID>`, so appearance comes from native Typst rules: `set text` and friends for properties of the content, `set block` for the cell's own block.

```typ
#show label("mosaic-cell-body"): set text(size: 0.9em)
#show label("mosaic-cell-body"): set block(fill: luma(240))
```

**Parameters**

- `..identifier` (`arguments`): The cell id, as the sole positional argument. Give it here or through `id:`.
- `content` (`content | none`, default `none`): Fixed content rendered in place of a slide body, so the surrounding slide supplies no block for this cell.
- `id` (`str | none`, default `none`): The cell id, when it is not passed positionally.
- `inset` (`auto | length | relative | dictionary`, default `auto`): Native Typst inset applied inside the cell's labeled block. `auto` uses the `spacing.inset` configured on `setup`, except for a compact cell, one directly in an `auto` row track, which hugs its content: it keeps `spacing.inset` left and right and takes `spacing.compact-inset` above and below, exactly like the header and footer of the built-in layouts.

## grids.track

Associates an explicit native track size with one child of `columns` or `rows`.

```typ
track(size, child) -> dictionary
```

Unwrapped children of a split take `1fr` and therefore share the space evenly. Wrap one in `track` to give it a size of its own.

```typ
#mosaic.grids.rows(
  mosaic.grids.track(auto, "header"),  // as tall as its content
  "body",                              // 1fr, taking the rest
  mosaic.grids.track(2em, "footer"),   // a fixed strip
)
```

The wrapper is temporary: `columns` or `rows` unwraps it while constructing the split, so a `track` value never appears in a resolved tree.

**Parameters**

- `size` (`auto | length | ratio | relative | fraction`): Native Typst grid track size. `auto` sizes to the child's content, a length or ratio fixes it, and a fraction such as `2fr` takes a share of what remains.
- `child` (`str | dictionary`): The child to size: a string cell id, or a canonical Mosaic grid node built with `cell`, `columns`, or `rows`. A node wrapped in `steps.on` is also accepted, so an incrementally revealed child can carry its own size.

## grids.columns

Splits the available width, arranging its children as columns.

```typ
columns(gutter: 0pt, stroke: none, ..children) -> dictionary
```

Children may be given in three forms, freely mixed:

- A string, which is shorthand for `cell(id)`.
- A node built with `cell`, `columns`, or `rows`, so splits nest to any depth.
- Any of those wrapped in `track` to give it an explicit track size.

A node may also be wrapped in `steps.on` so its visibility changes across incremental reveal steps.

Each unwrapped child receives a `1fr` column, so an unadorned `columns` divides the width evenly.

```typ
#mosaic.grids.columns(
  gutter: 1em,
  stroke: 0.5pt + gray,
  mosaic.grids.track(2fr, "left"),
  "right",
)
```

**Parameters**

- `gutter` (`auto | length | ratio | relative | fraction`, default `0pt`): Native Typst track size used between adjacent columns.
- `stroke` (`none | length | color | gradient | tiling | stroke | dictionary`, default `none`): Stroke drawn along each interior column boundary, centered in the gutter. A gutter of `0pt` leaves the stroke sitting directly between the columns.
- `..children` (`arguments`): The columns: string cell ids, Mosaic grid nodes, or values wrapped with `track`. At least one is required.

## grids.rows

Splits the available height, arranging its children as rows.

```typ
rows(gutter: 0pt, stroke: none, ..children) -> dictionary
```

Children take the same forms as in `columns`: a string cell id, a Mosaic grid node, either wrapped in `track`, or a node wrapped in `steps.on` for incremental reveal. Each unwrapped child receives a `1fr` row.

```typ
#mosaic.grids.rows(
  gutter: 0.7em,
  mosaic.grids.track(auto, "header"),
  mosaic.grids.columns(gutter: 1em, "left", "right"),
  mosaic.grids.track(auto, "footer"),
)
```

A cell directly in an `auto` row hugs its content; see the `inset` parameter of `cell`.

**Parameters**

- `gutter` (`auto | length | ratio | relative | fraction`, default `0pt`): Native Typst track size used between adjacent rows.
- `stroke` (`none | length | color | gradient | tiling | stroke | dictionary`, default `none`): Stroke drawn along each interior row boundary, centered in the gutter.
- `..children` (`arguments`): The rows: string cell ids, Mosaic grid nodes, or values wrapped with `track`. At least one is required.
