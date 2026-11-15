// Content fitting utilities adapted from Touying's fit-to-height and
// fit-to-width helpers.
//
// Touying: https://github.com/touying-typ/touying
// Original fitting work credited there to Andreas Kröpelin / Polylux PR #91
// and ntjess. Adaptation from Touying 0.7.4, commit a8abe0d.
// Used under the MIT License; see THIRD_PARTY_LICENSES.md.
#import "shared.typ": fail
#import "incremental/analysis.typ": has-deferred-record

#let reflow-scale(ratio, body) = scale(
  ratio,
  body,
  origin: top + left,
  reflow: true,
)

// Content already at its allocation measures as exactly `natural-ratio`, so
// that is the boundary between growing and shrinking rather than a tunable.
#let natural-ratio = 100%

// Measurement is not exact: a cell whose content fits to within a rounding
// error reports a ratio a hair off `natural-ratio`, and rescaling on that would
// resize content that was already correct. The tolerance is a numerical guard,
// not a design knob, which is why it is not configurable.
#let fit-tolerance = 0.05%

#let is-scale-needed(ratio, grow: false, shrink: true) = (
  (shrink and ratio < natural-ratio - fit-tolerance)
    or (grow and ratio > natural-ratio + fit-tolerance)
)

// A fitter only has a problem to solve inside a real allocation. Under
// `measure` there is none: the region is reported unbounded, and a `1fr`
// height inside it resolves to zero. Both degenerate cases would drive the
// ratios to infinity or zero and make the refinement steps divide by zero, so
// the fitters detect them and return the body untouched. This is a routine
// path, not an edge case: `steps.replace` measures its alternatives, captions
// measure their frame, the speaker thumbnail measures a whole slide, and
// overflow observation measures every cell whenever it is switched on.
#let is-unsolvable(length) = (
  float.is-infinite(length.pt()) or float.is-nan(length.pt()) or length <= 0pt
)

// The one scale factor that brings a measured `size` into the space available
// on the axes that constrain it. `auto` leaves an axis unconstrained, and an
// axis whose measurement is zero constrains nothing, so a body with no extent
// on either axis reports the natural ratio and is left alone. Both public
// fitters and the speaker-view thumbnail derive their factor here, so the
// geometry is stated once.
#let fit-ratio(size, width: auto, height: auto) = {
  let ratios = ()
  if width != auto and size.width > 0pt {
    ratios.push(width / size.width)
  }
  if height != auto and size.height > 0pt {
    ratios.push(height / size.height)
  }
  if ratios.len() == 0 {
    return natural-ratio
  }
  calc.min(..ratios) * 100%
}

// A width or height option resolved against the region that hosts it, inside
// a `layout` callback where em units have a font size to resolve against.
// `auto` means the whole region. A fraction reaches here only from
// `fit-to-height`'s own `1fr` default, which the block it wraps around the
// fitter makes real, so the region seen here already is that share. The
// public `fit` refuses a fraction before it gets this far.
#let resolve-extent(value, container-dimension) = if (
  value in (none, auto) or type(value) == fraction
) {
  container-dimension
} else if type(value) == ratio {
  container-dimension * value
} else if type(value) == relative {
  container-dimension * value.ratio + value.length.to-absolute()
} else {
  value.to-absolute()
}

#let validate-extent(value, name) = {
  // A fraction is a share of the space left over among siblings, and a fitter
  // measuring one block has no siblings to share with. It used to be read as
  // "the whole region" whatever its magnitude, which made `2fr` and `1fr` the
  // same request; the ratio says what was meant.
  if type(value) == fraction {
    fail(
      "fit " + name + " cannot be a fraction such as " + repr(value)
        + ", which is a share of free space that fit does not divide; use a "
        + "ratio of the region, such as 100%",
    )
  }
  if value != auto and type(value) not in (length, ratio, relative) {
    fail(
      "fit " + name + " must be auto, a length, a ratio, or a relative "
        + "length, received " + repr(value),
    )
  }
  value
}

#let validate-flag(value, name) = {
  if type(value) != bool {
    fail("fit " + name + " must be a boolean, received " + repr(value))
  }
  value
}

#let limit-content-width(body, width: 0pt) = box(
  width: calc.min(width, measure(body).width),
  body,
)

// Fits content to a width, shrinking or growing it only when requested.
#let fit-to-width(
  width: 1fr,
  grow: true,
  shrink: true,
  body,
) = layout(layout-size => {
  if is-unsolvable(layout-size.width) {
    return body
  }
  let content-width = measure(body).width
  let available-width = resolve-extent(width, layout-size.width)
  if is-unsolvable(available-width) {
    return body
  }
  let ratio = fit-ratio(
    (width: content-width, height: 0pt),
    width: available-width,
  )
  if content-width != 0pt and is-scale-needed(ratio, grow: grow, shrink: shrink) {
    reflow-scale(ratio, box(body, width: content-width))
  } else {
    body
  }
})

// Fits content to a finite height and width, scaling it geometrically.
#let fit-to-height(
  height: 1fr,
  width: auto,
  grow: true,
  shrink: true,
  body,
) = {
  let fitted = layout(container-size => {
    if is-unsolvable(container-size.width) or is-unsolvable(container-size.height) {
      return body
    }
    // A fractional height means "the space this block is given", which is the
    // whole region here; the enclosing `block(height: height)` below makes the
    // allocation real.
    let available-height = resolve-extent(height, container-size.height)
    if is-unsolvable(available-height) {
      return body
    }
    let boxed-content = limit-content-width(body, width: container-size.width)
    let size = measure(boxed-content)
    if size.height == 0pt or size.width == 0pt {
      return body
    }

    let available-width = resolve-extent(width, container-size.width)
    if is-unsolvable(available-width) {
      return body
    }
    let ratio = fit-ratio(size, width: available-width, height: available-height)

    // Content that is too tall at the region's width is about to be shrunk,
    // and once shrunk it no longer fills that width: prose scaled to a third
    // would sit in a third of the cell. So it is offered a wider measure
    // first. For text, height falls roughly as width grows, which makes the
    // square root of the height ratio the scale at which both axes fill; one
    // more measurement at that width settles it. The wider layout is kept only
    // if it ends up larger, so content that cannot reflow (a single tall
    // figure) is scaled exactly as before.
    if shrink and ratio < natural-ratio - fit-tolerance {
      let guess = calc.sqrt(available-height / size.height)
      if guess < 1 {
        let wider-content = limit-content-width(
          body,
          width: container-size.width / guess,
        )
        let wider-size = measure(wider-content)
        let wider-ratio = fit-ratio(
          wider-size,
          width: available-width,
          height: available-height,
        )
        if wider-ratio > ratio {
          boxed-content = wider-content
          ratio = wider-ratio
        }
      }
    }

    if is-scale-needed(ratio, grow: grow, shrink: shrink) {
      reflow-scale(ratio, boxed-content)
    } else {
      body
    }
  })
  if type(height) == fraction {
    block(height: height, fitted)
  } else {
    fitted
  }
}

// Scales content as it stands, without offering it a narrower width first.
// Content that reflows would rearrange itself into the region and never need
// scaling; content that cannot, a table or a diagram, keeps its proportions and
// is scaled by whichever axis binds.
#let fit-unwrapped(
  body,
  width: auto,
  height: auto,
  grow: false,
  shrink: true,
) = layout(region => {
  if is-unsolvable(region.width) or is-unsolvable(region.height) {
    return body
  }
  let available-width = resolve-extent(width, region.width)
  let available-height = resolve-extent(height, region.height)
  if is-unsolvable(available-width) or is-unsolvable(available-height) {
    return body
  }
  let size = measure(body)
  let ratio = fit-ratio(size, width: available-width, height: available-height)
  if is-scale-needed(ratio, grow: grow, shrink: shrink) {
    reflow-scale(ratio, box(body, width: size.width))
  } else {
    body
  }
})

/// Scales one block of content to the space it is given.
///
/// Mosaic never resizes body content on its own, so a slide holding more than
/// it can show reports an overflow rather than shrinking. `fit` is the explicit
/// per-block exception, for content whose size the author does not control: a
/// wide table, a chart, a generated list, a number meant to fill the slide.
///
/// It measures the content against the region the call sits in and scales it
/// geometrically, so proportions are preserved and the surrounding layout
/// accounts for the new size. With no `width` or `height` it fits the whole
/// region.
///
/// ```typ
/// #mosaic.slide[
///   == A long argument
///   #mosaic.fit(generated-list)
/// ]
/// ```
///
/// Fitting works in cells, in the `background` and `foreground` planes, and in
/// ordinary content. Pass `grow: true` for display type that should fill its
/// cell rather than merely avoid overflowing it:
///
/// ```typ
/// #mosaic.fit(grow: true)[42%]
/// ```
///
/// *Content that must not be re-laid out*
///
/// By default the content is offered the region's width first, so text and
/// lists wrap into the cell and are scaled only if they are still too tall.
/// Prose that must shrink is re-wrapped at a wider measure first, so the scaled
/// block fills the width of its cell instead of standing in a narrow column.
/// A table, chart, or diagram would rearrange its own columns instead, which
/// changes the composition rather than its size. Pass `wrap: false` to scale
/// such a block exactly as it stands:
///
/// ```typ
/// #mosaic.fit(wrap: false, my-wide-table)
/// ```
///
/// *Overflow*
///
/// A fitted block cannot overflow, so it emits no `<mosaic-overflow-warning>`
/// record and never fails an `overflow: "error"` compile. A cell that fits its
/// content therefore stops reporting how full it is.
///
/// *Incremental content and speaker notes*
///
/// Fitting measures its body, which means holding it inside a closure that the
/// slide runtime cannot look into. Incremental markers and speaker notes are
/// found by walking the slide's content, so anything inside a fitted block
/// would be invisible to that walk: the reveals would collapse into one frame
/// and the notes would vanish. `fit` rejects such a body rather than dropping
/// it silently. Keep `pause`, `steps`, and `note` outside the fitted block, or
/// fit each revealed part on its own.
///
/// *Sizes*
///
/// `width` and `height` take a length (`12cm`, `20em`), a ratio of the region
/// (`50%`), or a relative length combining the two (`50% + 1cm`). `auto` is
/// the whole region, and so is `100%`. A fraction such as `1fr` is refused: it
/// is a share of the space left over among siblings, and a fitted block is
/// measured on its own.
///
/// -> content
#let fit(
  /// The content to scale.
  /// -> content
  body,
  /// Width to fit into. `auto` uses the full width of the region.
  /// -> auto | length | ratio | relative
  width: auto,
  /// Height to fit into. `auto` uses the full height of the region.
  /// -> auto | length | ratio | relative
  height: auto,
  /// Let the content re-lay out at the available width before it is measured.
  /// Pass `false` for a block whose own arrangement must be preserved.
  /// -> bool
  wrap: true,
  /// Scale content up when it is smaller than the space available.
  /// -> bool
  grow: false,
  /// Scale content down when it is larger than the space available.
  /// -> bool
  shrink: true,
) = {
  _ = validate-extent(width, "width")
  _ = validate-extent(height, "height")
  _ = validate-flag(wrap, "wrap")
  _ = validate-flag(grow, "grow")
  _ = validate-flag(shrink, "shrink")
  // Measuring means capturing the body in a closure, where the runtime's
  // incremental and note walks cannot reach it. Refusing here is the difference
  // between a diagnostic and a deck that quietly loses its reveals. The test
  // is structural rather than a step count: a body whose only step is step 1
  // adds no frame, and would vanish all the same.
  if has-deferred-record(body) {
    fail(
      "fit cannot hold incremental steps or speaker notes; they would be "
        + "invisible to the slide runtime. Move pause, steps, and note outside "
        + "the fitted block, or fit each revealed part separately",
    )
  }
  if not wrap {
    return fit-unwrapped(
      body,
      width: width,
      height: height,
      grow: grow,
      shrink: shrink,
    )
  }
  // A width alone is the one case that must not consult the height: fitting a
  // single line to a column is a width problem, and the region's height would
  // otherwise bind first and shrink it further than asked.
  if width != auto and height == auto {
    fit-to-width(width: width, grow: grow, shrink: shrink, body)
  } else {
    fit-to-height(
      height: if height == auto { 1fr } else { height },
      width: width,
      grow: grow,
      shrink: shrink,
      body,
    )
  }
}
