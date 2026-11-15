// Construction, validation, and resolution of the title layout.
#import "../shared.typ": fail, key
#import "../deck-state.typ": logical-slide-id
#import "../author.typ": analyze-authors, resolve-authors
#import "../grid/constructors.typ": make-cell, columns, rows, track
#import "core.typ": (
  make-layout,
  validate-accent,
  validate-variant,
)
#import "support.typ": (
  adapt-fill,
  content-or-empty,
  as-content,
  fixed-cell,
)
#import "image-support.typ": (
  directional-image-layout,
  directional-positions,
  image-background-cell,
  image-cell,
  optional-fixed-image,
  resolve-image-position,
  validate-image-fields,
)
#import "../incremental/heading.typ": is-canonical-frame
#import "../fit.typ": fit-ratio, reflow-scale, is-unsolvable

#let variants = (
  "academic",
  "centered",
  "bordered",
  "ruled",
  "kicker",
  "panel",
  "image",
)

// The message for a title slide with no title to show: `auto` found nothing
// on `setup`, or the field was written empty. Suppressing the title is a
// different act with its own spelling, which the message names.
#let missing-title = (
  "layout \"title\" requires title content through title: or setup(title: ..); "
    + "pass title: none to compose the slide without one"
)

#let validate-fields(fields, allow-auto: false) = {
  let fields = validate-accent(fields, "title", allow-auto: allow-auto)
  let variant = validate-variant(fields.variant, variants, "layout \"title\"")
  // `none` suppresses a field, the title included. What stays an error is the
  // mistake: something that is neither text nor `none`, or text with nothing
  // in it.
  if (
    fields.title != none
      and (type(fields.title) not in (content, str) or fields.title in ("", []))
      and not (allow-auto and fields.title == auto)
  ) {
    fail(missing-title)
  }
  for name in ("subtitle", "date") {
    let value = fields.at(name)
    if value != none and type(value) not in (content, str) and not (allow-auto and value == auto) {
      fail("layout \"title\" " + name + " must be content, a string, none, or auto")
    }
  }
  if fields.rule != auto and type(fields.rule) != bool {
    fail("layout \"title\" rule must be auto, true, or false")
  }
  // Names become records here, so every renderer below reads one shape and the
  // `academic` count below is a count of authors rather than of spellings.
  // `none` resolves to the empty list, the same suppression as `()`.
  if not (allow-auto and fields.authors == auto) {
    fields.authors = resolve-authors(
      fields.authors,
      name: "layout \"title\" author",
    )
  }
  let fields = validate-image-fields(fields, "layout \"title\"")
  if variant == "academic" {
    if type(fields.authors) == array and fields.authors.len() == 0 {
      fail("layout \"title\" variant " + repr(variant) + " requires at least one author")
    }
  }
  fields
}

/// Creates a presentation title grid.
///
/// The layout supplies every cell's content itself, so the surrounding
/// `mosaic.slide` consumes no slide bodies.
///
/// ```typ
/// #show: mosaic.setup.with(
///   title: [Tree-based slide grids],
///   subtitle: [A layout model for Typst],
///   authors: [Ada Lovelace],
///   date: [2026-08-03],
/// )
///
/// #mosaic.slide(layout: "title", variant: "centered")
/// ```
///
/// *Inheritance*
///
/// Each of `title`, `subtitle`, `authors`, and `date` defaults to `auto`, which
/// takes the value configured on `setup`. To override an inherited value:
///
/// - Pass explicit content or a string to replace it.
/// - Pass `none` to suppress it. This works for all four fields; `authors`
///   also accepts the empty array `()`, which means the same.
///
/// A slide with its title suppressed still composes: the details alone, or
/// the picture alone. What fails is a title slide with no title to inherit,
/// that is `title: auto` on a deck whose `setup` declares none, because that
/// is an omission rather than a choice.
///
/// *Variants*
///
/// Text variants:
///
/// - `centered`: the heading stack at the slide's center, details anchored to
///   the bottom edge. `rule: true` adds a short accent rule under the heading.
/// - `bordered`: a thin rule border inset from the slide edge with the
///   centered stack inside it.
/// - `ruled`: the heading stack over a full-width accent rule with the
///   details beneath, flush left at the slide's vertical center. The
///   beamer-metropolis title page, and the default.
/// - `kicker`: the magazine masthead. A strong opening rule, the subtitle set
///   as a small tracked-caps eyebrow in the accent color, the title below it,
///   and the details anchored to the bottom edge.
/// - `panel`: a vertical side panel in the deck's text color carries the
///   details, knocked out in the canvas color under a short accent rule; the
///   heading stack takes the main field. A slide with no authors and no date
///   has nothing to put in the panel and draws the heading stack alone.
/// - `academic`: the conference-poster arrangement. A short accent rule
///   closes the heading stack, and author names carry superscript affiliation
///   numbers over a numbered affiliation legend and a contact line. Requires
///   at least one author.
///
/// One variant carries a picture:
///
/// - `image`: the compact title stack with a picture, placed by `position`.
///   Requires `image`, and is the only variant that takes one: write
///   `variant: "image"` together with `image:`.
///
/// Every variant states its own arrangement, as described above; unlike the
/// `plain` section, none leaves the placement of its stack to the theme. The
/// theme decides the type: the display size on `<mosaic-title-display>` and
/// the typography of the cell.
///
/// *Pictures*
///
/// `variant` names the text design and `position` names the picture's place,
/// in the vocabulary every layout with a picture shares:
///
/// - `"left"`, `"right"`, `"top"`, `"bottom"`: a full-bleed picture beside or
///   above the title stack, sized by `tracks`. `auto` means `"left"`.
/// - `"background"`: the title stack at the lower left, directly over a
///   full-slide picture. The type keeps the deck's text color, so quiet the
///   photograph with a scrim and recolor the cell as shown under *Styling*.
///
/// *Long titles*
///
/// Title metadata cannot be cut, so no variant lets it collide. The details
/// grow to a share of the slide and then scale down to hold it, and the
/// heading stack scales down in turn once it outgrows the room the details
/// leave, so a long title over a long author list shrinks rather than
/// overprinting. A stack scaled to fit does fit, so `setup(overflow: ..)`
/// does not report it.
///
/// To invert any of these, with the slide ground in the deck's text color and
/// the type knocked out, pass `invert: true` on the slide rather than picking
/// a variant; inversion is a polarity, not a structure.
///
/// *Authors*
///
/// Every variant accepts the same `authors`, written in whichever of three
/// spellings fits the deck: one name as content or a string, an array of
/// names, or an array of records built with `layouts.author` for the authors
/// that carry affiliations, an ORCID iD, or an address. Names and records mix
/// freely in one array. Every variant renders every author field through the
/// same tiers: a byline of names with linked ORCID labels, superscript
/// affiliation numbers, and the corresponding asterisk, then one fine-print
/// line per kind of information: the numbered affiliation legend, the contact
/// addresses, the date. Kinds never share a line, and the superscript markers
/// appear exactly when the deck names more than one institution.
///
/// *Labels*
///
/// Every resolved cell carries a label, so appearance comes from native Typst
/// rules:
///
/// - `mosaic-cell-title`: the title stack, in every variant. Most variants
///   compose the subtitle and the details inside it too.
/// - `mosaic-cell-details`: the affiliation and date band, in the `panel` and
///   `academic` variants, which set those tiers outside the title cell.
/// - `mosaic-cell-authors`: the byline, in the `academic` variant.
/// - `mosaic-cell-image`: the picture, in the `image` variant at the four
///   directional positions. At `"background"` the picture is the title cell's
///   background instead, so it has no image cell of its own.
///
/// One further label is not a cell: the display line of the title stack carries
/// `mosaic-title-display`, which is where a theme states the title's display
/// size.
///
/// *Styling*
///
/// The layout is structural. A rule on `<mosaic-cell-title>` reaches the whole
/// composed stack: title, subtitle, and details alike. Recoloring it is what
/// light-on-dark compositions over a photograph need.
///
/// ```typ
/// #show label("mosaic-cell-title"): set text(fill: white)
/// #mosaic.slide(
///   layout: "title",
///   variant: "image",
///   position: "background",
///   image: mosaic.components.image(
///     path("cover.webp"),
///     scrim: black.transparentize(55%),
///   ),
/// )
/// ```
///
/// Sizing it works the same way, because the display line carries its own
/// `<mosaic-title-display>` label and the theme's display size lands there
/// rather than on the cell. The tiers below are ordinary ems of the cell, so
/// one rule scales the stack as a unit and the proportions hold. That is how
/// to ask for quiet type in the corner of a photograph.
///
/// ```typ
/// #show label("mosaic-cell-title"): set text(size: 0.45em)
/// ```
///
/// A theme states the display size on the inner label instead, which leaves
/// the outer one free for the deck to scale:
///
/// ```typ
/// #show label("mosaic-title-display"): set text(size: 2em, weight: "semibold")
/// ```
///
/// -> dictionary
#let title(
  /// Title text. `auto` inherits `setup(title:)` and fails when there is
  /// none to inherit; `none` suppresses the title on this slide.
  /// -> auto | content | str | none
  title: auto,
  /// Subtitle set tight below the title. `auto` inherits `setup(subtitle:)`;
  /// `none` suppresses it.
  /// -> auto | content | str | none
  subtitle: auto,
  /// Display date joined into the fine-print details line. `auto` inherits
  /// `setup(date:)`; `none` suppresses it.
  /// -> auto | content | str | none
  date: auto,
  /// The picture of the `image` variant, required there and rejected by the
  /// others. Give a native `path(..)` value, which fills its region, or
  /// ready-made content such as
  /// `components.image(path("cover.webp"), scrim: black.transparentize(55%))`,
  /// whose `scrim` quiets the photograph enough to read text over it. A bare
  /// string is rejected: it would resolve inside the package rather than in
  /// the deck's project.
  /// -> none | content | path
  image: none,
  /// The text design: `ruled`, `centered`, `bordered`, `kicker`, `panel`,
  /// `academic`, or `image`.
  /// -> str
  variant: "ruled",
  /// Where the `image` variant's picture sits, and rejected by the others:
  /// `"left"`, `"right"`, `"top"`, `"bottom"`, or `"background"`. `auto`
  /// means `"left"`.
  /// -> auto | str
  position: auto,
  /// One name, or an array of names and records created with
  /// `layouts.author`. `auto` inherits `setup(authors:)`; `none` or `()`
  /// suppresses an inherited list.
  /// -> auto | content | str | array | none
  authors: auto,
  /// Sizes the split of a directional position, and is rejected elsewhere.
  /// One native Typst track size sizes the picture and is side-independent, so
  /// the `left` and `right` positions stay mirror images; the title region
  /// takes the remaining `1fr`. An array of two is in visual order instead,
  /// and must be mirrored by hand when the position flips. `auto` gives the
  /// picture the smaller share.
  /// -> auto | length | ratio | relative | fraction | array
  tracks: auto,
  /// Whether to draw the variant's mark: the `ruled` full-width rule, the
  /// `bordered` border, the `kicker` opening rule, or the short accent rule
  /// that closes the heading stack of the `academic`, `centered`, and `image`
  /// variants and opens the `panel`. `auto` draws the mark everywhere except
  /// on `centered` and `image`, which stay bare unless asked: the first is
  /// the plain composition, and on the second the photograph already does
  /// that work. `false` removes the mark in every variant.
  /// -> auto | bool
  rule: auto,
  /// Color of the variant's mark. `auto` uses the deck's text color for the
  /// `bordered` border and the `kicker` opening rule, and the semantic accent
  /// everywhere else: the `ruled` rule, the `panel` rule, the `kicker`
  /// eyebrow, and the short rule of `academic`, `centered`, and `image`. The
  /// color belongs to the mark, so where `rule` leaves the mark undrawn there
  /// is nothing for it to reach.
  /// -> color | auto
  accent: auto,
) = {
  let fields = validate-fields((
    title: title,
    subtitle: subtitle,
    date: date,
    image: image,
    variant: variant,
    position: position,
    authors: authors,
    tracks: tracks,
    rule: rule,
    accent: accent,
  ), allow-auto: true)
  make-layout("title", fields)
}

// The title layout's visual recipe, in one place.
//
// Like the section variants, a title is a composition: it interleaves type
// tiers with explicit spacers, rules, and offsets that no show rule can reach.
// The measurements live here as named internal constants rather than as
// literals spread through the variants. They are design decisions, not API:
// a deck that wants different geometry draws its own layout.
//
// The `-scale` fields multiply the title cell's own em, and the `-gap` fields
// multiply `settings.spacing.gap`, which is em-typed too. Both therefore
// resolve against the cell, which the theme holds at the deck's body size: the
// display size lives on the <mosaic-title-display> label inside the cell, so
// nothing here compounds with it and one `set text(size: ..)` on
// <mosaic-cell-title> resizes the stack as a unit. See title-display.
#let title-tokens = (
  // Tiers of the title stack.
  subtitle-scale: 1.05,
  details-scale: 0.75,
  byline-scale: 0.7,
  fine-print-scale: 0.62,
  // One leading for every details tier, in each variant that sets one.
  details-leading: 0.55em,
  // The accent rule that separates the heading stack from the details stack.
  accent-rule-length: 1.6,
  accent-rule-thickness: 0.12,
  // The hairline the band and card variants rule themselves with.
  accent-stroke-thickness: 0.04,
  // Vertical rhythm of the title stack, in multiples of the deck gap. The
  // stack separates display type, so its gaps are wider than a body gap: they
  // are stated here as their own numbers rather than inherited from the size
  // of whatever display scale a theme happens to set.
  subtitle-gap: 1.1,
  rule-gap: 2.6,
  details-gap-with-rule: 1.6,
  details-gap-without-rule: 2.6,
  // Author furniture.
  orcid-size: 0.9em,
  orcid-gap: 0.22em,
  affiliation-marker-gap: 0.2em,
  // Display scales for the variants that set their heading stack smaller.
  card-title-scale: 0.9em,
  academic-scale: 0.8em,
  image-title-scale: 0.85em,
  // The card's ground and its inner cell.
  card-inset: 1.2,
  card-outer-inset: 0.6,
  // How far a knocked-out subordinate tier lightens toward the ground.
  scrim-opacity: 30%,
  // The image/text split of a directional image title, in visual order for a
  // left- or top-positioned picture; mirrored for the other side.
  image-tracks: (2fr, 3fr),
  // The kicker masthead: the opening rule's weight, the eyebrow's letterform
  // (scale and tracking in the cell's em), and the gaps that separate rule,
  // eyebrow, and title.
  kicker-rule-thickness: 0.14,
  kicker-scale: 0.6,
  kicker-tracking: 0.14,
  kicker-rule-gap: 1.6,
  kicker-title-gap: 1.4,
  // The panel variant: the share of the slide the details panel takes, and
  // the factor its details type grows past the fine-print scales. The panel
  // is the details' own field rather than a footnote band, so its type reads
  // at nearly body size instead of fine print.
  panel-track: 30%,
  panel-details-scale: 1.15,
  // How much of its region a details box may claim before it stops growing
  // and starts scaling its content down (see capped-fit): a share of the
  // slide for the tiers that sit beside or below a heading, most of the
  // panel's column, and the whole region for the image compositions, whose
  // bounds the photograph already fixes.
  details-cap: 40%,
  panel-details-cap: 65%,
  stack-cap: 100%,
)

// The display line of the title stack carries its own <mosaic-title-display>
// label, and the theme's display size lands there rather than on the cell.
// The cell therefore stays at the deck's body size, which is what lets every
// subordinate tier below be an ordinary em multiple: nothing compounds with
// the display size, and one native `set text(size: ..)` on
// <mosaic-cell-title> scales title, subtitle, and details alike instead of
// moving the display line past its own subtitle.
//
// The display line is a level-one heading, so a tagged PDF opens its heading
// tree at H1 on the cover and a deck of `==` slides never skips a level.
// `outlined: false` keeps it out of the outline and the bookmarks, so no
// deck's navigation changes. Every theme states level-one heading typography
// through show-set rules, and Typst's native heading scale sits inside those;
// both would compound with the display size the label rule states on the
// block around them. The scoped rule below therefore replaces the heading
// with its body at the text style captured just outside it, which is the
// style the label rule resolved to. The heading stays realized exactly once
// per logical slide, keeping its structure tag, and every frame of the slide
// sets the same text; see title-text in section.typ for the same treatment
// on section slides.
#let title-display(body) = {
  let display = block(width: 100%, above: 0pt, below: 0pt, {
    if body == none or body == [] {
      body
    } else {
      // Captured outside the heading: inside it, the theme's heading rules
      // have already applied. The family is not restated: Typst warns per
      // source span that names an unknown family, so repeating the chain
      // here would report a missing designed face a second time, and no
      // bundled theme gives headings a face the display line lacks.
      context {
        let style = (
          style: text.style,
          weight: text.weight,
          stretch: text.stretch,
          size: text.size,
          fill: text.fill,
          tracking: text.tracking,
          spacing: text.spacing,
        )
        // One real heading per logical slide. A slide with several frames
        // renders this cell once per frame, and the heading is built here,
        // inside `context`, where the incremental walk that keeps automatic
        // headings to their canonical frame cannot see it. So the display
        // line asks the same question itself: the canonical frame carries
        // the element, and every other frame sets the same text without it.
        // Both branches end in `text(..style, ..)`, so the frames match.
        if is-canonical-frame() {
          show heading: it => text(..style, it.body)
          heading(level: 1, outlined: false, body)
        } else {
          text(..style, body)
        }
      }
    }
  })
  [#display#label("mosaic-title-display")]
}

// Subordinate tiers of the composed title stack, as em multiples of the cell.
//
// Their muted `fill` survives only while the cell carries the deck's ordinary
// text color; see `adapt-fill`. That is what lets one rule on
// <mosaic-cell-title> recolor the whole stack for a light-on-dark
// composition, which is the case the image variant exists to serve.
#let title-styles(settings) = (
  subtitle: (
    fill: settings.colors.muted,
    size: settings.title-tokens.subtitle-scale * 1em,
  ),
  details: (
    fill: settings.colors.muted,
    size: settings.title-tokens.details-scale * 1em,
  ),
)

#let title-inset(settings, top: 0pt, bottom: 0pt) = (
  top: top,
  right: settings.spacing.inset,
  bottom: bottom,
  left: settings.spacing.inset,
)

// The region a title fitter was really given, remembered so that a measurement
// can be answered truthfully.
//
// Every fitter below solves against the region its `layout` callback
// receives. Under `measure` that region is unbounded in height: Typst hands a
// measured body no allocation, whatever cell it will be placed in. A fitter
// that answered with its unfitted body there would make the overflow observer
// report a slide that renders correctly, and one that answered with nothing
// would measure as zero for every other reader. The honest answer is the size
// the content takes once placed, and the only way to know it under `measure`
// is to have recorded it when it was placed.
//
// So the placed pass writes the height it was offered to a state keyed by the
// logical slide and by `slot`, which names the fitter within the slide, and
// the measuring pass reads the final value back and fits against it. Content
// that was never placed has no record and measures at its natural size, which
// is what an unbounded region means. The record depends on the region alone,
// never on what a measurement returned, so reading it converges in one extra
// layout iteration.
//
// `render` receives the region to fit against, or `none` when there is none
// and the natural form is the answer. `slot: none` is a fitter nested inside
// another: the outer one measures it, wants its natural size, and does the
// fitting itself.
#let allocation(slot) = state(
  key("title-allocation:" + slot + ":" + str(logical-slide-id.get().first())),
  none,
)

#let in-allocation(slot, render) = layout(region => {
  if not is-unsolvable(region.width) and not is-unsolvable(region.height) {
    if slot != none {
      allocation(slot).update(_ => region.height)
    }
    render(region)
  } else if slot == none or is-unsolvable(region.width) {
    render(none)
  } else {
    let height = allocation(slot).final()
    render(if height == none { none } else { (width: region.width, height: height) })
  }
})

// Auto-then-fit: the block takes its natural height while that stays within
// `cap` of the surrounding region, and past the cap it scales down
// geometrically to hold it, with the same measurement the fitters in fit.typ
// use. Title metadata is the one slide content an author cannot cut, so its
// box grows like an auto track up to the cap and then compresses instead of
// colliding with the tier above it. See in-allocation for `slot`.
#let capped-fit(body, cap, slot: none) = in-allocation(slot, region => {
  if region == none {
    return body
  }
  let natural = measure(body, width: region.width)
  let limit = cap * region.height
  if natural.height <= limit {
    return body
  }
  reflow-scale(fit-ratio(natural, height: limit), body)
})

// The cell carries the deck's body size and the stack's shared typography
// through its <mosaic-cell-title> rules; the display size lives on the
// <mosaic-title-display> label inside it. A variant that wants a quieter
// composition therefore reduces the cell's em and every tier follows. The
// bottom-left anchor is variant semantics: pick another variant to change it.
#let title-body-cell(
  settings,
  scale: 1em,
  content: none,
  bottom-inset: auto,
  cap: none,
) = make-cell(
  id: "title",
  content: align(
    left + bottom,
    {
      let body = if scale == 1em { content } else { text(size: scale, content) }
      if cap == none { body } else { capped-fit(body, cap, slot: "stack") }
    },
  ),
  style: (
    content-sized: false,
    inset: title-inset(
      settings,
      top: settings.spacing.inset,
      // Anchored compositions want real breathing room at the bottom edge.
      bottom: if bottom-inset == auto { settings.spacing.inset } else { bottom-inset },
    ),
  ),
)

#let academic-small-cell(body, id, settings, bottom: auto) = fixed-cell(
  body,
  id,
  settings,
  inset: title-inset(
    settings,
    bottom: if bottom == auto { settings.spacing.compact-gap } else { bottom },
  ),
)

// Code blocks, not markup blocks: markup newlines become spaces, which would
// leak into joined lists as stray gaps before separators.
#let orcid-link(author, settings) = if author.orcid != none {
  let size = settings.title-tokens.orcid-size
  box(width: settings.title-tokens.orcid-gap)
  box(
    link(
      "https://orcid.org/" + author.orcid,
      image(
        "../../assets/orcid.svg",
        height: size,
        alt: "ORCID profile for " + repr(author.name),
      ),
    ),
  )
}

// One byline entry: the name, the linked ORCID icon, the superscript
// affiliation numbers when the deck carries more than one institution, and
// the corresponding asterisk.
#let author-entry(author, settings, numbered: false) = {
  as-content(author.name)
  orcid-link(author, settings)
  if numbered and author.numbers.len() > 0 {
    super(author.numbers.map(str).join([,]))
  }
  if author.corresponding { super[\*] }
}

// One legend entry: the superscript marker that ties an institution back to
// its authors, then the institution. A deck with a single institution needs
// no markers, so `numbered` drops them everywhere at once.
#let affiliation-entry(item, settings, numbered: true) = {
  if numbered {
    super(str(item.at(0) + 1))
    box(width: settings.title-tokens.affiliation-marker-gap)
  }
  as-content(item.at(1))
}

// One contact entry: the corresponding marker, then the linked address. The
// caller filters on email, so it is always present here.
#let contact-entry(author, settings) = {
  if author.corresponding {
    [\*]
    box(width: settings.title-tokens.affiliation-marker-gap)
  }
  link("mailto:" + author.email, author.email)
}

// The details pieces every composed variant arranges: the byline entries
// (name, ORCID link, affiliation numbers, corresponding asterisk), the
// numbered affiliation legend, the contact addresses, and the display date.
// This record is the field contract: every variant renders every part, and
// only the arrangement is the variant's own. A variant that drops a part
// drops an author's information on the floor, which is exactly what the
// coverage tests refuse.
//
// The relationship structure is the same in every variant: authors carry
// superscript numbers exactly when the deck names more than one institution,
// and the legend repeats those numbers. One institution needs no markers.
#let details-parts(fields, settings) = {
  let analyzed = analyze-authors(fields.authors)
  let numbered = analyzed.affiliations.len() > 1
  (
    names: analyzed.authors.map(author => author-entry(
      author,
      settings,
      numbered: numbered,
    )),
    affiliations: analyzed.affiliations
      .enumerate()
      .map(item => affiliation-entry(item, settings, numbered: numbered)),
    contacts: analyzed.authors
      .filter(author => author.email != none)
      .map(author => contact-entry(author, settings)),
    date: if fields.date == none { none } else { as-content(fields.date) },
  )
}

#let has-details(parts) = (
  parts.names.len() > 0
    or parts.affiliations.len() > 0
    or parts.contacts.len() > 0
    or parts.date != none
)

// The fine-print tiers beneath the byline, one line per kind of information:
// the affiliation legend, the contact addresses, the date. Entries of one
// kind join on a line with a middle dot; kinds never share a line, which is
// what keeps a wrapped legend from running into an address or a date.
#let fine-print-lines(parts) = {
  (
    parts.affiliations,
    parts.contacts,
    if parts.date == none { () } else { (parts.date,) },
  )
    .filter(tier => tier.len() > 0)
    .map(tier => tier.join([ · ]))
}

// Narrow containers (the panel, the image side columns) set one entry
// per line instead of dot-joined kind lines: a wrapped entry would dangle its
// superscript marker at a line end. Kinds keep their order, so the grouping
// survives the tighter measure.
#let fine-print-column(parts) = {
  let entries = parts.affiliations + parts.contacts
  if parts.date != none {
    entries.push(parts.date)
  }
  entries
}

// The compact stack serves the image compositions, and `narrow` states which
// measure it renders into. A side column sets every entry on its own line
// like the other narrow containers; a full-width band joins the byline with
// commas and gives each kind of fine print one line.
#let ordinary-title-details(fields, settings, narrow: true) = {
  let parts = details-parts(fields, settings)
  if not has-details(parts) {
    return none
  }
  if narrow {
    return (parts.names + fine-print-column(parts)).join(linebreak())
  }
  let lines = ()
  if parts.names.len() > 0 {
    lines.push(parts.names.join([, ]))
  }
  lines += fine-print-lines(parts)
  lines.join(linebreak())
}

// Short accent-colored rule: the one non-text gesture shared by every title
// variant. Sized in the stack's own em, which the cell holds at the deck's
// body size, so the rule keeps its proportion when a rule on
// <mosaic-cell-title> resizes the whole stack.
#let accent-rule(accent, settings, above: 0pt) = block(
  above: above,
  line(
    length: settings.title-tokens.accent-rule-length * 1em,
    stroke: (
      paint: accent,
      thickness: settings.title-tokens.accent-rule-thickness * 1em,
      cap: "round",
    ),
  ),
)

// Title and subtitle only: the heavy block of the page, without the details
// or the accent rule of the compact stack.
//
// Either tier may be suppressed. The stack is always content, so a caller can
// scale, align, or measure it without asking whether anything is in it.
#let heading-stack(fields, settings) = content-or-empty({
  if fields.title != none {
    title-display(as-content(fields.title))
  }
  if fields.subtitle != none {
    block(
      above: settings.title-tokens.subtitle-gap * settings.spacing.gap,
      // Contextual because `adapt-fill` reads the live text fill.
      context {
        let styles = title-styles(settings).subtitle
        text(..adapt-fill(styles, settings), fields.subtitle)
      },
    )
  }
})

// The rule and details below the heading stack of the compact composition.
#let title-stack-tail(
  fields,
  settings,
  include-details: true,
  narrow: true,
) = {
  let details = if include-details {
    ordinary-title-details(fields, settings, narrow: narrow)
  } else {
    none
  }
  // The auto default gives the looks variety: the accent rule anchors the
  // text variants, while the image variant stays purely photographic.
  let show-rule = if fields.rule == auto {
    fields.variant != "image"
  } else {
    fields.rule
  }
  let after = {
    // A deliberate break, marked by the accent rule, separates the heading
    // stack from the details stack. Without the rule, extra space marks the
    // same break.
    if show-rule {
      accent-rule(
        fields.accent,
        settings,
        above: settings.title-tokens.rule-gap * settings.spacing.gap,
      )
    }
    if details != none {
      block(
        above: if show-rule {
          settings.title-tokens.details-gap-with-rule
        } else {
          settings.title-tokens.details-gap-without-rule
        } * settings.spacing.gap,
        {
          set par(leading: settings.title-tokens.details-leading)
          // The muted fill yields to the cell's text fill once a rule sets
          // one, so label-targeted color overrides reach the whole stack.
          context text(
            ..adapt-fill(title-styles(settings).details, settings),
            details,
          )
        },
      )
    }
  }
  content-or-empty(after)
}

// The complete fixed content of the title cell: the heading stack followed by
// the rule and details tail.
#let title-stack-content(
  fields,
  settings,
  include-details: true,
  narrow: true,
) = {
  heading-stack(fields, settings)
  title-stack-tail(
    fields,
    settings,
    include-details: include-details,
    narrow: narrow,
  )
}

#let title-stack(
  fields,
  settings,
  scale: 1em,
  narrow: true,
  cap: none,
) = title-body-cell(
  settings,
  scale: scale,
  content: title-stack-content(fields, settings, narrow: narrow),
  cap: cap,
)

// ---------------------------------------------------------------------------
// Shared pieces for the composed text variants.
//
// Each variant separates two stacks: the heading stack (title + subtitle) and
// a details stack (byline, affiliations, contacts, date). The details
// builders take explicit text and muted fills because every variant knows its
// own backdrop: the canvas for ruled and centered, the deck text color for
// the panel variant's side panel.

// Byline and fine-print typography for the details tiers. The scales are one
// table; `unit` is what they multiply, and it is the whole difference between
// the two places details renders. Composed inside the title cell, the tiers
// take the cell's own em (the default), so they follow the rest of the stack
// when a rule rescales it; see title-display. The panel and academic bands
// are their own <mosaic-cell-details> cells instead, so they pass the deck's
// base size and stay anchored to the body type, answering to a rule on their
// own cell and not to the title's scale.
#let details-styles(settings, unit: 1em) = (
  byline: (size: settings.title-tokens.byline-scale * unit, weight: "medium"),
  fine: (size: settings.title-tokens.fine-print-scale * unit),
)

// A tiered centered or left-aligned details stack: the byline in the deck ink,
// then one fine-print line per kind of information beneath it. Contextual
// because `adapt-fill` reads the live text fill: the tiers yield their fills to
// a recolored cell (see adapt-fill), which keeps the one-rule light-on-dark
// contract for single-cell variants. The panel variant draws its own
// self-colored ground through `panel-details` instead of this stack.
#let details-stack(parts, settings) = context {
  let type-scale = details-styles(settings)
  let ink-style = adapt-fill(
    type-scale.byline + (fill: settings.colors.text),
    settings,
  )
  let muted-style = adapt-fill(
    type-scale.fine + (fill: settings.colors.muted),
    settings,
  )
  let fine = fine-print-lines(parts)
  set par(leading: settings.title-tokens.details-leading)
  if parts.names.len() > 0 {
    text(..ink-style, parts.names.join([, ]))
  }
  if fine.len() > 0 {
    if parts.names.len() > 0 { linebreak() }
    text(..muted-style, fine.join(linebreak()))
  }
}

// A heading stack that shrinks to its allocation instead of overprinting
// whatever sits below it. Ordinary titles are far inside the region and come
// back untouched, so this costs a measurement and changes nothing; only a
// title that outgrows the room its variant gives it scales down.
#let apply-stack-fit(body, settings, slot: "stack") = capped-fit(
  body,
  settings.title-tokens.stack-cap,
  slot: slot,
)

// The two-tier composition of the variants that anchor their details to the
// bottom edge (centered, kicker): the details are measured and capped first,
// the same arithmetic as capped-fit, and the heading takes the region they
// leave clear. Neither tier can reach the other however long the author list
// or the title grows. `heading` receives nothing and is laid out in a block of
// exactly the clear height, so it is the caller's to align and fit.
//
// Under `measure` the composition divides the region it was placed in (see
// in-allocation), so it measures as what it occupies. Never placed, it has no
// region to divide and the two tiers come back stacked at their natural size.
//
// `pinned` places the heading region at the top edge outright. A theme may
// align the title cell on the horizon, and that alignment reaches every block
// in the cell: it is how the centered heading region has always been placed,
// but it would slide a top-anchored masthead down the slide.
#let heading-over-details(
  heading,
  parts,
  settings,
  anchor: center,
  pinned: false,
) = in-allocation("composition", region => {
  let details = align(anchor, details-stack(parts, settings))
  if region == none {
    return {
      heading
      v(settings.spacing.gap)
      details
    }
  }
  let natural = measure(details, width: region.width)
  let limit = settings.title-tokens.details-cap * region.height
  if natural.height > limit {
    details = reflow-scale(fit-ratio(natural, height: limit), details)
  }
  let reserved = calc.min(natural.height, limit) + settings.spacing.gap
  block(width: 100%, height: region.height, {
    place(bottom + anchor, details)
    let clear = block(width: 100%, height: region.height - reserved, heading)
    if pinned { place(top + left, clear) } else { clear }
  })
})

// The paint of a variant's structural mark: the deck's text color unless the
// author asked for an explicit accent.
#let rule-paint(fields, settings) = if fields.mark-accent != none {
  fields.mark-accent
} else {
  settings.colors.text
}

#let has-rule(fields) = if fields.rule == auto { true } else { fields.rule }

// ruled: the heading stack over a full-width accent rule with the details
// stacked beneath it, the whole block flush left at the slide's vertical
// center. The rule takes the semantic accent rather than the text color, and
// the shape is the classic beamer-metropolis title page.
#let resolve-ruled-title(fields, settings) = {
  let parts = details-parts(fields, settings)
  make-cell(
    id: "title",
    // The whole block is one fitted composition: the details cap themselves
    // first, and whatever still outgrows the cell scales as a unit, rule and
    // all, so the three tiers keep their order and their proportions.
    content: align(left + horizon, apply-stack-fit({
      heading-stack(fields, settings)
      if has-rule(fields) {
        block(
          above: settings.title-tokens.rule-gap * settings.spacing.gap,
          line(length: 100%, stroke: (
            paint: fields.accent,
            thickness: settings.title-tokens.accent-rule-thickness * 1em,
          )),
        )
      }
      if has-details(parts) {
        block(
          above: settings.title-tokens.details-gap-with-rule * settings.spacing.gap,
          capped-fit(
            details-stack(parts, settings),
            settings.title-tokens.details-cap,
          ),
        )
      }
    }, settings)),
    style: (inset: settings.spacing.inset),
  )
}

// centered: the heading stack at the slide's center, the details anchored to
// the bottom edge so the composition never reads as top-heavy. The variant is
// the plain one, so its short accent rule draws only on request.
#let centered-heading(fields, settings) = align(center + horizon, apply-stack-fit(slot: "heading", {
  set align(center)
  heading-stack(fields, settings)
  if fields.rule == true {
    accent-rule(
      fields.accent,
      settings,
      above: settings.title-tokens.rule-gap * settings.spacing.gap,
    )
  }
}, settings))

#let resolve-centered-title(fields, settings) = {
  let parts = details-parts(fields, settings)
  make-cell(
    id: "title",
    // The heading centers in the space the details leave clear rather than
    // in the whole cell; see heading-over-details.
    content: if not has-details(parts) {
      centered-heading(fields, settings)
    } else {
      heading-over-details(
        centered-heading(fields, settings),
        parts,
        settings,
      )
    },
    style: (inset: settings.spacing.inset),
  )
}

// kicker: the magazine masthead. A strong opening rule at the top edge, the
// subtitle set as a small tracked-caps eyebrow in the accent color, the title
// below it, and the details anchored to the bottom edge, all flush left.
//
// The opening rule spans the cell and is never scaled; a masthead that
// outgrows the room under it shrinks beneath the rule, which keeps its
// length and weight.
#let kicker-masthead(fields, settings) = {
  if fields.subtitle != none {
    block(
      below: settings.title-tokens.kicker-title-gap * settings.spacing.gap,
      text(
        size: settings.title-tokens.kicker-scale * 1em,
        weight: "semibold",
        tracking: settings.title-tokens.kicker-tracking * 1em,
        fill: fields.accent,
        upper(as-content(fields.subtitle)),
      ),
    )
  }
  if fields.title != none {
    title-display(as-content(fields.title))
  }
}

#let kicker-heading(fields, settings) = {
  let rule = if has-rule(fields) {
    block(
      below: settings.title-tokens.kicker-rule-gap * settings.spacing.gap,
      line(length: 100%, stroke: (
        paint: rule-paint(fields, settings),
        thickness: settings.title-tokens.kicker-rule-thickness * 1em,
      )),
    )
  }
  let masthead = content-or-empty(kicker-masthead(fields, settings))
  align(left + top, in-allocation("heading", region => {
    let whole = {
      rule
      masthead
    }
    if region == none {
      return whole
    }
    let natural = measure(whole, width: region.width)
    if natural.height <= region.height {
      return whole
    }
    // Everything the rule and its gap take is fixed; the masthead scales
    // into what is left.
    let scaled = measure(masthead, width: region.width)
    let fixed = natural.height - scaled.height
    let room = region.height - fixed
    if is-unsolvable(room) {
      return whole
    }
    rule
    block(reflow-scale(fit-ratio(scaled, height: room), masthead))
  }))
}

#let resolve-kicker-title(fields, settings) = {
  let parts = details-parts(fields, settings)
  make-cell(
    id: "title",
    content: if not has-details(parts) {
      kicker-heading(fields, settings)
    } else {
      heading-over-details(
        kicker-heading(fields, settings),
        parts,
        settings,
        anchor: left,
        pinned: true,
      )
    },
    style: (inset: settings.spacing.inset),
  )
}

// panel: a vertical side panel in the deck's text color carries the details,
// knocked out in the canvas color under a short accent rule; the heading
// stack takes the main field. The panel paints from the palette's own pair,
// so it holds its contrast under any palette and under slide inversion.
#let panel-details(parts, settings, ink, pale) = {
  let type-scale = details-styles(
    settings,
    unit: settings.title-tokens.panel-details-scale * 1em,
  )
  set par(leading: settings.title-tokens.details-leading)
  if parts.names.len() > 0 {
    block(text(..(type-scale.byline + (fill: ink)), parts.names.join(linebreak())))
  }
  let fine = fine-print-column(parts)
  if fine.len() > 0 {
    block(
      above: settings.spacing.gap,
      text(..(type-scale.fine + (fill: pale)), fine.join(linebreak())),
    )
  }
}

#let resolve-panel-title(fields, settings) = {
  let parts = details-parts(fields, settings)
  let pale = settings.colors.canvas.transparentize(settings.title-tokens.scrim-opacity)
  let panel = make-cell(
    id: "details",
    content: {
      set text(fill: settings.colors.canvas)
      // Themes pin link accents through show-set rules tuned for the canvas;
      // on the ink panel the knocked-out fine-print fill is the legible one.
      show link: set text(fill: pale)
      align(left + bottom, capped-fit(
        {
          if has-rule(fields) {
            accent-rule(fields.accent, settings)
          }
          block(
            above: settings.spacing.gap,
            panel-details(parts, settings, settings.colors.canvas, pale),
          )
        },
        settings.title-tokens.panel-details-cap,
        slot: "panel",
      ))
    },
    style: (
      content-sized: false,
      inset: settings.spacing.inset,
      fill: settings.colors.text,
    ),
  )
  let heading = title-body-cell(
    settings,
    content: heading-stack(fields, settings),
    cap: settings.title-tokens.stack-cap,
  )
  // A panel with nothing to carry would be an empty slab of ink under a lone
  // rule, so the heading takes the slide.
  if not has-details(parts) {
    return heading
  }
  columns(
    track(settings.title-tokens.panel-track, panel),
    track(1fr, heading),
  )
}

#let resolve-bordered-title(fields, settings) = {
  let parts = details-parts(fields, settings)
  make-cell(
    id: "title",
    // The frame takes the height of its region outright rather than `100%`.
    // The two are the same length once placed, but a relative height has
    // nothing to resolve against under `measure` and the frame would report
    // no height at all; see in-allocation.
    content: in-allocation("frame", region => block(
      width: 100%,
      height: if region == none { auto } else { region.height },
      stroke: if has-rule(fields) {
        (
          paint: rule-paint(fields, settings),
          thickness: settings.title-tokens.accent-stroke-thickness * settings.base-size,
        )
      } else {
        none
      },
      inset: settings.title-tokens.card-inset * settings.spacing.inset,
      // One centered composition: the heading stack and the details travel
      // together, so the whole text area sits at the horizon rather than the
      // heading alone centering while the details hug the frame's bottom.
      align(center + horizon, apply-stack-fit({
        set align(center)
        text(size: settings.title-tokens.card-title-scale, heading-stack(fields, settings))
        if has-details(parts) {
          block(
            above: settings.title-tokens.details-gap-without-rule * settings.spacing.gap,
            capped-fit(
              details-stack(parts, settings),
              settings.title-tokens.details-cap,
            ),
          )
        }
      }, settings)),
    )),
    style: (inset: settings.title-tokens.card-outer-inset * settings.spacing.inset),
  )
}

#let resolve-academic-title(fields, settings) = {
  // The poster arrangement reads the same tiered model as every other
  // variant; it only spreads the byline and the fine print over their own
  // cells beneath the heading stack.
  let parts = details-parts(fields, settings)
  let fine-lines = fine-print-lines(parts)
  let children = ()
  // The heading stack takes the flexible track and aligns to its bottom, so
  // the whole composition anchors to the lower edge of the slide.
  children.push(track(1fr, title-body-cell(
    settings,
    scale: settings.title-tokens.academic-scale,
    content: title-stack-content(
      fields,
      settings,
      include-details: false,
    ),
    bottom-inset: settings.spacing.gap,
    cap: settings.title-tokens.stack-cap,
  )))
  if parts.names.len() > 0 {
    children.push(track(
      auto,
      fixed-cell(
        capped-fit(
          parts.names.join([, ]),
          settings.title-tokens.details-cap,
          slot: "authors",
        ),
        "authors",
        settings,
        inset: title-inset(
          settings,
          top: settings.spacing.compact-gap,
          bottom: if fine-lines.len() > 0 {
            settings.spacing.compact-gap
          } else {
            settings.spacing.inset
          },
        ),
      ),
    ))
  }
  if fine-lines.len() > 0 {
    children.push(track(
      auto,
      academic-small-cell(
        capped-fit(
          fine-lines.join(linebreak()),
          settings.title-tokens.details-cap,
          slot: "details",
        ),
        "details",
        settings,
        bottom: settings.spacing.inset,
      ),
    ))
  }
  rows(..children)
}

// image: the compact stack with a picture. A directional position splits the
// slide between a full-bleed picture and the title region; `background` sets
// the same stack, at full measure, over a picture that fills the slide.
#let resolve-image-title(fields, image, position, settings) = {
  // A side column is a narrow measure; the top and bottom bands and the
  // background run the full slide width and take the wide arrangement.
  let stack = title-stack(
    fields,
    settings,
    scale: settings.title-tokens.image-title-scale,
    narrow: position in ("left", "right"),
    // The photograph fixes the text region's bounds, so the whole stack
    // shrinks rather than colliding once it outgrows them.
    cap: settings.title-tokens.stack-cap,
  )
  if position not in directional-positions {
    return image-background-cell(stack, image)
  }
  let tracks = if fields.tracks == auto {
    if position in ("left", "top") {
      settings.title-tokens.image-tracks
    } else {
      settings.title-tokens.image-tracks.rev()
    }
  } else {
    fields.tracks
  }
  directional-image-layout(
    position,
    image-cell(image),
    stack,
    tracks: tracks,
  )
}

#let resolve-title(command, settings) = {
  let inherited = command.fields
  // `auto` with nothing to inherit is an omission and fails; an explicit
  // `none` is a choice and composes the slide without a title.
  if inherited.title == auto and settings.deck.title == none {
    fail(missing-title)
  }
  let fields = validate-fields(inherited + (
    title: if inherited.title == auto { settings.deck.title } else { inherited.title },
    subtitle: if inherited.subtitle == auto { settings.deck.subtitle } else { inherited.subtitle },
    authors: if inherited.authors == auto { settings.deck.authors } else { inherited.authors },
    date: if inherited.date == auto { settings.deck.date } else { inherited.date },
    accent: if inherited.accent == auto { settings.colors.accent } else { inherited.accent },
  ))
  // Marked text variants default their structural rule to the deck's text
  // color; only an explicit accent recolors it. The resolved accent above
  // still feeds the short accent rule of the other variants.
  let fields = fields + (
    mark-accent: if inherited.accent == auto { none } else { inherited.accent },
  )
  let image = optional-fixed-image(fields.image, "layout \"title\" image")
  // The recipe rides on `settings`, which every helper below already receives,
  // so the measurements reach the whole composition without threading an extra
  // argument through seven variants.
  let settings = settings + (title-tokens: title-tokens)
  if fields.variant == "academic" {
    resolve-academic-title(fields, settings)
  } else if fields.variant == "centered" {
    resolve-centered-title(fields, settings)
  } else if fields.variant == "bordered" {
    resolve-bordered-title(fields, settings)
  } else if fields.variant == "ruled" {
    resolve-ruled-title(fields, settings)
  } else if fields.variant == "kicker" {
    resolve-kicker-title(fields, settings)
  } else if fields.variant == "panel" {
    resolve-panel-title(fields, settings)
  } else {
    resolve-image-title(
      fields,
      image,
      resolve-image-position(fields),
      settings,
    )
  }
}
