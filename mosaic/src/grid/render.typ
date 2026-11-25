// Rendering of validated grid trees for one incremental step.
#import "../shared.typ": array-max, fail, tag
#import "../incremental/core.typ": apply-state, range-last, status
#import "content.typ": body-cell-ids
#import "traversal.typ": resolved-tracks, fold-grid
#import "../incremental/analysis.typ": max-step
#import "../incremental/heading.typ": has-heading
#import "../incremental/transform.typ": transform
// Aliased: `fit` is the local variable name for a cell's fit mode throughout
// this module, and the helper must not shadow it.
#import "../fit.typ": fit as fit-helper
#import "../settings.typ": compact-cell-inset, default-spacing, resolve-spacing
#import "../deck-state.typ": deck-settings, inverted-slide-colors

// Records one queryable warning per overflowing cell.
//
// This runs inside `layout`, before introspection has converged: the logical
// slide counter still reads its pre-layout value here, and the recorded number
// only becomes correct once Typst re-runs the pass. So this function never
// fails the compile even in "error" mode, because the message it could build
// would name the wrong slide. `overflow-report` raises the failure afterwards,
// from a context where the numbers are final.
// The measurement rides a zero-footprint `place` so observation never
// participates in layout. Wrapping the body in the `layout` element instead
// would collapse the region to the content's natural height, which pins
// horizon- and bottom-aligned cell content to the top of the cell.
#let observe-overflow(body, cell, slide, step) = {
  place(top, layout(region => {
    let natural = measure(body, width: region.width)
    if natural.height > region.height {
      [#metadata((
        mosaic: tag,
        kind: "overflow-warning",
        logical-slide: slide,
        frame: step,
        cell: cell,
        available-height: region.height,
        measured-height: natural.height,
        message: "mosaic: content overflows cell " + repr(cell),
      ))<mosaic-overflow-warning>]
    }
  }))
  body
}

// Fails the compile when any cell overflowed, naming every offender. Placed at
// the end of the document by `setup`, so `query` sees converged introspection
// and reports the slide numbers an author can actually navigate to.
#let overflow-report() = context {
  let records = query(<mosaic-overflow-warning>).map(it => it.value)
  if records.len() == 0 {
    return
  }
  let describe(record) = (
    "cell " + repr(record.cell) + " on slide " + str(record.logical-slide)
      + " frame " + str(record.frame) + " by "
      + repr(record.measured-height - record.available-height)
  )
  fail(
    "content overflows "
      + records.map(describe).join("; ")
      + " (set overflow: \"record\" to report these without failing)",
  )
}

#let fixed-content-has-heading(node) = fold-grid(
  node,
  cell => cell.content != none and has-heading(cell.content),
  (node, child) => child,
  (node, children) => children.any(value => value),
)

// A heading inside an incremental grid node would be added and removed with the
// node, so its outline entry would come and go between frames. Structural, and
// therefore asked once per slide rather than once per rendered frame.
#let validate-stable-grid-headings(node, contents) = {
  let offending = fold-grid(
    node,
    cell => false,
    (node, child) => (
      child
        or body-cell-ids(node.child).map(id => contents.at(id, default: none)).any(has-heading)
        or fixed-content-has-heading(node.child)
    ),
    (node, children) => children.any(value => value),
  )
  if offending {
    fail(
      "headings cannot be placed in incremental grid nodes; "
        + "keep semantic headings structurally stable across frames",
    )
  }
  node
}

// Whether a cell paints anything of its own beyond its content, which is what
// decides if adding or removing it can change a frame visually.
#let cell-paints(cell) = (
  cell.style.at("fill", default: none) != none
    or cell.style.at("stroke", default: none) != none
    or cell.style.at("background", default: none) != none
    or cell.style.at("before", default: []) != []
    or cell.style.at("after", default: []) != []
)

#let max-node(node) = fold-grid(
  node,
  cell => {
    if cell.content == none {
      1
    } else {
      let span = max-step(cell.content)
      // A cell whose fixed content is visually empty and whose style paints
      // nothing contributes no step of its own: wrapping such a spacer in
      // `on(..)` must not mint frames on which nothing changes.
      if span > 0 or cell-paints(cell) {
        calc.max(1, span)
      } else {
        0
      }
    }
  },
  (node, child) => if child == 0 {
    0
  } else {
    calc.max(range-last(node.range), child)
  },
  (node, children) => array-max(children),
)

// Resolve em components of an inset against a captured base text size, so
// label-targeted typography rules cannot scale cell geometry.
#let resolve-inset-part(value, base) = if type(value) == length {
  value.abs + value.em * base
} else if type(value) == relative {
  value.ratio + resolve-inset-part(value.length, base)
} else {
  value
}

// The slide a render starts from when no deck supplies one: slide zero,
// nothing numbered yet. Named once so the entry points cannot drift from
// each other.
#let initial-slide = 0

// A cell that states no inset of its own takes the deck's configured spacing.
// Read inside the render context, where the deck record is live; a component
// rendered outside `setup` falls back to the library default. A compact cell
// (one in an `auto` row track, at any depth below it, or one a layout marks
// content-sized) takes the compact inset, exactly as the built-in headers and
// footers do, so a hand-built grid cannot drift from them.
#let configured-inset(content-sized: false) = {
  let settings = deck-settings()
  let spacing = if settings == none {
    resolve-spacing(default-spacing)
  } else {
    settings.spacing
  }
  if content-sized { compact-cell-inset(spacing) } else { spacing.inset }
}

#let resolve-inset(inset, base) = if type(inset) == dictionary {
  let resolved = (:)
  for (side, value) in inset {
    resolved.insert(side, resolve-inset-part(value, base))
  }
  resolved
} else {
  resolve-inset-part(inset, base)
}

// `id` is the cell's id, which is `none` only alongside a `none` style: a
// split has neither. `states` are the reveal states of the `on` wrappers
// around the cell on this step, outermost first; they apply to the whole
// cell here rather than to its body, so a hidden cell hides its surface,
// its affixes, and whatever a label rule paints on it, exactly as a hidden
// split hides everything inside it.
#let render-cell(
  content,
  style,
  step,
  id: none,
  states: (),
  overflow: "off",
  slide: initial-slide,
  track: none,
  vertical: false,
  shrink: (width: false, height: false),
  compact: false,
  flow: false,
) = {
  // A styleless cell is a container the tree produced, not one an author named.
  // Its content is measured again by every cell inside it, so observing it too
  // re-measures each subtree once per level of nesting, and the path it would
  // report ("grid.0") names nothing an author can act on. The offending cell
  // reports itself.
  if style == none {
    return content
  }
  let before = style.at("before", default: [])
  let after = style.at("after", default: [])
  let inset = style.inset
  let fill = style.at("fill", default: none)
  let stroke = style.at("stroke", default: none)
  let radius = style.at("radius", default: 0pt)
  let background = style.at("background", default: none)
  let content-sized = style.at("content-sized", default: false)
  let fit = style.at("fit", default: none)
  let map = style.at("map", default: none)
  let anchor = style.at("align", default: none)
  // A cell in an `auto` row track sizes to its content, so its sibling `1fr`
  // tracks receive the remaining height and can align content on the horizon.
  // (`auto` on the horizontal axis is a column width and must not collapse the
  // cell height, so only the vertical axis opts in here.)
  let auto-height = vertical and track == auto
  let region-height = if content-sized or auto-height or shrink.height {
    auto
  } else {
    100%
  }
  // The horizontal counterpart: a cell in an `auto` column, or one measured
  // inside such a column (see `render-node`), takes its content's width. At
  // `100%` it would claim the whole region and starve its sibling columns.
  let region-width = if (not vertical and track == auto) or shrink.width {
    auto
  } else {
    100%
  }
  // `map` is the layout's transform of the slide body alone: variants that
  // recompose user-supplied content (small caps, recoloring, a title/number
  // grid) apply it here, before the affixes join, so `before` and `after`
  // keep their own typography.
  let content = if map == none { content } else { map(content) }
  let content = before + content + after
  // Dimming is a text fill, so it goes on the joined content, inside the
  // cell: there it reaches the affixes and outranks both the theme's label
  // rules and the inverted-slide ink restated below. Hiding is applied to
  // the finished cell at the end.
  let content = if "dimmed" in states {
    apply-state("dimmed", content)
  } else {
    content
  }
  // Cell fit modes are the public `fit` helper under two fixed settings, so a
  // layout that shrinks a cell and a deck that shrinks a block go through the
  // same code and cannot drift apart.
  let content = if fit == "width" {
    fit-helper(content, width: 1fr, grow: false)
  } else if fit == "contain" {
    fit-helper(content, grow: false, shrink: true)
  } else {
    content
  }
  // A variant-owned anchor, applied as an explicit element inside the labeled
  // block. Like the title layout's inline anchor, it is variant semantics
  // rather than a styling default: pick another variant to change it.
  let content = if anchor == none { content } else { align(anchor, content) }
  // A fitted cell is never observed. Its content is scaled into the allocation
  // by construction, so there is nothing to report, and observation measures in
  // a region where the fitters have no allocation to solve against (see
  // `is-unsolvable`) and therefore hand back the unfitted body, which would read
  // as an overflow that the rendered slide does not have.
  if overflow != "off" and fit == none {
    content = observe-overflow(content, id, slide, step)
  }
  // One block carries the whole cell, including its internal paint, and is
  // labeled <mosaic-cell-ID>. Native rules target it directly:
  //   show label("mosaic-cell-" + id): set text(...)
  //   show label("mosaic-cell-" + id): set align(horizon)
  //   show label("mosaic-cell-" + id): set block(fill: ...)
  // The inset lives inside the label so wrapping rules paint edge to edge,
  // but em insets are resolved against the text size just outside the label,
  // so cell typography rules do not scale cell geometry.
  grid.cell(inset: 0pt, context {
    let base = text.size
    // A flowing cell (see `render-breakable`) takes its content's height so
    // it can break, but it is still the slide's body: its `auto` inset is
    // the one the fixed frame gives it, so the fit check measures what the
    // fixed frame draws and the continuation pages keep the same padding.
    let sized = content-sized or ((auto-height or shrink.height) and not flow)
    let inset = if inset == auto {
      configured-inset(content-sized: sized or compact)
    } else {
      inset
    }
    // On an inverted slide the ink is restated here, inside the cell label:
    // theme rules pin text fills through <mosaic-cell-*> show-set rules, which
    // sit outside this block and would otherwise keep the un-inverted color.
    // Colors applied deeper as constructors — component roles, accents, the
    // layout's own resolved tiers — still win.
    let inverted = inverted-slide-colors.get()
    let content = if inverted == none {
      content
    } else {
      {
        set text(fill: inverted.text)
        content
      }
    }
    // Paint is passed only when the style declares it. An undeclared property
    // is left to native `set block` rules on the cell label, which follow
    // ordinary set precedence: a scoped rule overrides a deck-wide one instead
    // of stacking behind it the way a wrapping transform does. A declared
    // paint is the variant's design and stays constructor-strength.
    let body = block(
      width: region-width,
      height: region-height,
      ..if fill == none { (:) } else { (fill: fill) },
      ..if stroke == none { (:) } else { (stroke: stroke) },
      ..if radius == 0pt { (:) } else { (radius: radius) },
      clip: background != none,
    )[
      // A show-set on the cell label applies to everything inside the label,
      // not just the cell's own block; without a reset it would also paint
      // every block in the cell's content. Restating the defaults here
      // confines the rule to the surface it targets.
      #set block(fill: none, stroke: none, radius: 0pt)
      #if background != none {
        place(top + left, block(width: 100%, height: 100%, background))
      }
      #for (name, alignment) in (
        center: center + horizon,
        top: top + center,
        right: right + horizon,
        bottom: bottom + center,
        left: left + horizon,
        "top-left": top + left,
        "top-right": top + right,
        "bottom-left": bottom + left,
        "bottom-right": bottom + right,
      ) {
        place(alignment)[
          #metadata(none)#label("mosaic-cell-" + id + "-" + name)
        ]
      }
      #block(
        width: region-width,
        height: region-height,
        inset: resolve-inset(inset, base),
        content,
      )
    ]
    let cell = [#body#label("mosaic-cell-" + id)]
    // Hidden, the cell keeps its place in the grid, and in the measuring
    // pass of an `auto` track, and paints nothing.
    if "hidden" in states { apply-state("hidden", cell) } else { cell }
  })
}

// Whether a node is a split once any `on` wrappers are looked through.
#let is-split-node(node) = if node.kind == "on" {
  is-split-node(node.child)
} else {
  node.kind == "split"
}

// One child of a split, rendered into the cell its track holds: the grid
// cell content, or `none` when the child is removed on this step. Split out of
// `render-node` so the breakable slide path can lay a split's tracks out as
// separate rows of its own grid. Typst has no mutual recursion between
// top-level functions, so `render-node` is passed in by its caller. `compact`
// is `auto` to derive it from the track, as `render-node` does; the breakable
// path passes `false` for the body, whose track it turns into `auto` without
// meaning a content-sized cell.
#let render-child(
  render-node,
  child,
  track,
  contents,
  step,
  path: "grid",
  along: "height",
  overflow: "off",
  slide: initial-slide,
  shrink: (width: false, height: false),
  compact: false,
  child-compact: auto,
  dimmed: false,
  flow: false,
) = {
  let measuring = shrink.width or shrink.height
  let child-shrink = shrink
  if track == auto { child-shrink.insert(along, true) }
  let child-compact = if child-compact == auto {
    compact or (along == "height" and track == auto)
  } else {
    child-compact
  }
  let (child-content, removed, cell) = if (
    track == auto and not measuring and is-split-node(child)
  ) {
    let (full, removed, cell) = render-node(
      child,
      contents,
      step,
      path: path,
      overflow: overflow,
      slide: slide,
      compact: child-compact,
      dimmed: dimmed,
      flow: flow,
    )
    let sized = if removed { full } else {
      let probe = render-node(
        child,
        contents,
        step,
        path: path,
        slide: slide,
        shrink: child-shrink,
        compact: child-compact,
        dimmed: dimmed,
        flow: flow,
      ).at(0)
      layout(region => {
        let natural = measure(probe, width: region.width)
        block(width: natural.width, height: natural.height, full)
      })
    }
    (sized, removed, cell)
  } else {
    render-node(
      child,
      contents,
      step,
      path: path,
      overflow: if measuring { "off" } else { overflow },
      slide: slide,
      shrink: child-shrink,
      compact: child-compact,
      dimmed: dimmed,
      flow: flow,
    )
  }
  if removed {
    return none
  }
  render-cell(
    child-content,
    if cell == none { none } else { cell.style },
    step,
    ..if cell == none { (:) } else { (id: cell.id, states: cell.states) },
    overflow: if measuring { "off" } else { overflow },
    slide: slide,
    track: track,
    vertical: along != "width",
    shrink: child-shrink,
    compact: child-compact,
    flow: flow,
  )
}

// `contents` is the id -> content map. Each content-bearing cell looks up its
// own content by id, so there is no positional cursor to thread or keep aligned
// across branches and removed incremental nodes. Returns (content, removed,
// cell): `cell` is `none` for a split, whose content is already complete, and
// otherwise the `(id, style, states)` that `render-cell` wraps the content in.
//
// A split normally fills its region, which is what `1fr` tracks need. A split
// in an `auto` track has no region to fill: it must size to its content, and
// its cells must still paint edge to edge across the size it settles on, so
// that a header cell and a logo cell beside it share one height. It renders in
// two passes. The measuring pass renders the split with `shrink` set on the
// track's axis: every cell and split below takes its content's size on that
// axis, and fractional tracks along it, which have nothing to divide, act as
// `auto`. The measured size then becomes a fixed block, and the split renders
// again inside it the ordinary way, where `100%` and `1fr` resolve against that
// block. The measuring pass is never placed, so its labels, headings, and
// overflow records never reach the document.
//
// `compact` marks everything below an `auto` row, so cells there take the
// compact inset in both passes and the measured height is the rendered one.
//
// `dimmed` marks everything below an `on` node whose state on this step is
// "dimmed". Dimming is ink, which a component's own paint does not follow, so
// the flag reaches each cell's `transform`, which tells the components it
// redraws to mute themselves. Nested `on` nodes combine, a split hands the
// flag to every cell below it, and the measuring pass carries it too, so both
// passes of an `auto` track draw the same thing.
#let render-node(
  node,
  contents,
  step,
  path: "grid",
  overflow: "off",
  slide: initial-slide,
  shrink: (width: false, height: false),
  compact: false,
  dimmed: false,
  flow: false,
) = {
  if node.kind == "on" {
    let state = status(
      node.range,
      node.before,
      node.after,
      step,
    )
    if state == "removed" {
      return ([], true, none)
    }
    let (child-content, removed, cell) = render-node(
      node.child,
      contents,
      step,
      path: path + ".on",
      overflow: overflow,
      slide: slide,
      shrink: shrink,
      compact: compact,
      dimmed: dimmed or state == "dimmed",
      flow: flow,
    )
    // A split is finished content, so the state wraps it here. A cell is
    // not wrapped yet: the state travels with it to `render-cell`, which
    // applies it to the whole cell instead of to the body alone.
    if cell == none {
      return (apply-state(state, child-content), removed, none)
    }
    return (
      child-content,
      removed,
      cell + (states: (state,) + cell.states),
    )
  }
  if node.kind == "cell" {
    let body = if node.content == none { contents.at(node.id) } else { node.content }
    (
      transform(body, step, heading-scope: path, dimmed: dimmed),
      false,
      (id: node.id, style: node.style, states: ()),
    )
  } else {
    let rendered = ()
    let tracks = ()
    let along = if node.axis == "width" { "width" } else { "height" }
    let declared = resolved-tracks(node)
    let resolved = declared.map(size => if (
      shrink.at(along) and type(size) == fraction
    ) { auto } else { size })
    for (index, child) in node.children.enumerate() {
      let track = resolved.at(index)
      let content = render-child(
        render-node,
        child,
        track,
        contents,
        step,
        path: path + "." + str(index),
        along: along,
        overflow: overflow,
        slide: slide,
        shrink: shrink,
        compact: compact,
        // Inside a flowing body every fractional track turned `auto` only so
        // the body can break; a cell there keeps the inset its declared track
        // gives it in the fixed frame, so compactness reads the declared size.
        ..if flow {
          (child-compact: compact or (along == "height" and declared.at(index) == auto))
        },
        dimmed: dimmed,
        flow: flow,
      )
      if content != none {
        rendered.push(content)
        tracks.push(track)
      }
    }
    if rendered.len() == 0 {
      return ([], true, none)
    }
    // Interior boundaries between the tracks that survived this step; native
    // grid lines are drawn centered in the gutter.
    let stroke = node.at("stroke", default: none)
    let rules = if stroke == none {
      ()
    } else if node.axis == "width" {
      range(1, rendered.len()).map(x => grid.vline(x: x, stroke: stroke))
    } else {
      range(1, rendered.len()).map(y => grid.hline(y: y, stroke: stroke))
    }
    let cross = (if shrink.at(if along == "width" { "height" } else { "width" }) {
      auto
    } else {
      1fr
    },)
    let content = block(
      width: if shrink.width { auto } else { 100% },
      height: if shrink.height { auto } else { 100% },
      if node.axis == "width" {
        grid(
          columns: tracks,
          rows: cross,
          column-gutter: node.gutter,
          ..rules,
          ..rendered,
        )
      } else {
        grid(
          columns: cross,
          rows: tracks,
          row-gutter: node.gutter,
          ..rules,
          ..rendered,
        )
      },
    )
    (content, false, none)
  }
}

#let render(node, contents, step, overflow: "off", slide: initial-slide) = {
  let (body, removed, cell) = render-node(
    node,
    contents,
    step,
    path: "grid",
    overflow: overflow,
    slide: slide,
  )
  if cell == none or removed {
    body
  } else {
    grid(
      columns: (1fr,),
      rows: (1fr,),
      render-cell(
        body,
        cell.style,
        step,
        id: cell.id,
        states: cell.states,
        overflow: overflow,
        slide: slide,
      ),
    )
  }
}

// The track of a rows root that can paginate: the one fractional track, with
// every other track `auto`. `none` for any other shape, which a breakable
// slide cannot lay out across pages. A rows root that strokes its boundaries
// is refused too: the rules would have to be redrawn around repeated rows,
// and no built-in content layout draws them.
#let breakable-track(node) = {
  if (
    node.kind != "split"
      or node.axis == "width"
      or node.stroke != none
      or type(node.gutter) == fraction
  ) {
    return none
  }
  let tracks = resolved-tracks(node)
  let flexible = range(tracks.len()).filter(index => type(tracks.at(index)) == fraction)
  if flexible.len() != 1 {
    return none
  }
  let index = flexible.first()
  if range(tracks.len()).any(other => other != index and tracks.at(other) != auto) {
    return none
  }
  index
}

// A breakable slide's grid: one native grid in the page flow, which Typst
// paginates itself. The tracks above the flowing one become a repeated grid
// header and the tracks below it a repeated grid footer, so every
// continuation page carries them; the flowing track is an `auto` row whose
// cell takes its content's height, which is what lets it break. An empty
// `1fr` row after it absorbs the slack on the last page, so the footer stays
// at the foot of the frame there too.
//
// `under` and `over` are the full-frame planes, already sized by the caller.
// They ride zero-height rows at the top of the header and the bottom of the
// footer, so they reach every page: `under` is placed before anything else
// draws, and `over` after the body.
//
// The split's gutter is laid out as explicit rows between its own tracks,
// not as `row-gutter`, so the plane rows and the slack row add no gap the
// fixed frame lacks. The gap between the last header row and the body
// repeats with the header, and the gap above the first footer row with the
// footer.
//
// Overflow observation is off: the flowing cell has no fixed region to
// overflow, and the repeated rows size to their content.
//
// `repeated: true` returns only the rows every page repeats, with their gaps
// toward the body: the caller measures them to make sure a page has room left
// for the body. Rows that outgrow the page alone would be cut at the page edge
// and repeated, cut the same way, on every page, so such a slide cannot break.
#let render-breakable(
  node,
  contents,
  step,
  slide: initial-slide,
  under: none,
  over: none,
  repeated: false,
) = {
  let index = breakable-track(node)
  let tracks = resolved-tracks(node)
  let row(position) = render-child(
    render-node,
    node.children.at(position),
    if position == index { auto } else { tracks.at(position) },
    contents,
    step,
    path: "grid." + str(position),
    slide: slide,
    ..if position == index {
      (shrink: (width: false, height: true), child-compact: false, flow: true)
    },
  )
  let gap = node.gutter
  let gapped = gap != 0pt
  let spacer = grid.cell(inset: 0pt, [])
  // Rows as (size, cell) pairs, so the row sizes and the cells cannot drift.
  let stack(cells) = {
    let result = ()
    for (position, cell) in cells.enumerate() {
      if gapped and position > 0 { result.push((gap, spacer)) }
      result.push((auto, cell))
    }
    result
  }
  let above = stack(range(index).map(row).filter(cell => cell != none))
  let below = stack(range(index + 1, tracks.len()).map(row).filter(cell => cell != none))
  if gapped and above.len() > 0 { above.push((gap, spacer)) }
  if gapped and below.len() > 0 { below.insert(0, (gap, spacer)) }
  if repeated {
    return grid(
      columns: (1fr,),
      rows: (above + below).map(pair => pair.at(0)),
      ..(above + below).map(pair => pair.at(1)),
    )
  }
  let body = row(index)
  if under != none {
    above.insert(0, (auto, grid.cell(inset: 0pt, place(top + left, under))))
  }
  if over != none {
    below.push((auto, grid.cell(inset: 0pt, place(bottom + left, over))))
  }
  let middle = ((auto, if body == none { [] } else { body }), (1fr, spacer))
  grid(
    columns: (1fr,),
    rows: (above + middle + below).map(pair => pair.at(0)),
    ..if above.len() > 0 { (grid.header(..above.map(pair => pair.at(1))),) },
    ..middle.map(pair => pair.at(1)),
    ..if below.len() > 0 { (grid.footer(..below.map(pair => pair.at(1))),) },
  )
}
