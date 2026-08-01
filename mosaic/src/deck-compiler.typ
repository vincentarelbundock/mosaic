// Compilation of top-level Typst content into explicit and automatic slides.
#import "shared.typ": fail
#import "deck-commands.typ": is-command, slide-command, automatic-slide-command
#import "slide-runtime.typ": configure-deck, render-slide

#let typst-sequence = [].func()
#let typst-space = [ ].func()
#let typst-styled = text(red)[].func()
#let typst-context = (context []).func()
#let is-heading-space(value) = (
  value == []
    or (
      type(value) == content
        and value.func() in (parbreak, typst-space)
    )
)

#let wrap-content(value, wrappers) = {
  for wrapper in wrappers.rev() {
    value = (wrapper.func)(value, wrapper.styles)
  }
  value
}

#let top-level-content(body, wrappers: ()) = if (
  type(body) == content and body.func() == typst-sequence
) {
  body.children.map(child => top-level-content(
    child,
    wrappers: wrappers,
  )).flatten()
} else if type(body) == content and body.func() == typst-styled {
  top-level-content(
    body.child,
    wrappers: wrappers + ((
      func: body.func(),
      styles: body.styles,
    ),),
  )
} else {
  ((
    raw: body,
    shown: wrap-content(body, wrappers),
    wrappers: wrappers,
  ),)
}
// `auto-slide`, when not none, is a user-supplied constructor `(title, body) ->
// slide command` (the value returned by `mosaic.slide(...)`). It replaces the
// built-in header-body layout for automatic level-2 heading slides, letting a
// deck route `==` slides through its own styled `slide` helper.
#let compile-deck(body, section-grid: auto, auto-slide: none) = {
  let output = ()
  let mode = none
  let section = none
  let current = ()
  let flushed = none
  let slide-wrappers = ()

  // PROTOTYPE: automatic slides re-apply the user's captured set/show
  // wrappers around the rendered slide, exactly as explicit slide commands
  // do, so deck-level rules (including label-targeted rules) see the
  // rendered cell structure.
  let flush(mode, section, current, wrappers) = {
    if mode == "slide" {
      let body = current.sum(default: [])
      let rendered = if auto-slide == none {
        render-slide(automatic-slide-command(section, body))
      } else {
        let produced = auto-slide(section, body)
        if not is-command(produced, "slide") {
          fail(
            "setup auto-slide must return a mosaic.slide(...) command; "
              + "got " + repr(type(produced)),
          )
        }
        render-slide(produced.value)
      }
      wrap-content(rendered, wrappers)
    } else if mode == "section" {
      wrap-content(
        render-slide(slide-command(
          (section,),
          grid: section-grid,
          numbered: false,
        )),
        wrappers,
      )
    } else {
      none
    }
  }

  let flush-current(mode, section, current, wrappers) = (
    flush(mode, section, current, wrappers),
    none,
    none,
    (),
  )

  for entry in top-level-content(body) {
    let value = entry.raw
    let shown = entry.shown
    // PROTOTYPE: content collected into an automatic slide is re-styled by
    // the outer wrap in flush(); strip the slide-level wrapper prefix from
    // each piece so those styles are not applied twice (relative units such
    // as em sizes would compound). Wrappers nest, so the first N wrappers of
    // every piece inside the slide match the heading's N wrappers.
    let inner = if entry.wrappers.len() >= slide-wrappers.len() {
      wrap-content(value, entry.wrappers.slice(slide-wrappers.len()))
    } else {
      shown
    }
    let level = if (
      type(value) == content and value.func() == heading
    ) {
      value.depth
    } else {
      none
    }

    if is-command(value, "slide") {
      (flushed, mode, section, current) = flush-current(mode, section, current, slide-wrappers)
      if flushed != none { output.push(flushed) }
      output.push(wrap-content(
        render-slide(value.value),
        entry.wrappers,
      ))
    } else if is-command(value, "deck") {
      (flushed, mode, section, current) = flush-current(mode, section, current, slide-wrappers)
      if flushed != none { output.push(flushed) }
      output.push(wrap-content(
        configure-deck(
          default-grid: value.value.default-grid,
          background: value.value.background,
          foreground: value.value.foreground,
        ),
        entry.wrappers,
      ))
    } else if level in (1, 2) {
      (flushed, mode, section, current) = flush-current(mode, section, current, slide-wrappers)
      if flushed != none { output.push(flushed) }
      if level == 1 {
        mode = "section"
        section = value
        current = ()
      } else {
        mode = "slide"
        section = value
        current = ()
      }
      slide-wrappers = entry.wrappers
    } else if is-heading-space(value) {
      if mode == "slide" {
        current.push(inner)
      }
    } else if (
      mode == none
        and type(value) == content
        and value.func() in (metadata, typst-context)
    ) {
      output.push(shown)
    } else if mode == "slide" {
      current.push(inner)
    } else if mode == "section" {
      fail(
        "automatic section slides cannot contain "
          + "content before the next level-2 heading",
      )
    } else {
      fail(
        "content appears before the first level-1 or level-2 heading "
          + "handled by setup",
      )
    }
  }

  let flushed = flush(mode, section, current, slide-wrappers)
  if flushed != none { output.push(flushed) }
  output.sum(default: [])
}
