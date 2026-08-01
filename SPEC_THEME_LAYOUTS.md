# SPEC: Theme conventions, layout vocabulary, and bundled themes

**Status:** Parts 1a, 1b, and 1c implemented; Part 2 deferred pending evidence; Part 3 withdrawn
**Scope:** Vocabulary, theme-module convention, bundled themes, documentation, and a gated engine proposal for layout default styles
**Compatibility:** Mosaic is unreleased; no compatibility aliases were kept

## Summary

This spec records three decisions that have been implemented and one proposal
that remains deferred.

1. **Implemented (Part 1a): the "layout" vocabulary.** The public namespace
   `m.templates` is renamed `m.layouts`. "Template" collided with the Typst
   ecosystem meaning (a whole-document wrapper; Typst Universe has a literal
   Templates category) and was scope-free next to "theme" and "scheme." The
   stack is now: **theme** (colors, typography, layout factories) > **layouts**
   (named, styled per-slide-kind arrangements) > **grid** (structural cell
   tree), plus **palette** (raw tokens) and **colors** (semantic roles). Every
   term owns one scope. The rename is total: source modules (`layout-*.typ`),
   public API, diagnostics (`layout "title" ...`), tests, Makefile targets,
   docs pages and slugs (`layouts.html`), and tutorial assets.
2. **Implemented (Part 1b): the theme-module convention.** Themes are
   namespaced modules exporting `apply`, the layout factories `default`,
   `title`, and `section` at the module top level, a `layouts` dictionary
   grouping the same factories, `colors`, and `palette`. Factories accept and
   forward `cell-styles`. `m.slide()` remains the only logical-slide
   constructor; factories are thin closures over it.
3. **Implemented (Part 1c): bundled themes.** Metropolis, Cream, and
   Minimalist White ship inside the package as `m.themes.metropolis`,
   `m.themes.cream`, and `m.themes.minimalist`
   (`mosaic/src/themes/*.typ`), each with a small set of `apply.with(...)`
   knobs (`font`, `base-size`, and for Metropolis `font-mono`). Grayscale
   (the portfolio example) and the tutorial starter theme remain vendored
   single files, demonstrating the copy-me side of the convention.
4. **Deferred (Part 2):** a layout-default-styles layer below
   `m.slide(cell-styles:)`. Try `m.slide(styles:)` first; the heavier
   `m.layouts.define(...)` record is a fallback gated on the visual-planes
   decision.
5. **Withdrawn (Part 3):** `m.setup(rules:)`. The three-line `apply` wrapper
   is idiomatic Typst and is documented as the convention instead.

## Part 1: What was implemented

### The convention

A theme is an ordinary Typst module imported as a namespace:

```typst
#import "@local/mosaic:0.0.1" as m
#let theme = m.themes.metropolis   // bundled
// or: #import "theme.typ" as theme  // vendored copy

#show: theme.apply

#theme.title([My talk], subtitle: [A subtitle])

== Ordinary slide

Routed through the theme's `default` layout via auto-slide.

#theme.section([Methods])
```

Required exports: `apply`, `default`, `title`, `section`, `layouts`,
`colors`. Recommended: `palette`.

**A Typst constraint shaped one decision.** The earlier draft grouped
factories in a `theme.layouts` dictionary and had users call
`theme.layouts.title(...)`. Typst cannot call dictionary entries as functions
(`error: cannot directly call dictionary keys as functions`), so that call
would have required `#(theme.layouts.title)(...)` everywhere. Factories are
therefore exported at the module top level, where module-member calls work,
and the `layouts` dictionary remains as a secondary grouped export for
programmatic use (theme switching, contract tests). Grouping is provided by
the theme module namespace itself.

**Composability.** Portable factories accept and forward `cell-styles` so
deck authors can override theme defaults per slide:

```typst
#theme.section([Methods], cell-styles: (section: (fill: red)))
```

The forwarding merge (`theme-defaults + cell-styles`) is shallow: a user
`text:` dictionary replaces the theme's `text:` defaults rather than merging.
This is the documented limitation that Part 2 exists to close.

**Portable signatures.**

```typst
default(title, body, cell-styles: (:))      // themes may extend, e.g. number:
title(title, subtitle: none, authors: (), date: none, cell-styles: (:))
section(title, subtitle: none, cell-styles: (:))
```

The section title is the first positional argument, matching how every
existing theme was already written. Passing a positional parameter by name is
not allowed in Typst; shared demo content therefore uses an `arguments(...)`
value spread into the factory call.

### Bundled themes

The bundling decision and its rationale:

- Package files are immutable in the Typst cache, so bundled themes are only
  useful as-is or through knobs; each bundled `apply` exposes a deliberate,
  small knob set via `.with(...)`.
- Beyond the knobs, the customization story is copy-and-own: each bundled
  theme is a single readable file written to be copied out
  (`mosaic/src/themes/<name>.typ`), and its header says so.
- Bundled themes import package-internal modules directly (`../setup.typ`,
  `../deck-commands.typ`, ...) because importing `lib.typ` from inside the
  package would be circular.
- The example decks consume the bundled themes through thin `theme.typ`
  adapters that re-export the theme module and the palette tokens each deck's
  content references. Portfolio/Grayscale stays fully vendored as the
  counterexample.

### Vocabulary rename mechanics (for the record)

- `mosaic/src/template-*.typ` → `layout-*.typ`; identifiers, record kinds
  (`layout-grid`), and user-facing diagnostics renamed with them.
- `m.templates` → `m.layouts` in `lib.typ`; `m.themes` added.
- Tests `templates*.typ` → `layouts*.typ` (including `tests/invalid/`),
  `expected-diagnostics.txt` keys updated; Makefile target `template-tests` →
  `layout-tests`.
- Docs: `docs/templates.typ` → `docs/layouts.typ`,
  `docs/api/templates.typ` → `docs/api/layouts.typ`,
  `docs/tutorial-examples/templates/` → `.../layouts/`, sidebar targets,
  page titles, and in-prose vocabulary updated. Legitimate uses of the word
  ("presentation templates" in acknowledgments, CSS `grid-template-columns`)
  were kept.

## Design principles (unchanged)

1. **One slide constructor:** only `m.slide()` creates a logical slide command.
2. **Themes are modules, not framework objects.**
3. **Different semantics may require different arguments.**
4. **Uniform outputs matter more than uniform inputs:** every factory calls
   `m.slide()`.
5. **Public cells remain structural.**
6. **Definition defaults and instance overrides remain distinct.**
7. **Native Typst rules remain native:** typography lives in the `apply`
   wrapper as ordinary `set`/`show` rules.
8. **No catch-all variant argument soup.**
9. **Engine complexity must be paid for.**

## Part 2: Layout default styles (deferred, gated)

### The goal

A styles layer with this precedence, and deep `text` merging between layers:

```text
Mosaic internal defaults
→ theme/layout default styles
→ slide cell-styles overrides
```

Part 1's shallow `+` merge cannot deliver the third line's `text` merge.

### Precondition: the visual-planes decision

Metropolis already supplies the evidence: its ordinary slide needs
`foreground: footer(number: ...)`. A layout mechanism that excludes planes
cannot absorb that closure, so themes keep wrapper functions either way. The
two honest outcomes remain: exclude planes and justify the mechanism on
styles precedence alone (then it must be cheap), or include planes and accept
heavier layout values that weaken `m.slide()` as the sole command boundary.
Do not start Option B while this is open.

### Option A (try first): `m.slide(styles:)`

```typst
m.slide(
  ...,
  styles: (:),       // theme defaults, below cell-styles
  cell-styles: (:),  // per-instance overrides, unchanged
)
```

Same schema and validator as `cell-styles`; resolution applies `styles` then
`cell-styles` with deep `text` merging. Factories then pass their defaults as
`styles:` and forward user `cell-styles` untouched. No tagged records, no
forgery validation, no mutation boundaries; planes stay owned by the factory
closure, so the Metropolis question does not block it.

### Option B (fallback): `m.layouts.define(...)`

A tagged, inspectable layout record (grid + named default styles + section
metadata) accepted anywhere a built-in layout grid is accepted. Carries the
full validation matrix (forged/mutated records, base-grid-before-styles
ordering, dual-layer revalidation). Implement only with concrete evidence
that a first-class layout value is needed beyond what Option A plus module
closures provide. `name` optional; no `suppress-global-logo`.

### Acceptance criteria

1. `cell-styles` reliably override theme defaults with deep `text` merging.
2. `m.slide()` remains the sole logical-slide constructor.
3. Metropolis's ordinary slide keeps one coherent owner.
4. Validation surface proportionate to what it enables.
5. Factories get simpler, and consumer calls do not get longer.

## Part 3: Withdrawn: `m.setup(rules:)`

The wrapper convention is documented instead. Rationale: the wrapper is
idiomatic Typst and costs three lines; `rules:` added ordering semantics that
would need rendered-test proof; Typst cannot introspect function arity; a
function-valued styling parameter is a second configuration idiom next to the
native one.

## Rejected alternatives

- **Flat `slide-*` exports** (the pre-migration convention): conflated slide
  lifecycle with semantic layouts; unbounded flat interface. Replaced by
  namespaced factories.
- **`theme.layouts.title(...)` as the call form:** defeated by Typst's
  dictionary-call limitation; kept only as a programmatic grouping.
- **One variant-dispatch function** (`kind: "title"`): variant-dependent
  fields, misleading signatures, argument-soup validation.
- **Theme object or registry** (`m.theme(...)`): the module namespace already
  provides selection and grouping without framework state.
- **Restoring styles to public cells:** would undo the structural-cell
  architecture.
- **Identical arguments for all factories:** different semantics need
  different data; the portable core standardizes what is shared.
- **Leading with `m.layouts.define`:** its flagship case (Metropolis) needs
  planes the record excludes, and its validation cost is disproportionate to
  the styles-precedence benefit that `styles:` delivers more cheaply.
- **Bundling every theme:** Grayscale and the starter stay vendored so the
  copy-me story remains demonstrated and documented.

## Verification performed

- `make check` (core, layout, and negative suites) green after the rename.
- All three bundled themes compile standalone and render correctly
  (title/default/section smoke decks inspected visually).
- All four example decks rebuild through their own Makefiles; Metropolis
  inspected visually (title, content, section slides).
- All five one-deck-many-themes demo wrappers compile.

## Open questions

1. **Planes:** may reusable layout values carry `background`/`foreground`?
   Decision required before Part 2; Metropolis is the decision case.
2. **Shallow-merge gap:** is the Part 1 limitation (user `text:` overrides
   replace theme `text:` defaults) painful enough in practice to schedule
   Part 2 Option A?
3. **Knob surfaces:** bundled `apply` knobs are minimal (`font`,
   `base-size`, `font-mono`). Should accent colors become knobs? That
   requires threading them through layout factories, which currently read
   the static palette.
4. **Option B trigger:** what concrete evidence (theme exchange,
   introspection, tooling) would justify a first-class layout record?
5. **Contract test:** should a test compile identical source against every
   theme (bundled and vendored) to enforce the portable signatures?
