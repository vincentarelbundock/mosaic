// Sane presentation defaults, applied as a document-wide show rule.
#import "slide/runtime.typ": configure-deck
#import "deck-compiler.typ": (
  compile-deck, default-heading-policy, validate-heading-policy,
)
#import "grid/render.typ": overflow-report
#import "settings.typ": make-settings
#import "shared.typ": fail, validate-keys
#import "color-defaults.typ": default-colors
#import "layout/config.typ": standard-layouts, validate-layouts
#import "paper.typ": default-paper, resolve-paper

// Every option `setup` accepts, with its default. This is the single list:
// `theme-engine` derives the set of theme-neutral option names from these keys
// rather than restating them.
#let default-setup = (
  paper: default-paper,
  margin: 0pt,
  spacing: (:),
  notes: (:),
  roles: auto,
  overflow: "warn",
  layouts: standard-layouts,
  headings: default-heading-policy,
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
  let defaults = default-setup
  _ = validate-keys(options, defaults, "setup")
  let options = defaults + options
  let paper = options.paper
  let spacing = options.spacing
  let notes = options.notes
  let roles = options.roles
  let overflow = options.overflow
  let layouts = validate-layouts(options.layouts)
  let headings = validate-heading-policy(options.headings)
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
  let paper-size = resolve-paper(paper)

  if output not in ("slides", "speaker", "notes") {
    fail("setup output must be \"slides\", \"speaker\", or \"notes\"")
  }
  let settings = make-settings(
    colors: colors,
    content: content,
    deck: deck,
    spacing: spacing,
    notes: notes,
    roles: roles,
    overflow: overflow,
  )
  let page-options = if output == "slides" {
    // A presentation canvas is edge to edge, so the margin defaults to zero and
    // the deck's inset does the spacing. A custom canvas can reclaim a real
    // page margin through `margin:`.
    (
      width: paper-size.width,
      height: paper-size.height,
      margin: options.margin,
      fill: colors.canvas,
    )
  } else {
    // No explicit fill: an `auto` page still prints white, and the slide
    // thumbnails read `page.fill == auto` as their cue to paint the deck's
    // canvas color inside the frame.
    (
      paper: "a4",
      margin: settings.notes.margin,
    )
  }
  set page(..page-options)
  let document-authors = if settings.deck.authors.all(author => type(author.name) == str) {
    settings.deck.authors.map(author => author.name)
  } else {
    ()
  }
  set document(title: settings.deck.title, author: document-authors)
  // No slide typography here by design. Every `set` and `show` rule a slide
  // renders with comes from the active theme's `apply`, including the rules
  // that style the canonical <mosaic-cell-*> vocabulary. This engine owns
  // structure only: page geometry, document metadata, the deck record, and
  // compilation.
  //
  // The one typographic exception is the pair of rules below for the printed
  // `speaker` and `notes` outputs. Those pages are paper, not slide canvas, so
  // their furniture must read black-on-white regardless of theme; the engine
  // states that neutral default on the note labels, and any later rule on the
  // same label (a theme's or the deck's) overrides it. The labels never occur
  // in the `slides` output, so the rules are inert there.
  show label("mosaic-note-heading"): set text(
    size: 12pt, weight: "bold", fill: black,
  )
  show label("mosaic-note-body"): set text(size: 10pt, fill: black)
  [#metadata(settings.deck) <mosaic-deck-metadata>]
  // The single write of the deck record: everything `setup` declares, stored
  // as one immutable value.
  configure-deck(
    settings: settings,
    layouts: layouts,
    frozen-counters: frozen-counters,
    frozen-states: frozen-states,
    handout: handout,
    output: output,
    paper: paper-size,
  )
  compile-deck(body, headings: headings)
  // Runs after the deck, where introspection has converged, so the diagnostic
  // can name the slide each clipped cell is on.
  if overflow == "error" {
    overflow-report()
  }
}
