// Speaker-note extraction for one physical incremental frame.
#import "incremental-core.typ": status
#import "incremental-command.typ": (
  content-children,
  is-command-on,
  is-list-item,
  is-temporal,
)
#import "note-command.typ": is-note
#import "grid-model.typ": fold-grid

#let notes-at(value, step) = {
  let visit(value) = {
    if is-note(value) {
      return (value.value.body,)
    }
    if is-command-on(value) {
      let state = status(value.range, value.before, value.after, step)
      if state == "visible" {
        return visit(value.body)
      }
      return ()
    }
    if type(value) == array {
      return value.fold((), (notes, item) => notes + visit(item))
    }
    if type(value) == dictionary {
      return value.values().fold((), (notes, item) => notes + visit(item))
    }
    if type(value) != content {
      return ()
    }
    if is-temporal(value) {
      let timed = value.value
      if timed.kind == "temporal-on" {
        let state = status(timed.range, timed.before, timed.after, step)
        if state == "visible" {
          return visit(timed.body)
        }
        return ()
      }
      if timed.kind == "temporal-reveal" {
        if timed.items.len() == 1 {
          let children = content-children(timed.items.first())
          if children.any(is-list-item) {
            let result = ()
            let index = 0
            for child in children {
              if is-list-item(child) {
                let state = status(
                  timed.start + index,
                  timed.before,
                  timed.after,
                  step,
                )
                if state == "visible" {
                  result += visit(child)
                }
                index += 1
              } else {
                result += visit(child)
              }
            }
            return result
          }
        }
        let result = ()
        for (index, item) in timed.items.enumerate() {
          let state = status(
            timed.start + index,
            timed.before,
            timed.after,
            step,
          )
          if state == "visible" {
            result += visit(item)
          }
        }
        return result
      }
      if timed.kind == "temporal-replace" {
        if step < timed.start {
          return ()
        }
        let index = calc.min(step - timed.start, timed.bodies.len() - 1)
        return visit(timed.bodies.at(index))
      }
      if timed.kind == "temporal-reducer" {
        return visit(timed.args)
      }
    }
    if value.func() == metadata {
      return ()
    }
    value.fields().values().fold(
      (),
      (notes, field) => notes + visit(field),
    )
  }
  visit(value)
}

#let fixed-grid-notes-at(node, step) = fold-grid(
  node,
  cell => if cell.content == none { () } else { notes-at(cell.content, step) },
  (node, child) => if (
    status(node.range, node.before, node.after, step) == "visible"
  ) { child } else { () },
  (node, children) => children.fold((), (notes, child) => notes + child),
)
