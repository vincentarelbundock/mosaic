# SPEC: accessible PDF export

Status: proposed. Written 2026-09-01 against Mosaic 0.0.2 and Typst 0.15.0, prompted by issue #7 ("[Wishlist] More PDF/UA compliance").

## Scope

What Mosaic must do so that a deck compiled with `typst compile --pdf-standard ua-1` is accessible in practice, not merely green in a validator. Everything here concerns PDF export. HTML export, PDF/UA-2, and WCAG criteria that only a human can judge are out of scope.

## Division of responsibility

Three parties produce an accessible deck, and confusing them is what made issue #7 look like a package bug.

- **The exporter.** Typst 0.15 writes Tagged PDF by default, so a plain `typst compile` already emits `/MarkInfo<</Marked true>>`, a StructTreeRoot, `/Lang`, and an outline. Two PDF/UA markers appear only under `--pdf-standard ua-1`: the XMP `pdfuaid:part 1` identifier, and `/ViewerPreferences<</DisplayDocTitle true>>`. Neither is reachable from Typst markup, so no package change substitutes for the flag. A file exported without it fails PDF/UA identification however well the deck is written; this is the whole of what issue #7 reported.
- **The deck author.** Alt text on images and equations, a language when the deck is not English, and not encoding meaning in color alone. Mosaic can document these but cannot supply them.
- **The package.** Everything structural: that the deck's headings form a properly nested tree opening at level one, and that theme chrome is marked as decoration rather than announced as content. This spec is about that third part.

## Current state, measured

Method: each theme compiled with `--pdf-standard ua-1` (Typst 0.15.0), the structure tree walked from `/StructTreeRoot`, and the per-page marked-content operators counted in the content streams. The chrome measurement uses a deck whose only slide content is `== Header`, so every tagged span beyond the first is theme furniture.

| theme | ua-1 export | tagged spans on a bare content slide | artifacts | chrome in the tag tree |
| --- | --- | --- | --- | --- |
| default | clean | 1 | 3 | none |
| manifesto | clean | 1 | 3 | none |
| metropolis | clean | 1 | 5 | none (its progress bar is a `line`, which Typst artifacts automatically) |
| editorial | clean | 2 | 3 | the folio (slide number) |
| mono | clean | 3 | 2 | the statusline (slide number) and the `$` heading prompt |

Two structural defects follow.

**D1. The title slide contributes no heading.** `title-display` (`mosaic/src/layout/title.typ:374`) wraps the deck title in a `block` carrying the `<mosaic-title-display>` label. A block is not a heading, so page one tags as `Div > Div > Span` and the first heading in a deck of `==` slides is an H2. PDF/UA-1 wants the tree to open at H1, which is why the reporter in issue #7 had to plant a filler `= First Section (to appease UA)` before their first content slide.

**D2. Decorative text chrome is announced as content.** Mosaic draws the background and foreground planes as `place`d blocks inside the page body (`full-slide-layer`, `mosaic/src/slide/runtime.typ:68`) rather than through Typst's native `page(background:)` / `page(foreground:)`, so Typst's automatic artifacting of page furniture never applies to them. Editorial's folio (`mosaic/src/themes/editorial/definition.typ:74`) and mono's statusline (`mosaic/src/themes/mono/definition.typ:69`) are therefore live text: a screen reader reads the slide number aloud on every slide. Mono compounds this with the shell prompt at `mosaic/src/themes/mono/definition.typ:35`, which prefixes every level-two heading with a `$` in its own grid cell, so each slide title announces as "dollar sign, Roadmap".

Already covered, and not to be re-litigated here: contrast, which `tests/test_palettes.py` enforces on every bundled palette including inverted ones; reading order, which follows the grid's depth-first cell order and matches the visual order; and the components (card, callout, badge), which export cleanly under ua-1.

## Requirements

**R1. The deck title is a level-one heading.** `title-display` emits `heading(level: 1, outlined: false, ..)` around the display line. Every title variant reaches this one function through `heading-stack`, so the change is made once.

- `outlined: false` is required, not incidental: it keeps the title out of the PDF outline and out of any `#outline()`, so no existing deck's bookmarks change. Verified that a heading with `outlined: false` still tags `/H1` and adds no bookmark.
- The heading is suppressed when the title field is empty. An empty `/H1` is worse than none.
- The visual result must be unchanged. Two collisions were checked and are benign. Every theme's transformative heading rule is scoped to level two (mono's prompt, editorial's ruled header, manifesto's uppercase), so a level-one cover heading escapes all of them; and every theme defines its `show label("mosaic-title-display")` size rule after its level-one heading rule, so the display size still wins. The one live effect is `show heading: set block(below: ..)`, which all five themes set and which would widen the title-to-subtitle gap; `title-display` must neutralize it with a `show heading: set block(above: 0pt, below: 0pt)` stated inside the cell, where it sits nearest the element.

Acceptance: a deck of only `==` slides, with no filler section, exports under ua-1 with an `/H1` on page one and no skipped heading level.

**R2. Theme chrome is an artifact.** Each theme's default `background` and `foreground` in its `defaults:` block wraps its content in `pdf.artifact`. This is a per-theme one-liner, not an engine change: a plane the *deck* passes may legitimately be content (a cover photograph with alt text, a "continued" label), so the engine must not artifact planes wholesale.

Acceptance: on a content slide whose only content is one heading, every theme tags exactly one span.

**R3. Mono's prompt is an artifact.** The `$` in `mosaic/src/themes/mono/definition.typ:35` is decoration and must not join the heading's text. Wrap it in `pdf.artifact`, keeping it in the same grid cell so the layout is unchanged.

Acceptance: mono's heading announces as its own text alone.

**R4. The documentation states the split.** The FAQ's accessibility answer already names `--pdf-standard ua-1`, the three authoring requirements, and (as of this work) links PDF4WCAG with a note that two of its checks answer for the export flag rather than for the deck. Remaining: `docs-src/examples/decks/common.mk` should carry the flag as a commented alternative, since the example decks are what readers copy, and the FAQ should drop the sentence requiring a leading `=` section once R1 lands.

**R5. The suite covers the tag tree.** See below.

## Test plan

A new positive test `tests/accessibility.typ` in the `core` manifest group, exercising a title slide, a `==` content slide, and one component, plus assertions in `scripts/run-tests.py`. The suite's existing tools (pdftotext, pdfdetach) cannot see tags, but no new prerequisite is needed:

- Structure elements are written as plain objects, so `/S/H1` and `/S/H2` can be counted in the PDF bytes directly, in the style of the suite's existing output greps.
- Marked-content operators live in Flate content streams, which stdlib `zlib` inflates; counting `/Artifact` BDC/BMC against `/Span` BDC in the inflated streams is what proves R2 and R3.

Assertions: the ua-1 export succeeds for every theme; page one carries an `/H1`; a bare content slide carries exactly one tagged span per theme; and, as a guard on the exporter contract rather than on Mosaic, a ua-1 export contains `pdfuaid:part` and `DisplayDocTitle true` while a default export contains neither.

## Open questions

- **Planes versus native page furniture.** Routing planes through `page(foreground:)` would make Typst artifact them automatically and would fix D2 for user planes too, but it changes how planes compose with the slide frame and with incremental steps. R2 deliberately takes the narrow fix; the broader one deserves its own investigation.
- **Uppercase headings.** Manifesto uppercases level-two headings (`mosaic/src/themes/manifesto/definition.typ:34`), which puts all-caps text in the tag tree. Some screen readers spell such words letter by letter. Judging this needs a real assistive technology, not a validator, so it is recorded rather than specified.
- **Should the title be bookmarked?** R1 says no, to keep existing outlines stable. If decks later want the cover in the outline, that is a field on the title layout rather than a default.

## Verification log

All measurements in this document were taken on 2026-09-01 with Typst 0.15.0 against the working tree installed as `@local/mosaic:0.0.2`, using `ua-mwe.typ` at the repository root (the MCVE from issue #7, with a hand-built title slide) and one throwaway deck per theme. Specifically: a default export carries neither `pdfuaid:part` nor `/DisplayDocTitle`, and its catalog reads `/ViewerPreferences<</Direction/L2R>>`; the same source under `--pdf-standard ua-1` carries both; the built-in title layout tags page one as `Div > Div > Span`, and a one-cell grid holding a real `=` heading tags it as `Div > Div > H1`; and wrapping mono's default foreground in `pdf.artifact` moves one span out of the tag tree.
