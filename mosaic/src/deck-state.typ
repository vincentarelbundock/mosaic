// Deck runtime state and public numbering/navigation queries.
#import "shared.typ": fail
#import "grid-model.typ": cell

#let grid-state = state("mosaic:0.0.1:default-grid", cell(id: "body"))
#let background-state = state("mosaic:0.0.1:background", none)
#let foreground-state = state("mosaic:0.0.1:foreground", none)
#let logical-slide = counter("mosaic:0.0.1:logical-slide")
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

/// Displays the current semantic section number.
///
/// Section slides created with `layouts.section()` are counted
/// automatically. Custom section layouts opt in with `slide(section: true)`.
///
/// -> content
#let section-number(
  /// Whether to display the final total as `current / total`.
  /// -> bool
  total: false,
) = context {
  display-number(
    logical-section.get().first(),
    logical-section.final().first(),
    total,
  )
}

/// Displays the current physical Typst page number.
///
/// -> content
#let page-number(
  /// Whether to display the final total as `current / total`.
  /// -> bool
  total: false,
) = context {
  let pages = counter(page)
  display-number(
    pages.get().first(),
    pages.final().first(),
    total,
  )
}

/// Returns the active heading at an exact level, or a fallback value.
///
/// -> content | none | any
#let current-heading(
  /// Exact heading level to query.
  /// -> int
  level: 1,
  /// Required value of the heading's `outlined` field.
  /// -> bool
  outlined: true,
  /// Value returned when no matching heading is active.
  /// -> any
  default: none,
) = {
  if type(level) != int or level < 1 {
    fail("current-heading level must be a positive integer")
  }
  if type(outlined) != bool {
    fail("current-heading outlined must be a boolean")
  }
  let headings = query(selector(heading).before(here()))
  let active = headings.rev().find(it => it.level <= level)
  if (
    active == none
      or active.level != level
      or active.outlined != outlined
  ) {
    default
  } else {
    active
  }
}
