// Incremental command reduction and content reconstruction for one step.
#import "../shared.typ": (
  fail,
  array-max,
  key,
  tag,
  typst-sequence,
  typst-space,
  typst-styled,
)
#import "core.typ": apply-state, status
#import "command.typ": (
  content-children,
  is-command-on,
  is-temporal,
  replace-index,
  reveal-slots,
  slot-status,
  temporal-kinds,
)
#import "heading.typ": (
  canonical-only,
  capture-heading-style,
  has-heading,
  heading-continuation,
  resolve-heading-depth,
)
#import "../note/command.typ": is-note
#import "pause.typ": has-pause, is-pause, pause-schedule
#import "analysis.typ": has-deferred-record, max-step

// The elements `transform` can rebuild around transformed content. An element
// missing from this table is opaque: it is passed through untouched, and a
// step, pause, or note inside it is refused by name rather than lost.
//
// `positional` lists the fields the constructor takes positionally, in order.
// A field the element does not carry is skipped, which is how an optional
// leading positional (`place`'s alignment, `enum.item`'s number) stays out of
// the call, unless `defaults` names the value a constructor insists on being
// handed (`math.root` takes its index positionally even when there is none).
// `children` marks a variadic `children` field. Every other field is passed
// back by name.
#let make-shapes(
  funcs,
  positional: ("body",),
  children: false,
  defaults: (:),
) = funcs.map(func => (
  func: func,
  positional: positional,
  children: children,
  defaults: defaults,
))

#let container-shapes = (
  ..make-shapes((
    block, box, pad, hide, strong, emph, smallcaps, sub, super,
    underline, overline, strike, highlight, figure, figure.caption,
    grid.cell, table.cell, list.item, quote, footnote, math.equation,
    par, rect, square, circle, ellipse, scale, move, skew, repeat,
    pdf.artifact, math.lr, math.mid, math.cancel, math.limits, math.scripts,
    math.underline, math.overline,
  )),
  ..make-shapes((enum.item,), positional: ("number", "body")),
  ..make-shapes((align, place), positional: ("alignment", "body")),
  ..make-shapes((link,), positional: ("dest", "body")),
  ..make-shapes((rotate,), positional: ("angle", "body")),
  ..make-shapes((columns,), positional: ("count", "body")),
  ..make-shapes((terms.item,), positional: ("term", "description")),
  ..make-shapes((math.frac,), positional: ("num", "denom")),
  ..make-shapes((math.attach,), positional: ("base",)),
  ..make-shapes((math.accent,), positional: ("base", "accent")),
  ..make-shapes(
    (math.root,),
    positional: ("index", "radicand"),
    defaults: (index: none),
  ),
  ..make-shapes(
    (
      math.underbrace, math.overbrace, math.underbracket, math.overbracket,
      math.underparen, math.overparen, math.undershell, math.overshell,
    ),
    positional: ("body", "annotation"),
  ),
  ..make-shapes(
    (
      grid, table, list, enum, terms, stack, grid.header, grid.footer,
      table.header, table.footer, math.vec, math.cases,
    ),
    positional: (),
    children: true,
  ),
)
#let container-funcs = container-shapes.map(shape => shape.func)

// Elements whose label is a reference target. A label repeated on every frame
// makes `@label` fail with "occurs multiple times", so these keep theirs on
// the canonical frame only. Every other container keeps its label on every
// frame, because label-targeted show rules must keep applying.
#let referenceable-funcs = (figure, math.equation, footnote)

#let is-blank(value) = (
  value == []
    or (type(value) == content and value.func() in (typst-space, parbreak))
)

#let is-visually-empty(value) = {
  if is-note(value) {
    return true
  }
  if type(value) != content {
    return false
  }
  if value.func() == typst-sequence {
    return value.children.all(is-visually-empty)
  }
  if value.func() in container-funcs {
    let fields = value.fields()
    if "children" in fields {
      return fields.children.all(is-visually-empty)
    }
    let child = fields.at("body", default: none)
    return child != none and is-visually-empty(child)
  }
  false
}

// Visual frames repeat a heading's appearance without repeating the element,
// which is only possible where a plain container can be rebuilt around it.
#let continuation-fail(func, plural: false) = fail(
  "cannot create a structurally inert continuation for "
    + (if plural { "every heading" } else { "a heading" })
    + " nested in " + repr(func) + "; move "
    + (if plural { "headings" } else { "the heading" })
    + " into ordinary slide flow",
)

#let command-array(value) = {
  if value == none {
    ()
  } else if type(value) == array {
    value
  } else {
    (value,)
  }
}

#let render-command-state(body, state: "visible", hide: none, dim: none) = {
  if state == "visible" {
    command-array(body)
  } else if state == "hidden" {
    command-array(hide(body))
  } else if state == "dimmed" {
    if dim == none {
      fail("dimmed command content requires a dim function in drawing")
    }
    command-array(dim(body))
  } else {
    ()
  }
}

#let render-commands(values, step, hide: none, dim: none) = {
  let result = ()
  for value in command-array(values) {
    let temporal = if is-command-on(value) {
      value
    } else if is-temporal(value, kind: "temporal-on") {
      value.value
    } else {
      none
    }
    if temporal != none {
      let state = status(temporal.range, temporal.before, temporal.after, step)
      let body = render-commands(temporal.body, step, hide: hide, dim: dim)
      result += render-command-state(body, state: state, hide: hide, dim: dim)
    } else if is-temporal(value, kind: "temporal-reveal") {
      let temporal = value.value
      for slot in reveal-slots(temporal.items).slots {
        let body = render-commands(slot.body, step, hide: hide, dim: dim)
        let state = slot-status(temporal, slot, step)
        result += render-command-state(body, state: state, hide: hide, dim: dim)
      }
    } else if type(value) == array {
      result += render-commands(value, step, hide: hide, dim: dim)
    } else {
      result.push(value)
    }
  }
  result
}

// The marker a native list would draw at a nesting depth. `list.marker` is
// content, an array cycled by depth, or a function of the depth.
#let resolve-list-marker(marker, depth) = if type(marker) == array {
  marker.at(calc.rem(depth, marker.len()))
} else if type(marker) == function {
  marker(depth)
} else {
  marker
}

// The same marker setting as seen from `shift` levels further in, so a native
// list nested inside a reconstructed item continues the depth cycle instead of
// restarting it.
#let shift-list-marker(marker, shift) = if type(marker) == array {
  let offset = calc.rem(shift, marker.len())
  marker.slice(offset) + marker.slice(0, offset)
} else if type(marker) == function {
  depth => marker(depth + shift)
} else {
  marker
}

// Draws a run of list or enum items as a marker grid.
//
// A native list draws every marker with the list's own style, so an item that
// is hidden on this frame would still show its bullet or number. Here each
// marker is its own cell and takes the state of its item. Every metric comes
// from the active `list`/`enum` style rather than from a guess: the marker is
// the deck's own (`list.marker` at this depth, `enum.numbering`), an `auto`
// marker column sizes to the widest marker actually drawn, and the gutter is
// the element's own body indent. `spacing: auto` resolves as it does natively:
// paragraph leading between the items of a tight list, paragraph spacing
// between those of a wide one. `tight` is whether the items were written
// without blank lines between them.
//
// `rows` holds `(kind: "item", number:, state:, body:)` records and
// `(kind: "span", body:)` records for untimed siblings, which span both
// columns. Explicit item numbers (`3.`) restart the count, exactly as they do
// in a native enum; removed items still hold their number so the visible
// markers never shift between steps.
#let render-item-grid(item-kind, rows, depth: 0, tight: true) = context {
  let bulleted = item-kind == list.item
  let (spacing, body-indent, indent) = if bulleted {
    (list.spacing, list.body-indent, list.indent)
  } else {
    (enum.spacing, enum.body-indent, enum.indent)
  }
  let marker = list.marker
  let pattern = enum.numbering
  let number = if type(enum.start) == int { enum.start } else { 1 }
  let cells = ()
  for row in rows {
    if row.kind == "span" {
      cells.push(grid.cell(colspan: 2, align: left, row.body))
      continue
    }
    if type(row.number) == int {
      number = row.number
    }
    if row.state != "removed" {
      // The zero-width space gives the marker's line the metrics of body
      // text, so a marker set smaller than the text still sits on the first
      // baseline of its item, as a native marker does.
      cells.push(apply-state(row.state, sym.zws + if bulleted {
        resolve-list-marker(marker, depth)
      } else {
        numbering(pattern, number)
      }))
      cells.push(apply-state(row.state, if bulleted {
        set list(marker: shift-list-marker(marker, depth + 1))
        row.body
      } else {
        row.body
      }))
    }
    number += 1
  }
  pad(left: indent, grid(
    columns: (auto, 1fr),
    column-gutter: body-indent,
    row-gutter: if spacing != auto {
      spacing
    } else if tight {
      par.leading
    } else {
      par.spacing
    },
    align: (if bulleted { left } else { enum.number-align }, left),
    ..cells,
  ))
}

// Joins the entries of one sibling sequence back into content.
//
// An entry is either `(kind: "content", body:, blank:, hidden:, group:)` or a
// list item, `(kind: "item", func:, native:, number:, body:, state:,
// timed:)`. Content is joined as it stands, one `hide` around each contiguous
// hidden stretch. A run of items stays native unless one of them is timed (it
// sits after a pause or inside `on`); a timed run is drawn as a marker grid on
// every frame, so the list does not change shape as its items arrive.
#let render-entries(entries, depth: 0) = {
  let parts = ()
  let index = 0
  while index < entries.len() {
    let entry = entries.at(index)
    if entry.kind == "item" {
      let last = index
      let cursor = index + 1
      while cursor < entries.len() {
        let next = entries.at(cursor)
        if next.kind == "item" and next.func == entry.func {
          last = cursor
        } else if not (next.kind == "content" and next.blank) {
          break
        }
        cursor += 1
      }
      let run = entries.slice(index, last + 1)
      let items = run.filter(member => member.kind == "item")
      if items.any(item => item.timed) {
        parts.push(render-item-grid(
          entry.func,
          items,
          depth: depth,
          tight: not run.any(member => (
            member.kind == "content" and member.body.func() == parbreak
          )),
        ))
      } else {
        parts += run.map(member => if member.kind == "item" {
          member.native
        } else {
          member.body
        })
      }
      index = last + 1
    } else {
      let chunk = ()
      while index < entries.len() {
        let next = entries.at(index)
        if (
          next.kind != "content"
            or next.hidden != entry.hidden
            or next.group != entry.group
        ) {
          break
        }
        chunk.push(next.body)
        index += 1
      }
      let joined = chunk.sum(default: [])
      parts.push(if entry.hidden { hide(joined) } else { joined })
    }
  }
  parts.sum(default: [])
}

// The frame-level guard against records the walks never reached.
//
// `transform`, `max-step`, and `notes-at` find steps, pauses, and notes by
// walking content. A record produced where no walk can look (inside a
// `context` block, a `layout` callback, the output of a show rule, or a
// component, which is built from the first two) is only discovered when Typst
// realizes it, by which time the frame count is settled and the note list is
// built. It would render as nothing, so the slide runtime installs this as a
// `show metadata` rule on every frame and the loss becomes a diagnostic. A
// slide command realized inside a frame is a nested slide.
//
// `collected-notes` are the note bodies the runtime already gathered for this
// frame. A note in a layout field (a section tagline is the `subtitle` field)
// is rendered inside a `context` block, where the walks cannot reach it, but
// the runtime reads it from the field itself, so its record is expected here.
#let validate-frame-metadata(it, collected-notes: ()) = {
  let value = it.value
  if type(value) != dictionary or value.at("mosaic", default: none) != tag {
    return it
  }
  let kind = value.at("kind", default: none)
  let opaque = (
    " cannot be used inside a Mosaic component, a context block, a layout "
      + "callback, or show-rule output, where the slide runtime cannot see "
      + "it; move it outside"
  )
  if kind == "note" {
    if value.body in collected-notes {
      return it
    }
    fail("note" + opaque)
  }
  if kind == "pause" or kind in temporal-kinds {
    fail(
      "pause and steps cannot be used inside a Mosaic component, a section "
        + "tagline or other layout field, a context block, a layout "
        + "callback, or show-rule output, where the slide runtime cannot see "
        + "them; move them into a cell body",
    )
  }
  if kind == "slide" {
    fail("slide cannot be nested inside another slide or a container")
  }
  it
}

// Whether any temporal wrapper in this value holds a heading, which is the one
// thing `transform` cannot reconstruct: a heading that appears and disappears
// between frames would take its outline entry with it.
//
// The `has-heading` guard prunes: a subtree with no heading anywhere can
// hold no offending temporal either, so a deck whose bodies carry no headings
// (the common case) costs one walk and stops. The check is structural, so the
// slide runtime asks it once rather than on every frame.
#let has-temporal-heading(value) = {
  if not has-heading(value) {
    return false
  }
  if type(value) == array {
    return value.any(has-temporal-heading)
  }
  if type(value) == dictionary {
    return value.values().any(has-temporal-heading)
  }
  if type(value) != content {
    return false
  }
  if is-temporal(value) {
    return true
  }
  value.fields().values().any(has-temporal-heading)
}

#let validate-stable-temporal-headings(value) = {
  if has-temporal-heading(value) {
    fail(
      "headings cannot be wrapped in on, reveal, replace, or drawing; "
        + "keep semantic headings structurally stable across frames",
    )
  }
  value
}

// `headings` is `auto` for a cell, where the canonical frame carries the real
// heading and every other frame an inert continuation, or `"visual"` for a
// plane, which never owns a heading. `as-entries`, `frame`, `promote`, and
// `list-depth` are internal: they carry one walk's position into the nested
// walk of a pause segment.
#let transform(
  body,
  step,
  headings: auto,
  heading-scope: "content",
  as-entries: false,
  frame: auto,
  promote: auto,
  list-depth: 0,
) = {
  let heading-mode = if headings == auto {
    if step == 1 { "canonical" } else { "visual" }
  } else {
    headings
  }
  if heading-mode not in ("canonical", "visual") {
    fail("internal heading mode must be canonical or visual")
  }
  if type(heading-scope) != str {
    fail("internal heading scope must be a string")
  }
  // The physical step this walk renders, which a pause segment's local step
  // is not. The canonical frame is usually step 1 and is then known here; in
  // handout mode it is the last step, which only the runtime knows, so a
  // heading or label on a later frame asks `canonical-frame` at layout time.
  let frame = if frame == auto { step } else { frame }
  let promote = if promote == auto { headings == auto } else { promote }

  let visit(body, depth: 0, entries: false) = {
    let go = visit.with(depth: depth)
    if entries {
      // `body` is an array of sibling children; see `render-entries`.
      if has-pause(body) {
        let result = ()
        for (index, segment) in pause-schedule(body, max-step).enumerate() {
          let local-step = step - segment.start + 1
          let nested = transform(
            segment.children,
            calc.max(local-step, 1),
            headings: heading-mode,
            heading-scope: heading-scope + ":pause-" + str(index),
            as-entries: true,
            frame: frame,
            promote: promote,
            list-depth: depth,
          )
          for entry in nested {
            if entry.kind == "item" {
              entry.timed = entry.timed or index > 0
              if local-step < 1 and entry.state != "removed" {
                entry.state = "hidden"
              }
            } else {
              entry.hidden = local-step < 1
              entry.group = index
            }
            result.push(entry)
          }
        }
        return result
      }
      let result = ()
      let make-item(child, state, timed) = {
        let bulleted = child.func() == list.item
        let fields = child.fields()
        let label = fields.at("label", default: none)
        let number = fields.at("number", default: auto)
        let own = content-children(child.body).filter(part => not is-blank(part))
        if own.len() > 0 and is-pause(own.last()) {
          fail(
            "a pause at the end of a list item has no effect; put the pause "
              + "on its own line between the items, or use steps.reveal",
          )
        }
        let inner = visit(
          child.body,
          depth: if bulleted { depth + 1 } else { depth },
        )
        let native = if bulleted {
          list.item(inner)
        } else if type(number) == int {
          enum.item(number, inner)
        } else {
          enum.item(inner)
        }
        (
          kind: "item",
          func: child.func(),
          native: if label == none { native } else { [#native#label] },
          number: number,
          body: inner,
          state: state,
          timed: timed,
        )
      }
      for child in body {
        let func = if type(child) == content { child.func() } else { none }
        if func in (list.item, enum.item) {
          result.push(make-item(child, "visible", false))
          continue
        }
        // `on` around nothing but items of one kind times those items, so
        // they join the surrounding list instead of forming one of their own.
        if is-temporal(child, kind: "temporal-on") {
          let value = child.value
          let inner = content-children(value.body).filter(part => (
            not is-blank(part)
          ))
          let kinds = inner.map(part => part.func()).dedup()
          if kinds.len() == 1 and kinds.first() in (list.item, enum.item) {
            let state = status(value.range, value.before, value.after, step)
            result += inner.map(item => make-item(item, state, true))
            continue
          }
        }
        result.push((
          kind: "content",
          body: go(child),
          blank: is-blank(child),
          hidden: false,
          group: none,
        ))
      }
      return result
    }
    if type(body) != content {
      return body
    }
    if is-note(body) {
      return []
    }
    if is-pause(body) {
      return []
    }
    if body.func() == heading {
      if has-heading(body.body) {
        fail("heading bodies cannot contain nested headings")
      }
      let body = resolve-heading-depth(body)
      let style-state = state(
        key("heading-style:" + heading-scope + ":" + repr(body)),
        none,
      )
      // The real heading, emitted on one frame only. Its body is left exactly
      // as written unless it holds a step, pause, or note, which must be
      // resolved like any other content.
      let canonical = {
        let source = if has-deferred-record(body.body) {
          let fields = body.fields()
          let label = fields.remove("label", default: none)
          let rebuilt = heading(go(fields.remove("body")), ..fields)
          if label == none { rebuilt } else { [#rebuilt#label] }
        } else {
          body
        }
        [
          #show heading: capture-heading-style.with(style-state)
          #source
        ]
      }
      return if heading-mode == "canonical" {
        canonical
      } else {
        heading-continuation(
          style-state,
          go(body.body),
          canonical: if promote { canonical } else { none },
          frame: frame,
        )
      }
    }
    if is-temporal(body) {
      let value = body.value
      if value.kind == "temporal-on" {
        let state = status(
          value.range,
          value.before,
          value.after,
          step,
        )
        return apply-state(state, go(value.body))
      }
      if value.kind == "temporal-reveal" {
        let (list: list-mode, slots) = reveal-slots(value.items)
        let indexed = slots.filter(slot => slot.index != none)
        let kinds = indexed.map(slot => slot.body.func()).dedup()
        // A uniform bullet or numbered list is drawn as a marker grid so that
        // hidden items keep their markers aligned with the revealed ones.
        if list-mode and kinds.len() == 1 and kinds.first() in (
          list.item,
          enum.item,
        ) {
          let item-kind = kinds.first()
          let inner-depth = if item-kind == list.item { depth + 1 } else { depth }
          let rows = ()
          for slot in slots {
            // An untimed sibling rides along, always visible, spanning both
            // the marker and body columns. Pure spacing between items stays
            // out: the grid's own row gutter already provides it, and a row
            // per space would double every gap.
            if slot.index == none {
              if not is-blank(slot.body) {
                rows.push((kind: "span", body: go(slot.body)))
              }
              continue
            }
            rows.push((
              kind: "item",
              number: slot.body.fields().at("number", default: auto),
              state: slot-status(value, slot, step),
              body: visit(slot.body.body, depth: inner-depth),
            ))
          }
          return render-item-grid(
            item-kind,
            rows,
            depth: depth,
            tight: not slots.any(slot => (
              slot.index == none and slot.body.func() == parbreak
            )),
          )
        }
        return slots.map(slot => if slot.index == none {
          go(slot.body)
        } else {
          apply-state(slot-status(value, slot, step), go(slot.body))
        }).sum(default: [])
      }
      if value.kind == "temporal-replace" {
        let transformed = value.bodies.map(go)
        let index = replace-index(value, step)
        // Every alternative is measured at the width the slot is offered, so
        // prose wraps instead of running off the slide, and the slot takes the
        // largest of them. The outer box keeps the slot inline: `layout` alone
        // is a block and would break `f(x) = #replace(..)` out of its line.
        return box(layout(region => {
          let bounded = not (
            float.is-infinite(region.width.pt())
              or float.is-nan(region.width.pt())
          )
          let sizes = transformed.map(alternative => if bounded {
            measure(alternative, width: region.width)
          } else {
            measure(alternative)
          })
          box(
            width: array-max(sizes.map(size => size.width)),
            height: array-max(sizes.map(size => size.height)),
            if index != none {
              place(value.align, transformed.at(index))
            },
          )
        }))
      }
      if value.kind == "temporal-drawing" {
        let commands = render-commands(
          value.args,
          step,
          hide: value.hide,
          dim: value.dim,
        ).map(go).filter(command => not is-visually-empty(command))
        return (value.render)(
          ..value.kwargs,
          commands,
        )
      }
    }
    if body.func() == typst-sequence {
      return render-entries(
        visit(body.children, depth: depth, entries: true),
        depth: depth,
      )
    }
    if body.func() == typst-styled {
      return typst-styled(go(body.child), body.styles)
    }
    let has-visual-heading = heading-mode == "visual" and has-heading(body)
    if body.func() in container-funcs {
      let shape = container-shapes.find(shape => shape.func == body.func())
      let fields = body.fields()
      let label = fields.remove("label", default: none)
      // A list item's body is one level deeper, which is what selects the
      // marker of a list nested inside it.
      let inner-depth = if body.func() == list.item { depth + 1 } else { depth }
      // Built with loops rather than `map`: `fields.remove` inside a closure
      // would mutate a captured variable, which Typst rejects.
      let positional = ()
      for name in shape.positional {
        if name in fields {
          positional.push(visit(fields.remove(name), depth: inner-depth))
        } else if name in shape.defaults {
          positional.push(shape.defaults.at(name))
        }
      }
      let children = if shape.children {
        fields.remove("children", default: ()).map(go)
      } else {
        ()
      }
      // Content passed by name (a figure's caption, a quote's attribution, a
      // math attachment) is part of the slide like any body.
      let named = (:)
      for (name, value) in fields {
        named.insert(name, go(value))
      }
      let rebuilt = (body.func())(..positional, ..children, ..named)
      if has-visual-heading and has-heading(rebuilt) {
        continuation-fail(body.func(), plural: true)
      }
      // Labels on repeated visual containers would create duplicate
      // destinations. Ordinary containers retain their native labels.
      if label == none or has-visual-heading {
        return rebuilt
      }
      let labeled = [#rebuilt#label]
      if body.func() not in referenceable-funcs or frame == 1 {
        return labeled
      }
      return canonical-only(labeled, rebuilt, frame)
    }
    if has-visual-heading {
      continuation-fail(body.func())
    }
    // Anything else is opaque. Passing it through is right for a leaf, and
    // wrong for an element that carries a record this walk would have had to
    // resolve: the analysis walks count it, and nothing here applies it.
    if has-deferred-record(body) {
      fail(
        "pause, steps, and note cannot be used inside " + repr(body.func())
          + ", which the slide runtime cannot rebuild; move them outside it",
      )
    }
    body
  }
  if as-entries {
    return visit(body, depth: list-depth, entries: true)
  }
  visit(body, depth: list-depth)
}
