// Rendering of validated grid trees for one incremental step.
#import "shared.typ": array-max, tag
#import "incremental-core.typ": range-last, status
#import "grid-model.typ": count-bodies, resolved-tracks, fold-grid
#import "incremental.typ": contains-heading, max-step, transform, apply-state
#import "fit.typ": fit-to-width, fit-to-height

#let observe-overflow(body, cell, slide, step) = layout(region => {
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
  body
})

#let fixed-content-has-heading(node) = fold-grid(
  node,
  cell => cell.content != none and contains-heading(cell.content),
  (node, child) => child,
  (node, children) => children.any(value => value),
)

#let max-node(node) = fold-grid(
  node,
  cell => {
    if cell.content == none {
      1
    } else {
      max-step(cell.content)
    }
  },
  (node, child) => calc.max(range-last(node.range), child),
  (node, children) => array-max(children),
)

#let split-cell-surface(surface) = {
  let native = surface
  let fill = native.remove("fill", default: none)
  let inset = native.remove("inset")
  let alignment = native.remove("align", default: left + top)
  let stroke = native.remove("stroke", default: none)
  (
    native: native,
    fill: fill,
    inset: inset,
    alignment: alignment,
    stroke: stroke,
  )
}

#let render-cell(
  content,
  style,
  overflow: "off",
  key: "grid",
  slide: 0,
  step: 1,
  track: none,
  vertical: false,
) = {
  if style == none {
    if overflow == "warn" {
      return observe-overflow(content, key, slide, step)
    }
    return content
  }
  let surface = style
  let id = surface.remove("_id", default: none)
  let text-style = surface.remove("text", default: (:))
  // Paragraph leading rides along in the text style dictionary; it must be
  // split out because it belongs to `par`, not `text`.
  let text-leading = text-style.remove("leading", default: none)
  let before = surface.remove("before", default: [])
  let after = surface.remove("after", default: [])
  let radius = surface.remove("radius", default: 0pt)
  let background = surface.remove("background", default: none)
  let content-sized = surface.remove("content-sized", default: false)
  let fit = surface.remove("fit", default: none)
  let fit-reserve = surface.remove("_fit-reserve", default: none)
  let fit-width = surface.remove("_fit-width", default: auto)
  // A cell in an `auto` row track sizes to its content, so its sibling `1fr`
  // tracks receive the remaining height and can align content on the horizon.
  // (`auto` on the horizontal axis is a column width and must not collapse the
  // cell height, so only the vertical axis opts in here.)
  let auto-height = vertical and track == auto
  let region-height = if content-sized or auto-height { auto } else { 100% }
  let content = before + content + after
  let content = if text-style.len() == 0 {
    content
  } else {
    text(..text-style, content)
  }
  let content = if text-leading == none {
    content
  } else {
    {
      set par(leading: text-leading)
      content
    }
  }
  let content = if fit == "width" {
    fit-to-width(width: if fit-width == auto { 1fr } else { fit-width }, grow: false, content)
  } else if fit in ("auto", "contain") {
    fit-to-height(
      height: 1fr,
      width: fit-width,
      reserve: fit-reserve,
      grow: false,
      shrink: true,
      reflow: fit == "auto",
      content,
    )
  } else {
    content
  }
  if overflow == "warn" {
    content = observe-overflow(
      content,
      if id == none { key } else { id },
      slide,
      step,
    )
  }
  let content = if id == none {
    content
  } else {
    block(width: 100%, height: region-height)[
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
      #content
    ]
  }
  if background != none {
    let parts = split-cell-surface(surface)
    grid.cell(
      ..parts.native,
      inset: 0pt,
      block(
        width: 100%,
        height: region-height,
        fill: parts.fill,
        stroke: parts.stroke,
        radius: radius,
        clip: true,
      )[
        #place(
          top + left,
          block(width: 100%, height: 100%, background),
        )
        #block(
          width: 100%,
          height: region-height,
          inset: parts.inset,
          align(parts.alignment, content),
        )
      ],
    )
  } else if radius == 0pt {
    grid.cell(..surface, content)
  } else {
    let parts = split-cell-surface(surface)
    grid.cell(
      ..parts.native,
      inset: 0pt,
      block(
        width: 100%,
        height: region-height,
        fill: parts.fill,
        inset: parts.inset,
        stroke: parts.stroke,
        radius: radius,
        align(parts.alignment, content),
      ),
    )
  }
}

#let render-node(
  node,
  bodies,
  step,
  next: 0,
  key: "grid",
  overflow: "off",
  slide: 0,
) = {
  if node.kind == "on" {
    let count = count-bodies(node.child)
    let supplied = bodies.slice(next, next + count)
    if supplied.any(contains-heading) or fixed-content-has-heading(node.child) {
      assert(
        false,
        message: "mosaic: headings cannot be placed in incremental grid "
          + "nodes; keep semantic headings structurally stable across frames",
      )
    }
    let state = status(
      node.range,
      node.before,
      node.after,
      step,
    )
    if state == "removed" {
      return ([], next + count-bodies(node.child), true, none)
    }
    let (content, next, removed, style) = render-node(
      node.child,
      bodies,
      step,
      next: next,
      key: key + ".on",
      overflow: overflow,
      slide: slide,
    )
    let content = apply-state(state, content)
    return (content, next, removed, style)
  }
  if node.kind == "cell" {
    let style = node.style
    if node.id != none {
      style.insert("_id", node.id)
    }
    let style = if style.len() == 0 { none } else { style }
    if node.content == none {
      (
        transform(bodies.at(next), step, heading-key: key),
        next + 1,
        false,
        style,
      )
    } else {
      (
        transform(node.content, step, heading-key: key),
        next,
        false,
        style,
      )
    }
  } else {
    let rendered = ()
    let tracks = ()
    let resolved = resolved-tracks(node)
    for (index, child) in node.children.enumerate() {
      let result = render-node(
        child,
        bodies,
        step,
        next: next,
        key: key + "." + str(index),
        overflow: overflow,
        slide: slide,
      )
      next = result.at(1)
      if not result.at(2) {
        let content = render-cell(
          result.at(0),
          result.at(3),
          overflow: overflow,
          key: key + "." + str(index),
          slide: slide,
          step: step,
          track: resolved.at(index),
          vertical: node.axis != "width",
        )
        rendered.push(content)
        tracks.push(resolved.at(index))
      }
    }
    if rendered.len() == 0 {
      return ([], next, true, none)
    }
    // Interior boundaries between the tracks that survived this step; native
    // grid lines are drawn centered in the gutter.
    let rule = node.at("rule", default: none)
    let rules = if rule == none {
      ()
    } else if node.axis == "width" {
      range(1, rendered.len()).map(x => grid.vline(x: x, stroke: rule))
    } else {
      range(1, rendered.len()).map(y => grid.hline(y: y, stroke: rule))
    }
    let content = block(
      width: 100%,
      height: 100%,
      if node.axis == "width" {
        grid(
          columns: tracks,
          rows: (1fr,),
          column-gutter: node.gutter,
          ..rules,
          ..rendered,
        )
      } else {
        grid(
          columns: (1fr,),
          rows: tracks,
          row-gutter: node.gutter,
          ..rules,
          ..rendered,
        )
      },
    )
    (content, next, false, none)
  }
}

#let render(node, bodies, step, next: 0, overflow: "off", slide: 0) = {
  let result = render-node(
    node,
    bodies,
    step,
    next: next,
    key: "grid",
    overflow: overflow,
    slide: slide,
  )
  let content = if result.at(3) == none or result.at(2) {
    result.at(0)
  } else {
    grid(
      columns: (1fr,),
      rows: (1fr,),
      render-cell(
        result.at(0),
        result.at(3),
        overflow: overflow,
        key: "grid",
        slide: slide,
        step: step,
      ),
    )
  }
  (content, result.at(1), result.at(2))
}
