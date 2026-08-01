// Rendering of validated grid trees for one incremental step.
#import "shared.typ": array-max, tag
#import "incremental-core.typ": range-last, status
#import "grid-model.typ": body-cell-ids, resolved-tracks, fold-grid
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

// Resolve em components of an inset against a captured base text size, so
// label-targeted typography rules cannot scale cell geometry.
#let resolve-inset-part(value, base) = if type(value) == length {
  value.abs + value.em * base
} else if type(value) == relative {
  value.ratio + resolve-inset-part(value.length, base)
} else {
  value
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
  let before = surface.remove("before", default: [])
  let after = surface.remove("after", default: [])
  let inset = surface.remove("inset")
  let fill = surface.remove("fill", default: none)
  let stroke = surface.remove("stroke", default: none)
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
  // One block carries the whole cell, including its internal paint, and is
  // labeled <mosaic-cell-ID>. Native rules target it directly:
  //   show label("mosaic-cell-" + id): set text(...)
  //   show label("mosaic-cell-" + id): set align(horizon)
  //   show label("mosaic-cell-" + id): it => block(fill: ..., it)
  // The inset lives inside the label so wrapping rules paint edge to edge,
  // but em insets are resolved against the text size just outside the label,
  // so cell typography rules do not scale cell geometry.
  grid.cell(inset: 0pt, context {
    let base = text.size
    let body = block(
      width: 100%,
      height: region-height,
      fill: fill,
      stroke: stroke,
      radius: radius,
      clip: background != none,
    )[
      #if background != none {
        place(top + left, block(width: 100%, height: 100%, background))
      }
      #if id != none {
        for (name, alignment) in (
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
      }
      #block(
        width: 100%,
        height: region-height,
        inset: resolve-inset(inset, base),
        content,
      )
    ]
    if id == none {
      body
    } else {
      [#body#label("mosaic-cell-" + id)]
    }
  })
}

// `contents` is the id -> content map. Each content-bearing cell looks up its
// own content by id, so there is no positional cursor to thread or keep aligned
// across branches and removed incremental nodes. Returns (content, removed,
// style).
#let render-node(
  node,
  contents,
  step,
  key: "grid",
  overflow: "off",
  slide: 0,
) = {
  if node.kind == "on" {
    let supplied = body-cell-ids(node.child).map(id => contents.at(id))
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
      return ([], true, none)
    }
    let (child-content, removed, style) = render-node(
      node.child,
      contents,
      step,
      key: key + ".on",
      overflow: overflow,
      slide: slide,
    )
    return (apply-state(state, child-content), removed, style)
  }
  if node.kind == "cell" {
    let style = node.style
    if node.id != none {
      style.insert("_id", node.id)
    }
    let style = if style.len() == 0 { none } else { style }
    let body = if node.content == none { contents.at(node.id) } else { node.content }
    (transform(body, step, heading-key: key), false, style)
  } else {
    let rendered = ()
    let tracks = ()
    let resolved = resolved-tracks(node)
    for (index, child) in node.children.enumerate() {
      let (child-content, removed, style) = render-node(
        child,
        contents,
        step,
        key: key + "." + str(index),
        overflow: overflow,
        slide: slide,
      )
      if not removed {
        let content = render-cell(
          child-content,
          style,
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
      return ([], true, none)
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
    (content, false, none)
  }
}

#let render(node, contents, step, overflow: "off", slide: 0) = {
  let (body, removed, style) = render-node(
    node,
    contents,
    step,
    key: "grid",
    overflow: overflow,
    slide: slide,
  )
  if style == none or removed {
    body
  } else {
    grid(
      columns: (1fr,),
      rows: (1fr,),
      render-cell(
        body,
        style,
        overflow: overflow,
        key: "grid",
        slide: slide,
        step: step,
      ),
    )
  }
}
