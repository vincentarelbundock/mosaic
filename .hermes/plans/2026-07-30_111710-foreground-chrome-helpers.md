# Foreground Chrome Helpers Implementation Plan

> **For Hermes:** Implement this plan task-by-task with TDD. Do not commit unless Vincent explicitly authorizes it.

**Goal:** Add two paper-independent foreground helpers—`mosaic.components.edges` and `mosaic.components.border`—that replace repeated hand-positioned slide chrome in the reconstructed decks.

**Architecture:** Both helpers return ordinary Typst content for composition through `mosaic.deck(foreground:)` or `mosaic.slide(foreground:)`. They operate inside Mosaic's existing full-slide `100% × 100%` foreground layer and therefore never inspect or hardcode paper dimensions. Keep them as narrow native-content helpers in `components.typ`; do not introduce a chrome template, settings state, automatic collision avoidance, or a second layout DSL.

**Tech Stack:** Typst 0.15.1, Mosaic component namespace, existing Typst compile tests, Calepin documentation generation.

---

## Findings that determine priority

1. `SPEC_HELPERS.md` is partially stale:
   - candidate 6 is already implemented as `m.grid.h/v(rule:)`, validated, tested, and used by `ppt/minimalist-white-mosaic/main.typ`;
   - candidate 9 already exists as `m.components.progress(variant: "line")`; only the Metropolis reconstruction still needs migration.
2. `templates.section(align:)` is a genuine missing field, but it is not yet sufficient to replace the hand-built section slides:
   - section alignment is hardcoded to `center + horizon`;
   - the section `role` changes the resolver's accent color but does not make a plain section accent-filled;
   - Metropolis also needs deliberate progress placement.
   These semantics should be decided together in a later section-template slice rather than adding `align:` alone.
3. Edge chrome is repeated across three reconstructions:
   - `minimalist-white-mosaic`: three running header slots;
   - `cream-green-black-mosaic`: three running header slots and cover metadata;
   - `photojournalist-mosaic`: four cover corners.
4. The cream deck's border currently hardcodes `814pt × 446pt`, making it the clearest paper-size bug in the candidate list.
5. `gallery` would currently be a thin wrapper around native `grid` and `m.image`; `card` is too design-specific; role-based text wrappers risk competing with native Typst styling; keyed slide bodies remain a larger API change. Defer these until the smaller helpers have been used in more decks.

## Proposed public API

```typst
#m.components.edges(
  top-left: [Clean],
  top: [Introduction],
  top-right: [Minimal],
  bottom-right: [September 2035],
  inset: (x: 28pt, y: 18pt),
  text-style: (size: 6pt, fill: white),
)
```

- Supported slots: `top-left`, `top`, `top-right`, `bottom-left`, `bottom`, `bottom-right`.
- `top` and `bottom` mean centered along that edge, matching native Typst alignment vocabulary.
- Slot values are `content | none`.
- `inset` accepts a native length or a dictionary using `x`, `y`, `top`, `right`, `bottom`, and `left`.
- Side-specific values override `x`/`y`; `x`/`y` override the uniform fallback.
- `text-style` is a native text dictionary and defaults to `(:)`, inheriting surrounding text styling.
- Output is ordinary foreground content; no hidden setup lookup or automatic thresholds.

```typst
#m.components.border(
  inset: 14pt,
  stroke: 0.8pt + white,
  radius: 0pt,
)
```

- The border is sized from the foreground layer using `100%` dimensions.
- `inset` uses the same normalization rules as `edges`.
- `stroke` and `radius` remain native Typst values.
- The helper draws no fill and consumes no slide body.

Composition stays explicit:

```typst
#let chrome = [
  #m.components.border(inset: 14pt, stroke: 0.8pt + white)
  #m.components.edges(
    top-left: [Clean],
    top: [Introduction],
    top-right: [Minimal],
    inset: (x: 38pt, y: 12pt),
    text-style: (size: 6pt, fill: white),
  )
]

#let slide = m.slide.with(foreground: chrome)
```

---

### Task 1: Reconcile the helper specification

**Objective:** Make `SPEC_HELPERS.md` distinguish implemented APIs, migrations, accepted next work, and deferred ideas.

**Files:**
- Modify: `SPEC_HELPERS.md`

**Steps:**
1. Mark candidate 6 as implemented: `m.grid.h/v(rule:)`.
2. Mark candidate 9 as an existing-component migration: use `m.components.progress(variant: "line")` in Metropolis.
3. Mark `edges` and `border` as the selected next increment.
4. Expand candidate 3's note: `align:` must be designed with section fill/role semantics, not landed in isolation.
5. Split candidate 4 into independent `item` and `card` decisions.
6. Mark gallery, role-text wrappers, and keyed bodies as deferred pending more evidence.

**Verification:**
- Read the revised document and confirm no entry still says rules or line progress are unimplemented.

### Task 2: Add red tests for `components.edges`

**Objective:** Define slot placement, inset normalization, text styling, and composition before implementation.

**Files:**
- Modify: `tests/components.typ`
- Create: `tests/invalid/components-edges-inset.typ`
- Create: `tests/invalid/components-edges-text-style.typ`
- Modify: `tests/invalid/expected-diagnostics.txt`

**Steps:**
1. Add a compile deck containing all six slots.
2. Add one page using uniform `inset: 8pt`.
3. Add one page using `(x:, y:)` and per-side overrides.
4. Compose `edges` with an existing foreground component to prove ordinary-content behavior.
5. Add invalid fixtures for a non-length/non-dictionary inset and non-dictionary `text-style`.
6. Run the focused positive and negative tests and confirm they fail because `components.edges` is absent.

**Commands:**
```sh
make install
/home/vincent/.local/bin/typst compile --root . tests/components.typ /tmp/mosaic-components-red.pdf
make negative-tests TYPST=/home/vincent/.local/bin/typst
```

**Expected:** Focused tests fail for the missing public helper, not for unrelated syntax.

### Task 3: Implement `components.edges`

**Objective:** Add the smallest deterministic edge-slot compositor.

**Files:**
- Modify: `mosaic/src/components.typ`
- Modify: `mosaic/src/component-api.typ`

**Steps:**
1. Add one private inset normalizer in `components.typ`.
2. Validate only the documented inset keys and native length values.
3. Validate `text-style` as a dictionary with the existing shared dictionary validator.
4. Map slots to native alignments and signed offsets:
   - left → positive `dx`;
   - right → negative `dx`;
   - top → positive `dy`;
   - bottom → negative `dy`.
5. Skip `none` slots rather than emitting empty placements.
6. Render supplied slot content through `text(..text-style, body)` so native content and inherited styling remain available.
7. Export `edges` from `component-api.typ`.
8. Run the focused tests and make them green without adding settings access or paper-size logic.

### Task 4: Add red tests for `components.border`

**Objective:** Prove that a border uses relative slide geometry and remains stable across paper ratios.

**Files:**
- Modify: `tests/components.typ`
- Create: `tests/invalid/components-border-inset.typ`
- Modify: `tests/invalid/expected-diagnostics.txt`

**Steps:**
1. Add one 16:9 page and one 4:3 page using the same border call.
2. Add a composition case combining `border` and `edges` in one foreground value.
3. Add an invalid inset fixture.
4. Confirm the focused tests fail because `components.border` is absent.

### Task 5: Implement `components.border`

**Objective:** Replace hardcoded page rectangles with a full-slide relative overlay.

**Files:**
- Modify: `mosaic/src/components.typ`
- Modify: `mosaic/src/component-api.typ`

**Steps:**
1. Reuse the private inset normalizer from `edges`.
2. Build a `100% × 100%` transparent block with the requested inset.
3. Draw a `100% × 100%` unfilled rectangle inside it using native `stroke` and `radius`.
4. Export `border`.
5. Run the focused tests and render both aspect ratios for visual inspection.

### Task 6: Add documentation and a visual gallery

**Objective:** Document foreground composition and provide rendered examples instead of API prose alone.

**Files:**
- Modify: `docs/component-library.typ`
- Modify or create: `docs/tutorial-examples/libraries/components/chrome.typ`
- Generated: corresponding SVG/PDF tutorial assets
- Generated: component API sources and HTML

**Steps:**
1. Document that helpers return foreground content and do not merge foreground values automatically.
2. Show deck-wide `edges`, per-slide overrides, `border`, and explicit composition.
3. Note that Mosaic presentation furniture renders after custom foreground and may occupy the same corners; callers should choose non-conflicting slots or disable the relevant furniture.
4. Render 16:9 and 4:3 examples and inspect all offsets and border insets.
5. Regenerate API sources and documentation pages using the established safe Calepin cache sequence.

### Task 7: Migrate reconstructed decks as acceptance tests

**Objective:** Demonstrate that the helpers remove real duplication without reducing fidelity.

**Files:**
- Modify: `ppt/minimalist-white-mosaic/main.typ`
- Modify: `ppt/cream-green-black-mosaic/main.typ`
- Modify: `ppt/photojournalist-mosaic/main.typ`

**Steps:**
1. Replace `minimalist-white`'s `chrome-with` placement boilerplate with `components.edges`; preserve its center-fill exception locally because that knockout treatment is deck-specific.
2. Replace the cream deck's `nav` helper with `components.edges`.
3. Replace the cream deck's hardcoded `frame` rectangle with `components.border`.
4. Replace the photojournalist cover's four corner placements with `components.edges`.
5. Compile all four reconstructed decks.
6. Render before/after contact sheets and compare placement, clipping, and paper-ratio behavior.
7. Run `jscpd` on `ppt/` and record whether placement duplication decreases.

**Commands:**
```sh
make install
for src in ppt/*/main.typ; do
  /home/vincent/.local/bin/typst compile --root . "$src" "/tmp/$(basename "$(dirname "$src")").pdf"
done
jscpd ppt --format typst --formats-exts typst:typ --reporters console
```

### Task 8: Final verification

**Objective:** Verify public behavior, generated artifacts, and repository hygiene.

**Steps:**
1. Run focused component and negative tests.
2. Run the complete suite:
   ```sh
   make check TYPST=/home/vincent/.local/bin/typst
   ```
3. Verify generated API freshness:
   ```sh
   make -q api-sources
   ```
4. Check text diffs:
   ```sh
   git diff --check -- '*.typ' '*.md' '*.html' '*.json' 'Makefile'
   ```
5. Run duplication checks on `mosaic/src`, `tests`, and `ppt`.
6. Verify Git object integrity:
   ```sh
   git fsck --full --no-dangling
   ```
7. Confirm no temporary Calepin wrapper/cache remains and `docs/_calepin/active.typ` points to the normal page runtime config.
8. Do not commit unless explicitly authorized.

---

## Follow-on proposal after chrome

Design the section template as one coherent slice rather than adding `align:` alone:

1. add explicit native `align:`;
2. decide whether an accent-filled section is an explicit `variant: "accent"` or a documented consequence of `role:`;
3. preserve deterministic image variants;
4. demonstrate Metropolis section progress with the existing `components.progress(variant: "line")` instead of creating another progress implementation.

The preferred direction is an explicit `accent` variant because fill inversion is a visible treatment, while `role` should select color rather than silently change structure or contrast behavior.

## Risks and tradeoffs

- **Furniture collisions:** built-in logo, section label, footer, and numbering are rendered after custom foreground. Do not add collision detection; document explicit composition.
- **Over-generalization:** six edge slots cover observed cases. Do not add arbitrary anchor arrays, rotation, responsive switching, or layout callbacks yet.
- **Theme coupling:** default `text-style: (:)` inherits native text. Avoid hidden settings lookup in a content helper.
- **Foreground replacement:** a slide-level foreground replaces an inherited deck foreground. The helper should not change that established behavior; callers compose values explicitly.
- **Generated files:** the working tree already contains extensive generated and unrelated changes. Restrict edits to listed files and preserve current work.
