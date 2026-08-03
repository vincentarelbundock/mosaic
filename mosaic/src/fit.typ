// Content fitting utilities adapted from Touying's fit-to-height and
// fit-to-width helpers.
//
// Touying: https://github.com/touying-typ/touying
// Original fitting work credited there to Andreas Kröpelin / Polylux PR #91
// and ntjess. Adaptation from Touying 0.7.4, commit a8abe0d.
// Used under the MIT License; see THIRD_PARTY_LICENSES.md.

#let contains-text(it) = {
  if type(it) != content {
    return false
  }
  if it.func() in (text, math.equation) {
    return true
  }
  if it.has("body") {
    return contains-text(it.body)
  }
  if it.has("child") {
    return contains-text(it.child)
  }
  if it.has("children") {
    for child in it.children {
      if contains-text(child) {
        return true
      }
    }
  }
  false
}

#let reflow-scale(ratio, body) = scale(
  ratio,
  body,
  origin: top + left,
  reflow: true,
)

#let reflowed-size(ratio, body) = measure(reflow-scale(ratio, body))

#let should-scale(ratio, grow, shrink) = (
  (shrink and ratio < 100%) or (grow and ratio > 100%)
)

// A fitter only has a problem to solve inside a real allocation. Under
// `measure` there is none: the region is reported unbounded, and a `1fr`
// height inside it resolves to zero. Both degenerate cases would drive the
// ratios to infinity or zero and make the refinement steps divide by zero, so
// the fitters detect them and return the body untouched. Overflow observation
// measures every cell, so this is a routine path, not an edge case.
#let unsolvable(length) = (
  float.is-infinite(length.pt()) or float.is-nan(length.pt()) or length <= 0pt
)

#let size-to-pt(size, container-dimension) = {
  let resolved = size
  if type(size) == fraction {
    let fraction-text = repr(size * 1000000)
    resolved = float(fraction-text.slice(0, fraction-text.len() - 2)) / 1000000
  }
  if type(resolved) in (int, float, ratio) {
    container-dimension * resolved
  } else {
    measure(v(resolved)).height
  }
}

#let limit-content-width(body, container-size) = box(
  width: calc.min(container-size.width, measure(body).width),
  body,
)

/// Fits content to a width, shrinking or growing it only when requested.
#let fit-to-width(
  width: 1fr,
  grow: true,
  shrink: true,
  body,
) = layout(layout-size => {
  if unsolvable(layout-size.width) {
    return body
  }
  let content-width = measure(body).width
  let available-width = size-to-pt(width, layout-size.width)
  if unsolvable(available-width) {
    return body
  }
  let ratio = if content-width == 0pt {
    100%
  } else {
    available-width / content-width * 100%
  }
  if content-width != 0pt and should-scale(ratio, grow, shrink) {
    scale(
      box(body, width: content-width),
      origin: top + left,
      x: ratio,
      y: ratio,
      reflow: true,
    )
  } else {
    body
  }
})

/// Fits content to a finite height and width. Text may be reflowed while its
/// scale is refined; other content is scaled geometrically.
#let fit-to-height(
  height: 1fr,
  width: auto,
  grow: true,
  shrink: true,
  reflow: true,
  body,
) = context {
  let layout-content(
    width: auto,
    grow: true,
    shrink: true,
    height,
    body,
  ) = layout(container-size => {
    if unsolvable(container-size.width) or unsolvable(container-size.height) {
      return body
    }
    let available-height = if type(height) == fraction {
      container-size.height
    } else {
      size-to-pt(height, container-size.height)
    }
    if unsolvable(available-height) {
      return body
    }
    let boxed-content = limit-content-width(body, container-size)
    let size = measure(boxed-content)
    if size.height == 0pt or size.width == 0pt {
      return body
    }

    let height-ratio = available-height / size.height
    let available-width = if width in (none, auto) {
      container-size.width
    } else {
      size-to-pt(width, container-size.width)
    }
    if unsolvable(available-width) {
      return body
    }
    let width-ratio = available-width / size.width
    let ratio = calc.min(height-ratio, width-ratio) * 100%

    if width == auto and reflow and contains-text(body) {
      let adjust-width(ratio, boxed-content, target-size) = {
        let used-width-ratio = (
          reflowed-size(ratio, boxed-content).width / target-size.width
        )
        let adjusted = block(
          width: target-size.width / calc.sqrt(used-width-ratio),
          body,
        )
        (calc.sqrt(used-width-ratio) * 100%, adjusted)
      }

      let adjust-height(ratio, boxed-content, target-size) = {
        let used-height-ratio = (
          reflowed-size(ratio, boxed-content).height / target-size.height
        )
        let adjusted = block(
          width: target-size.width / float(ratio) * calc.sqrt(used-height-ratio),
          body,
        )
        ratio *= calc.sqrt(1 / used-height-ratio)
        used-height-ratio = (
          reflowed-size(ratio, adjusted).height / target-size.height
        )
        ratio /= used-height-ratio
        (ratio, adjusted)
      }

      for _ in range(2) {
        (ratio, boxed-content) = adjust-width(
          ratio,
          boxed-content,
          (width: available-width, height: available-height),
        )
        (ratio, boxed-content) = adjust-height(
          ratio,
          boxed-content,
          (width: available-width, height: available-height),
        )
      }

      let scaled-width = reflowed-size(ratio, boxed-content).width
      let current-width = measure(boxed-content).width
      boxed-content = box(
        width: current-width * (available-width / scaled-width),
        body,
      )
    }

    if should-scale(ratio, grow, shrink) {
      reflow-scale(ratio, boxed-content)
    } else {
      body
    }
  })

  let fitted = layout-content(
    width: width,
    grow: grow,
    shrink: shrink,
    height,
    body,
  )
  if type(height) == fraction {
    block(height: height, fitted)
  } else {
    fitted
  }
}
