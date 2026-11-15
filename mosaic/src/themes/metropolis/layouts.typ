// Callable Metropolis layout namespace: base layouts with Metropolis
// defaults. The facade and the definition share these defaults, so an
// explicit `m.layouts.content()` call builds the same slide an automatic
// heading does.
#import "../../layout/api.typ" as _base
#import "../../author.typ": author
#import "../../grid/api.typ" as _grids
#import "../../component/api.typ" as _components

#let content = _base.content.with(variant: "header-body-footer")

// The classic Metropolis title page: the heading stack over a full-width
// accent rule, details beneath, flush left at the vertical center.
#let title = _base.title.with(variant: "ruled")

// The signature Metropolis section: the title block over a full-width
// progress bar that fills as the deck advances through its sections. The bar
// is a real grid row rather than a label rule, because the section cell fits
// its content to the slide width and content appended by a show rule would
// land outside the fitted region.
//
// Bare calls (and the automatic heading slides, through the definition) get
// the progress composition; any argument falls through to the base layout, so
// the full base signature stays reachable under this theme.
#let section(..args) = if args.pos().len() == 0 and args.named().len() == 0 {
  _grids.rows(
    tracks: (1fr, auto, auto, 1fr),
    _grids.cell("section-margin-top", content: []),
    "section",
    _grids.cell(
      "section-progress",
      inset: 0pt,
      content: _components.progress(
        variant: "line", count: "sections", width: 100%, thickness: 4.5pt,
      ),
    ),
    _grids.cell("section-margin-bottom", content: []),
  )
} else {
  _base.section(..args)
}

#let image = _base.image
