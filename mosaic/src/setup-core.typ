// Sane presentation defaults, applied as a document-wide show rule.
#import "slide-runtime.typ": configure-deck
#import "deck-compiler.typ": compile-deck
#import "settings.typ": make-settings, configure-settings, resolve-colors
#import "shared.typ": fail, reject-unknown-keys
#import "color-defaults.typ": default-colors
#import "layout-config.typ": standard-layouts, validate-layouts

#let text-element = text
#let heading-element = heading

// Private setup engine. Public and themed facades supply an exact options
// dictionary and private semantic colors; no color registry enters the API.
#let setup-core(options, body, colors: default-colors) = {
  if type(options) != dictionary {
    fail("internal setup options must be a dictionary; got " + repr(type(options)))
  }
  let defaults = (
    paper: "16-9",
    spacing: (:),
    overflow: "warn",
    layouts: standard-layouts,
    handout: false,
    output: "slides",
    frozen-counters: (),
    frozen-states: (),

    title: none,
    subtitle: none,
    authors: (),
    date: none,
    colors: (:),
    content: (:),
  )
  if type(defaults) != dictionary {
    fail("internal setup defaults must be a dictionary; got " + repr(type(defaults)))
  }
  reject-unknown-keys(options, defaults, "setup")
  let options = defaults + options
  let paper = options.paper
  let spacing = options.spacing
  let overflow = options.overflow
  let layouts = validate-layouts(options.layouts)
  let handout = options.handout
  let output = options.output
  let frozen-counters = options.frozen-counters
  let frozen-states = options.frozen-states

  let colors = resolve-colors(colors, options.colors)
  if type(options.content) != dictionary {
    fail("setup content must be a dictionary")
  }
  let content = (header: none) + options.content
  let deck = (
    title: options.title,
    subtitle: options.subtitle,
    authors: options.authors,
    date: options.date,
  )
  let paper-presets = (
    "16-9": "presentation-16-9",
    "4-3": "presentation-4-3",
  )
  if type(paper) != str or paper not in paper-presets {
    fail("setup paper must be \"16-9\" or \"4-3\"")
  }

  if output not in ("slides", "speaker", "notes") {
    fail("setup output must be \"slides\", \"speaker\", or \"notes\"")
  }
  let settings = make-settings(
    colors: colors,
    content: content,
    deck: deck,
    spacing: spacing,
    overflow: overflow,
  )
  let page-options = if output == "slides" {
    (
      paper: paper-presets.at(paper),
      margin: 0pt,
      fill: colors.canvas,
    )
  } else {
    (
      paper: "a4",
      margin: 15mm,
      fill: white,
    )
  }
  set page(..page-options)
  let document-authors = if settings.deck.authors.all(author => type(author.name) == str) {
    settings.deck.authors.map(author => author.name)
  } else {
    ()
  }
  set document(title: settings.deck.title, author: document-authors)
  set text-element(..settings.type.body)
  show heading-element.where(depth: 1): set text-element(..settings.type.title)
  show heading-element.where(depth: 2): set text-element(..settings.type.heading)
  show figure.caption: set text-element(..settings.type.caption)
  show heading-element: set block(below: settings.spacing.heading-below)
  set list(spacing: settings.spacing.list-spacing)
  set enum(spacing: settings.spacing.list-spacing)
  set terms(spacing: settings.spacing.list-spacing)
  // Canonical cell typography and arrangement. Every rendered cell is one
  // block labeled <mosaic-cell-ID>, so defaults for the canonical cell
  // vocabulary are ordinary label-targeted rules. Rules defined later (in a
  // themed setup, rules after `#show: setup`, or rules scoped around one
  // slide command) sit inside these and therefore win.
  show label("mosaic-cell-section"): set align(center + horizon)
  show label("mosaic-cell-section"): set text-element(..settings.type.title)
  show label("mosaic-cell-footer"): set text-element(..settings.type.small)
  show label("mosaic-cell-title"): set text-element(
    ..(settings.type.title + (size: 2em, tracking: -0.015em)),
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-authors"): set text-element(
    size: 0.8em,
    weight: "medium",
  )
  show label("mosaic-cell-details"): set text-element(..settings.type.small)
  configure-settings(settings)
  [#metadata(settings.deck) <mosaic-deck-metadata>]
  configure-deck(
    layouts: layouts,
    frozen-counters: frozen-counters,
    frozen-states: frozen-states,
    handout: handout,
    output: output,
    paper: paper,
  )
  compile-deck(body)
}
