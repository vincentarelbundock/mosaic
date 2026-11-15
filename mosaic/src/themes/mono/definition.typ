// Passive Mono design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, and the canonical <mosaic-cell-*>
// vocabulary. Mono is the terminal voice of the bundled set: monospace type
// throughout, panel-backed code blocks, a shell prompt on every heading, and toc
// sections that list the whole deck like a process table. It is dark by
// default, so the polarity branch picks the dark code theme with no palette
// override at all.
#import "../../component/api.typ" as components
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens
#import "../polarity.typ": is-dark-canvas, dark-code-theme
#import "../../incremental/heading.typ": decorate-heading
#import "../../component/style.typ": deck-colors

#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  // Tight lists become wide, keeping every argument the list was written with
  // (`start`, `numbering`, `marker`, ..): only `tight` changes.
  let widen(it) = {
    let fields = it.fields()
    let children = fields.remove("children")
    _ = fields.remove("tight", default: none)
    (it.func())(..fields, tight: false, ..children)
  }
  show list.where(tight: true): widen
  show enum.where(tight: true): widen
  // A list nested in an item of a wide list is a block, which would take the
  // paragraph spacing above it, a gap wider than the item rhythm. Every list
  // therefore pins the lists nested in it to its own item spacing, read from
  // the live `set list(spacing: ..)` or `set enum(spacing: ..)` so a deck
  // that changes the rhythm keeps it even. The rule is stated inside the
  // list, so the space above a top-level list is left alone. It is a
  // show-set rule scoped to the list, which is the limit: a deck-level
  // `show list: set block(above: ..)` does not reach nested lists.
  let pin-nested(it) = context {
    let gap = if it.func() == enum { enum.spacing } else { list.spacing }
    if type(gap) != length { return it }
    show selector(list).or(enum): set block(above: gap)
    it
  }
  show selector(list).or(enum): pin-nested
  set list(spacing: 0.9em, marker: text(fill: colors.accent)[--])
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  set table(stroke: 0.8pt + colors.line)
  set raw(theme: dark-code-theme) if is-dark-canvas(colors)
  show heading.where(depth: 1): set text(size: base-size * 1.7, weight: "bold")
  show heading.where(depth: 2): set text(size: base-size * 1.25, weight: "bold")
  show heading: set block(below: 1em)
  // The slide-header prompt: a shell marker in the accent color before every
  // level-two heading, which is what opens a content slide.
  // Declared through `decorate-heading` so the prompt is redrawn on every
  // frame of an incremental slide, where only one frame holds the heading.
  show: decorate-heading.with(depth: 2, it => grid(
    columns: (auto, 1fr),
    column-gutter: 0.5em,
    align: (left + top, left + top),
    // Decoration, not part of the heading's text: the artifact wrapper keeps
    // it out of the tagged PDF's structure tree.
    pdf.artifact(text(fill: colors.accent)[\$]),
    it,
  ))
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show link: set text(fill: colors.accent)
  show raw.where(block: false): set text(fill: colors.accent)
  show raw.where(block: true): set text(size: 0.78em)
  // The panel reads the palette of the slide it is drawn on rather than the
  // deck's: on an inverted slide the ink is knocked out, and a panel still
  // painted in the deck surface would set dark code on a dark ground.
  show raw.where(block: true): it => context {
    let live = deck-colors()
    block(
      width: 100%, fill: live.surface, stroke: 0.8pt + live.line,
      radius: 4pt, inset: (x: 14pt, y: 11pt), it,
    )
  }
  show label("mosaic-cell-header"): set text(weight: "bold")
  show label("mosaic-title-display"): set text(size: 1.5em, weight: "bold")
  show label("mosaic-cell-title"): set par(leading: 0.5em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: 2em)
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.62em, fill: colors.muted)
  body
}

#let definition = (
  name: "Mono",
  colors: tokens.colors,
  defaults: (
    // The statusline: a right-aligned slide counter at the bottom of every
    // numbered slide. It resolves its colors from the deck record, so a
    // palette swap recolors it too, and the component quiets itself on
    // unnumbered pages such as titles.
    // Chrome, not content: the artifact wrapper keeps it out of the tagged
    // PDF's structure tree, so a screen reader never announces it.
    foreground: pdf.artifact(place(bottom + right, block(
      inset: (right: 24pt, bottom: 12pt),
      text(
        size: 0.55em,
        components.progress(variant: "1/1"),
      ),
    ))),
  ),
  options: (
    // The one chain that needs no platform names: Typst embeds DejaVu Sans
    // Mono, so the designed face always resolves and no build ever warns.
    // A deck that has a favorite mono passes it through `setup(font: ..)`.
    font: ("DejaVu Sans Mono", "Liberation Mono"),
    base-size: 19pt,
  ),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
