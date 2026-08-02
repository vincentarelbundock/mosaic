// Deck runtime state and internal logical-slide numbering.
#import "grid-model.typ": cell

#let grid-state = state("mosaic:0.0.1:default-grid", cell(id: "body"))
#let background-state = state("mosaic:0.0.1:background", none)
#let foreground-state = state("mosaic:0.0.1:foreground", none)
#let logical-slide = counter("mosaic:0.0.1:logical-slide")
#let logical-slide-id = counter("mosaic:0.0.1:logical-slide-id")
#let logical-section = counter("mosaic:0.0.1:logical-section")
#let current-numbered = state("mosaic:0.0.1:numbered", true)

#let display-number(current, final, total) = {
  if total {
    [#current / #final]
  } else {
    str(current)
  }
}

/// Displays the current logical slide number.
///
/// -> content
#let slide-number(
  /// Whether to display the final total as `current / total`.
  /// -> bool
  total: false,
) = context {
  if current-numbered.get() {
    display-number(
      logical-slide.get().first(),
      logical-slide.final().first(),
      total,
    )
  } else {
    []
  }
}
