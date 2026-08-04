// Sane presentation defaults, applied as a document-wide show rule.
#import "slide/runtime.typ": configure-deck
#import "deck-compiler.typ": compile-deck
#import "grid/render.typ": overflow-report
#import "settings.typ": make-settings, configure-settings
#import "shared.typ": fail, reject-unknown-keys
#import "color-defaults.typ": default-colors
#import "layout/config.typ": standard-layouts, validate-layouts

// Every option `setup` accepts, with its default. This is the single list:
// `theme-engine` derives the set of theme-neutral option names from these keys
// rather than restating them.
#let setup-defaults = (
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
  content: (:),
)

// Private setup engine. The theme engine supplies an exact options dictionary
// and fully resolved semantic colors; no color registry enters the API.
#let setup-core(options, body, colors: default-colors) = {
  if type(options) != dictionary {
    fail("internal setup options must be a dictionary; got " + repr(type(options)))
  }
  let defaults = setup-defaults
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
    // No explicit fill: an `auto` page still prints white, and the slide
    // thumbnails read `page.fill == auto` as their cue to paint the deck's
    // canvas color inside the frame.
    (
      paper: "a4",
      margin: 15mm,
    )
  }
  set page(..page-options)
  let document-authors = if settings.deck.authors.all(author => type(author.name) == str) {
    settings.deck.authors.map(author => author.name)
  } else {
    ()
  }
  set document(title: settings.deck.title, author: document-authors)
  // No typography here by design. Every `set` and `show` rule a deck renders
  // with comes from the active theme's `apply`, including the rules that style
  // the canonical <mosaic-cell-*> vocabulary. This engine owns structure only:
  // page geometry, document metadata, deck configuration, and compilation.
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
  // Runs after the deck, where introspection has converged, so the diagnostic
  // can name the slide each clipped cell is on.
  if overflow == "error" {
    overflow-report()
  }
}
