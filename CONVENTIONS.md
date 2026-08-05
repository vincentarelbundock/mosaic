# Naming and signature conventions

Rules for all `.typ` code in this repository. They were derived from a full
audit of the source in August 2026 and applied in one refactor; new code must
follow them.

## Case and structure

- kebab-case for every binding, parameter, dictionary key, label, and state
  key. No snake_case, camelCase, or uppercase names.
- The underscore prefix is reserved for two uses: capturing a native Typst
  function before shadowing it (`_native-image`, `_native-figure`) and internal
  module aliases (`#import "..." as _base`). Ordinary private helpers carry no
  underscore; Typst has no visibility control and the prefix must stay
  meaningful.
- Labels carry the `mosaic-` prefix. State keys go through `key()` in
  `shared.typ`. All failures go through `fail()`, which prepends `mosaic: `.

## Verb families

- `is-x` and `has-x` are boolean predicates. There is no `valid-x` family.
- `validate-x` is the only verb at the input boundary. It asserts via
  `fail()`, normalizes shorthand where the concept allows it, and always
  returns the validated or normalized value. Callers capture it
  (`let fields = validate-fields(...)`) or discard it explicitly with
  `_ = ...`. Never `let _ =`. There are no `require-`, `reject-`,
  `normalize-`, or `parse-` families.
- `resolve-x` computes a final form from validated inputs. `render-x` produces
  content. `apply-x` wraps content in styling or reveal state and returns it;
  a theme's `apply` callback is the public face of the family
  (`apply-state`).
- `make-x` is for internal constructors only; public constructors are bare
  nouns (`cell`, `card`, `divider`, `columns`, `rows`, `track`) or short
  command words (`on`).
- `default-x` names a default value. Never `x-defaults`.

## Vocabulary

One word per concept, chosen to match native Typst wherever a native word
exists.

- Structure: `node` is any tree dict, `cell` is a leaf, `track` is the sizing
  wrapper, `grid` is the whole tree, `plane` is a full-slide layer
  (`background`, `foreground`), `slot` is a revealable unit in an incremental
  command. `region` is reserved for the native `layout()` callback.
- Bundles: `fields` are a layout's validated user arguments, `options` a bag
  of raw user-tunable arguments before resolution (`setup` arguments, a theme
  definition's `options` key), `settings` the deck-wide resolved record,
  `record` the write-once deck state, `definition` a passive theme dict,
  `tokens` any private constant bundle, color and geometry alike
  (`title-tokens`, `component-tokens`). There is no `spec`; a raw argument at
  a validator boundary is a `value`.
- Content: `body` is content the caller writes, `content` the cell field or
  native type, `value` an unvalidated argument at a validator boundary,
  `child`/`children` tree structure, `item` a list element. A map of bodies
  keyed by cell id is `cells`, never `content`: the public `slide(cells:)` and
  `setup(cells:)` arguments say what their keys are. The two planes are
  parameters of their own (`background:`, `foreground:`) and never entries in
  `cells`, because a plane is not a grid leaf.
- Identity: `id` is a user-chosen instance identifier (cells, planes), `key` a
  dictionary or state key, `name` the name of a kind of thing (layout, role,
  variant), `kind` the internal node discriminant, `variant` a preset look,
  `role` a semantic palette entry.
- The title slide's author, affiliation, and date block is `details`.
  `metadata` means the native Typst element and nothing else.
- Pictures are `image`, never `visual` or `picture`. Bags of `text()` arguments
  are `styles`, never `typography`.
- Space: `gutter` only when the value feeds a native grid gutter, `gap` for any
  other free-space measure, `spacing` only for native `par`/`block` spacing and
  the user-facing `settings.spacing` dict, `inset` for interior space,
  `margin` for page margins. Typst has no `padding`; neither does Mosaic.
- Color: `fill` is the parameter, `paint` the value type, `muted` de-emphasis,
  `scrim` a translucent layer over a picture, `tint` a lightening amount,
  `canvas` the page background token, `surface` the raised block token.
- A drawn typographic line is a `rule`. A stroke passed to a grid boundary is a
  `stroke`.

## Signatures

- Shape: one positional subject first, options as named parameters with
  defaults, trailing content through a `..sink` or a final content parameter
  filled by a trailing block. No function takes two ordinary positionals.
- The diagnostic context string is a positional parameter named `name`,
  immediately after the value under validation (or last, after an
  `allowed`/`expected` list). Tree walkers use `path:` because a tree path is
  different information. Named with a default only where callers genuinely rely
  on the default.
- Shared parameters keep one order across a family: subject first, `settings`
  last positional, the named tail in one stable order (`path:`, `overflow:`,
  `slide:`).
- Booleans are always named with defaults, never positional. `allow-` is the
  only permission prefix.
- Public parameters use native Typst spellings where a native concept exists:
  `fill`, `stroke`, `inset`, `radius`, `width`, `height`, `align`, `gutter`,
  `columns`, `fit`. Shadows of native functions must be signature supersets:
  same positional subject, same native parameter names, extras added as named
  parameters, the rest forwarded through a `..native` sink.
- Public exports must not shadow a native function with something that is not
  one. That is why the grid namespace is `grids` and the pill component is
  `badge`. The namespace is what lets `grids.columns` and `grids.rows` carry
  the native words without taking them at the top level.
