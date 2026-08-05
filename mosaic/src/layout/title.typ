// Construction, validation, and resolution of the title layout.
#import "../shared.typ": fail
#import "../author.typ": analyze-authors
#import "../grid/constructors.typ": styled-cell, h, v, t
#import "core.typ": (
  make-layout,
  validate-accent,
  validate-image-spec,
)
#import "support.typ": (
  adapt-fill,
  content-or-empty,
  as-content,
  fixed-cell,
  inherit-fill,
)
#import "image-support.typ": (
  directional-image-layout,
  image-background-cell,
  image-cell,
  optional-fixed-image,
  semantic-directional-variants,
  semantic-image-position,
  semantic-image-variants,
  validate-directional-tracks,
  validate-semantic-image-use,
)

#let variants = (
  "academic",
  "swiss",
  "centered",
  "plate",
  "frame",
) + semantic-image-variants



#let stack-alignments = (
  left,
  center,
  right,
  left + top,
  left + horizon,
  left + bottom,
  center + top,
  center + horizon,
  center + bottom,
  right + top,
  right + horizon,
  right + bottom,
)

#let validate-fields(fields, allow-auto: false) = {
  let fields = validate-accent(fields, "title", allow-auto: allow-auto)
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "layout \"title\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  if type(fields.title) not in (content, str) and not (allow-auto and fields.title == auto) {
    fail("layout \"title\" requires title content through title:")
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
  if type(fields.authors) != array and not (allow-auto and fields.authors == auto) {
    fail("layout \"title\" authors must be an array")
  }
  if type(fields.authors) == array {
    _ = analyze-authors(fields.authors)
  }
  let fields = validate-semantic-image-use(fields, "layout \"title\"")
  if fields.image != none {
    _ = validate-image-spec(
      fields.image,
      "layout \"title\" image",
      allow-size: false,
    )
  }
  if variant == "academic" {
    if type(fields.authors) == array and fields.authors.len() == 0 {
      fail("layout \"title\" variant " + repr(variant) + " requires at least one author")
    }
  }
  if variant in semantic-directional-variants {
    _ = validate-directional-tracks(fields.tracks, "layout \"title\" tracks")
  } else if fields.tracks != auto {
    fail("layout \"title\" tracks apply only to directional image variants")
  }
  if variant == "image-background" {
    if fields.align not in stack-alignments {
      fail(
        "layout \"title\" align must use left, center, or right, optionally combined with top, horizon, or bottom",
      )
    }
  } else if fields.align != left + bottom {
    fail("layout \"title\" align applies only to variant \"image-background\"")
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
///   authors: (mosaic.layouts.author("Ada Lovelace"),),
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
/// - Pass `none` to suppress an inherited `title`, `subtitle`, or `date`.
/// - Pass `()` to suppress inherited `authors`.
///
/// *Variants*
///
/// Text variants:
///
/// - `swiss`: the heading stack sits on a full-width baseline rule; author,
///   affiliation, and date hang below it in aligned columns. The default.
/// - `centered`: the heading stack at the slide's center, details anchored to
///   the bottom edge.
/// - `plate`: the whole slide takes the deck's text color and the type is
///   knocked out in the canvas color.
/// - `frame`: a thin rule border inset from the slide edge with the centered
///   stack inside it.
/// - `academic`: the conference-poster arrangement. Author names carry
///   superscript affiliation numbers over a numbered affiliation legend and a
///   contact line. Requires at least one author.
///
/// Image variants, each of which requires `image`:
///
/// - `image-left`, `image-right`, `image-top`, `image-bottom`: a full-bleed
///   picture beside or above the title stack, sized by `tracks`.
/// - `image-background`: the title stack directly over a full-slide picture,
///   anchored by `align`.
///
/// *Authors*
///
/// Every variant accepts the same `authors` array of records built with
/// `layouts.author`. The `academic` variant exposes the complete scholarly
/// details; the compact variants show names, affiliations, and linked ORCID
/// icons while omitting contact details.
///
/// *Styling*
///
/// The layout is structural. Cells are labeled `<mosaic-cell-title>`,
/// `<mosaic-cell-authors>`, `<mosaic-cell-details>`, `<mosaic-cell-accent>`,
/// and `<mosaic-cell-image>`, so appearance comes from native Typst rules.
/// A rule on `<mosaic-cell-title>` reaches the whole composed stack: title,
/// subtitle, and details alike. Recoloring it is what light-on-dark
/// compositions over a photograph need.
///
/// ```typ
/// #show label("mosaic-cell-title"): set text(fill: white)
/// #mosaic.slide(
///   layout: "title",
///   variant: "image-background",
///   image: (path: "cover.webp", scrim: black.transparentize(55%)),
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
  /// Title text. `auto` inherits `setup(title:)`.
  /// -> auto | content | str
  title: auto,
  /// Subtitle set tight below the title. `auto` inherits `setup(subtitle:)`;
  /// `none` suppresses it.
  /// -> auto | content | str | none
  subtitle: auto,
  /// Display date joined into the fine-print details line. `auto` inherits
  /// `setup(date:)`; `none` suppresses it.
  /// -> auto | content | str | none
  date: auto,
  /// The picture used by the image variants, and rejected by the others. Give a
  /// path, ready-made content, or a dictionary spec whose `scrim` key quiets the
  /// photograph enough to read text over it, as in
  /// `(path: "cover.webp", scrim: black.transparentize(55%))`.
  /// -> none | content | str | path | dictionary
  image: none,
  /// Structural arrangement: `swiss`, `centered`, `plate`, `frame`,
  /// `academic`, `image-left`, `image-right`, `image-top`, `image-bottom`, or
  /// `image-background`.
  /// -> str
  variant: "swiss",
  /// Array of records created with `layouts.author`. `auto` inherits
  /// `setup(authors:)`; `()` suppresses an inherited array.
  /// -> auto | array
  authors: auto,
  /// Sizes the split of a directional image variant, and is rejected by the
  /// others. One native Typst track size sizes the picture and is
  /// side-independent, so `image-left` and `image-right` stay mirror images;
  /// the title region takes the remaining `1fr`. An array of two is in visual
  /// order instead, and must be mirrored by hand when the variant flips.
  /// `auto` gives the picture the smaller share.
  /// -> auto | length | ratio | relative | fraction | array
  tracks: auto,
  /// Anchors the title stack within the slide, for `image-background` only.
  /// Combine `left`, `center`, or `right` with an optional `top`, `horizon`, or
  /// `bottom`.
  /// -> alignment
  align: left + bottom,
  /// Whether to draw the variant's structural mark: the `swiss` baseline
  /// rule or the `frame` border. On image variants
  /// it draws the short accent rule of the compact stack instead. `auto`
  /// draws the structural marks and omits the accent rule on image variants,
  /// where the photograph already does that work.
  /// -> auto | bool
  rule: auto,
  /// Color of the variant's structural mark. `auto` uses the deck's text
  /// color for the marked text variants (`swiss`, `frame`) and the semantic
  /// accent for the image variants' short rule.
  /// -> color | auto
  accent: auto,
) = {
  let fields = validate-fields((
    title: title,
    subtitle: subtitle,
    date: date,
    image: image,
    variant: variant,
    authors: authors,
    tracks: tracks,
    align: align,
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
#let title-metrics = (
  // Tiers of the title stack.
  subtitle-scale: 1.05,
  details-scale: 0.72,
  byline-scale: 0.6,
  fine-print-scale: 0.55,
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
  // Variant-specific offsets, in multiples of the base size.
  band-details-offset: 0.65,
  plate-details-offset: 1.4,
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
  // How far the image-background wash lightens toward the canvas color.
  scrim-opacity: 30%,
  // The image/text split of a directional image title, in visual order for a
  // left- or top-positioned picture; mirrored for the other side.
  image-tracks: (2fr, 3fr),
  // Responsive placement of a centered title over a background image: the
  // share of the width held clear at the side, and the margin when centered.
  side-reserve: 35%,
  centered-inset: 18%,
)

// The display line of the title stack carries its own <mosaic-title-display>
// label, and the theme's display size lands there rather than on the cell.
// The cell therefore stays at the deck's body size, which is what lets every
// subordinate tier below be an ordinary em multiple: nothing compounds with
// the display size, and one native `set text(size: ..)` on
// <mosaic-cell-title> scales title, subtitle, and details alike instead of
// moving the display line past its own subtitle.
#let title-display(body) = {
  let display = block(width: 100%, above: 0pt, below: 0pt, body)
  [#display#label("mosaic-title-display")]
}

// Subordinate tiers of the composed title stack, as em multiples of the cell.
//
// Their muted `fill` survives only while the cell carries the deck's ordinary
// text color; see `adapt-fill`. That is what lets one rule on
// <mosaic-cell-title> recolor the whole stack for a light-on-dark
// composition, which is the case the image-* variants exist to serve.
#let title-styles(settings) = (
  subtitle: (
    fill: settings.colors.muted,
    size: settings.title-metrics.subtitle-scale * 1em,
  ),
  details: (
    fill: settings.colors.muted,
    size: settings.title-metrics.details-scale * 1em,
  ),
)

#let title-inset(settings, top: 0pt, bottom: 0pt) = (
  top: top,
  right: settings.spacing.inset,
  bottom: bottom,
  left: settings.spacing.inset,
)

// The cell carries the deck's body size and the stack's shared typography
// through its <mosaic-cell-title> rules; the display size lives on the
// <mosaic-title-display> label inside it. A variant that wants a quieter
// composition therefore reduces the cell's em and every tier follows. The
// `anchor` is variant semantics and is applied inline; pick another variant
// (or the image-background `align:` field) to change it.
#let title-body-cell(
  settings,
  scale: 1em,
  content-sized: false,
  content: none,
  anchor: left + bottom,
  bottom-inset: auto,
) = styled-cell(
  id: "title",
  content: align(
    anchor,
    if scale == 1em { content } else { text(size: scale, content) },
  ),
  style: (
    content-sized: content-sized,
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
  let size = settings.title-metrics.orcid-size
  box(width: settings.title-metrics.orcid-gap)
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

#let author-name(author, settings, corresponding: false) = {
  as-content(author.name)
  orcid-link(author, settings)
  if corresponding and author.corresponding { super[\*] }
}

// Code mode: a markup block would preserve its edge newlines as spaces,
// leaking stray gaps around the joined run (for example before separators).
#let join-content(items, separator: [, ]) = {
  for (index, item) in items.enumerate() {
    if index > 0 { separator }
    item
  }
}

#let ordinary-title-details(fields, settings) = {
  let analyzed = analyze-authors(fields.authors)
  let author-names = analyzed.authors.map(author => author-name(author, settings))
  let affiliations = analyzed.affiliations.map(as-content)
  // Two tiers at most: a byline, then one fine-print line joining
  // affiliations and date. More rows would dilute the grouping.
  let fine-print = affiliations
  if fields.date != none {
    fine-print.push(as-content(fields.date))
  }
  if author-names.len() == 0 and fine-print.len() == 0 {
    none
  } else {
    if author-names.len() > 0 {
      join-content(author-names)
    }
    if fine-print.len() > 0 {
      if author-names.len() > 0 { linebreak() }
      join-content(fine-print, separator: [ · ])
    }
  }
}

// Short accent-colored rule: the one non-text gesture shared by every title
// variant. Sized in the stack's own em, which the cell holds at the deck's
// body size, so the rule keeps its proportion when a rule on
// <mosaic-cell-title> resizes the whole stack.
#let accent-rule(accent, settings, above: 0pt) = block(
  above: above,
  line(
    length: settings.title-metrics.accent-rule-length * 1em,
    stroke: (
      paint: accent,
      thickness: settings.title-metrics.accent-rule-thickness * 1em,
      cap: "round",
    ),
  ),
)

#let compact-title-after(
  fields,
  settings,
  include-details: true,
) = {
  let details = if include-details { ordinary-title-details(fields, settings) } else { none }
  // The auto default gives the looks variety: the accent rule anchors the
  // text variants, while image variants stay purely photographic.
  let show-rule = if fields.rule == auto {
    fields.variant not in semantic-image-variants
  } else {
    fields.rule
  }
  let after = {
    // The subtitle sits tight below the title: together they form the
    // heavy block of the page.
    if fields.subtitle != none {
      block(
        above: settings.title-metrics.subtitle-gap * settings.spacing.gap,
        // The muted fill yields to the cell's text fill once a rule sets one,
        // so label-targeted color overrides reach the whole stack.
        context text(
          ..adapt-fill(title-styles(settings).subtitle, settings),
          fields.subtitle,
        ),
      )
    }
    // A deliberate break, marked by the accent rule, separates the heading
    // stack from the details stack. Without the rule, extra space marks the
    // same break.
    if show-rule {
      accent-rule(
        fields.accent,
        settings,
        above: settings.title-metrics.rule-gap * settings.spacing.gap,
      )
    }
    if details != none {
      block(
        above: if show-rule {
          settings.title-metrics.details-gap-with-rule
        } else {
          settings.title-metrics.details-gap-without-rule
        } * settings.spacing.gap,
        {
          set par(leading: settings.title-metrics.details-leading)
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

// The complete fixed content of the title cell: the title text followed by
// the subtitle and details stack.
#let title-stack-content(
  fields,
  settings,
  include-details: true,
) = {
  title-display(as-content(fields.title))
  compact-title-after(
    fields,
    settings,
    include-details: include-details,
  )
}

#let title-stack(
  fields,
  settings,
  scale: 1em,
) = title-body-cell(
  settings,
  scale: scale,
  content: title-stack-content(fields, settings),
)

// ---------------------------------------------------------------------------
// Shared pieces for the composed text variants.
//
// Each variant separates two stacks: the heading stack (title + subtitle) and
// a details stack (byline, affiliations, date). The details builders take
// explicit text and muted fills because every variant knows its own backdrop:
// the canvas for swiss and centered, the deck text color for plate.

// Title and subtitle only: the heavy block of the page, without the details
// or the accent rule of the compact stack.
#let heading-stack(fields, settings, subtitle-fill: auto) = {
  title-display(as-content(fields.title))
  if fields.subtitle != none {
    block(
      above: settings.title-metrics.subtitle-gap * settings.spacing.gap,
      // Contextual because `adapt-fill` reads the live text fill.
      context {
        let styles = title-styles(settings).subtitle
        if subtitle-fill == auto {
          text(..adapt-fill(styles, settings), fields.subtitle)
        } else {
          text(..(inherit-fill(styles) + (fill: subtitle-fill)), fields.subtitle)
        }
      },
    )
  }
}

// The details pieces every composed variant arranges: author names (with
// ORCID links), the deduplicated affiliations, and the display date.
#let details-parts(fields, settings) = {
  let analyzed = analyze-authors(fields.authors)
  (
    names: analyzed.authors.map(author => author-name(author, settings)),
    affiliations: analyzed.affiliations.map(as-content),
    date: if fields.date == none { none } else { as-content(fields.date) },
  )
}

#let has-details(parts) = (
  parts.names.len() > 0 or parts.affiliations.len() > 0 or parts.date != none
)

// Byline and fine-print typography for the details tiers. The scales are one
// table; `unit` is what they multiply, and it is the whole difference between
// the two places details renders. Composed inside the title cell, the tiers
// take the cell's own em (the default), so they follow the rest of the stack
// when a rule rescales it; see title-display. The swiss band is its own
// <mosaic-cell-details> cell instead, so it passes the deck's base size and
// stays anchored to the body type, answering to a rule on its own cell and not
// to the title's scale.
#let details-styles(settings, unit: 1em) = (
  byline: (size: settings.title-metrics.byline-scale * unit, weight: "medium"),
  fine: (size: settings.title-metrics.fine-print-scale * unit),
)

// A two-tier centered or left-aligned details stack: the byline in the ink
// color, one fine-print line joining affiliations and date below it.
// Contextual because `adapt-fill` reads the live text fill. Adaptive
// tiers yield their fills to a recolored cell (see adapt-fill), which keeps
// the one-rule light-on-dark contract for single-cell variants; plate passes
// explicit fills for its self-colored ground instead.
#let details-stack(parts, settings, ink: auto, pale: auto, adaptive: true) = context {
  let type-scale = details-styles(settings)
  let ink-style = type-scale.byline + (
    fill: if ink == auto { settings.colors.text } else { ink },
  )
  let muted-style = type-scale.fine + (
    fill: if pale == auto { settings.colors.muted } else { pale },
  )
  if adaptive {
    ink-style = adapt-fill(ink-style, settings)
    muted-style = adapt-fill(muted-style, settings)
  }
  let fine = parts.affiliations
  if parts.date != none { fine.push(parts.date) }
  set par(leading: settings.title-metrics.details-leading)
  if parts.names.len() > 0 {
    text(..ink-style, join-content(parts.names))
  }
  if fine.len() > 0 {
    if parts.names.len() > 0 { linebreak() }
    text(..muted-style, join-content(fine, separator: [ · ]))
  }
}

// The paint of a variant's structural mark: the deck's text color unless the
// author asked for an explicit accent.
#let rule-paint(fields, settings) = if fields.at("mark-accent", default: none) != none {
  fields.mark-accent
} else {
  settings.colors.text
}

#let has-rule(fields) = if fields.rule == auto { true } else { fields.rule }

// swiss: the heading stack rests on a full-width baseline rule; author,
// affiliation, and date hang below it in three aligned columns.
#let resolve-swiss-title(fields, settings) = {
  let parts = details-parts(fields, settings)
  if not has-details(parts) and not has-rule(fields) {
    return title-stack(fields, settings)
  }
  // Contextual so the band's sizes anchor to the live base size.
  let band = context {
    let base = settings.base-size
    let type-scale = details-styles(settings, unit: base)
    if has-rule(fields) {
      block(line(
        length: 100%,
        stroke: (
          paint: rule-paint(fields, settings),
          thickness: settings.title-metrics.accent-stroke-thickness * base,
        ),
      ))
    }
    if has-details(parts) {
      block(
        above: settings.title-metrics.band-details-offset * base,
        grid(
          columns: (1fr, 1fr, auto),
          column-gutter: base,
          if parts.names.len() > 0 {
            set par(leading: settings.title-metrics.details-leading)
            text(
              ..(type-scale.byline + (fill: settings.colors.text)),
              join-content(parts.names),
            )
          },
          if parts.affiliations.len() > 0 {
            set par(leading: settings.title-metrics.details-leading)
            text(
              ..(type-scale.fine + (fill: settings.colors.muted)),
              join-content(parts.affiliations, separator: [ · ]),
            )
          },
          if parts.date != none {
            align(right, text(
              ..(type-scale.fine + (fill: settings.colors.muted)),
              parts.date,
            ))
          },
        ),
      )
    }
  }
  v(
    t(1fr, title-body-cell(
      settings,
      content: heading-stack(fields, settings),
      bottom-inset: settings.spacing.gap,
    )),
    t(auto, fixed-cell(
      band,
      "details",
      settings,
      inset: title-inset(settings, bottom: settings.spacing.inset),
    )),
  )
}

// centered: the heading stack at the slide's center, the details anchored to
// the bottom edge so the composition never reads as top-heavy.
#let resolve-centered-title(fields, settings) = {
  let parts = details-parts(fields, settings)
  styled-cell(
    id: "title",
    content: {
      align(center + horizon, {
        set align(center)
        heading-stack(fields, settings)
      })
      if has-details(parts) {
        place(
          bottom + center,
          align(center, details-stack(parts, settings)),
        )
      }
    },
    style: (inset: settings.spacing.inset),
  )
}

// plate: the whole slide takes the deck's text color and the type is knocked
// out in the canvas color. Typography alone; no marks.
#let resolve-plate-title(fields, settings) = {
  let pale = settings.colors.canvas.transparentize(settings.title-metrics.scrim-opacity)
  let parts = details-parts(fields, settings)
  styled-cell(
    id: "title",
    content: {
      set text(fill: settings.colors.canvas)
      align(left + bottom, {
        heading-stack(fields, settings, subtitle-fill: pale)
        if has-details(parts) {
          block(
            above: settings.title-metrics.plate-details-offset * 1em,
            details-stack(parts, settings, ink: settings.colors.canvas, pale: pale, adaptive: false),
          )
        }
      })
    },
    style: (
      inset: settings.spacing.inset,
      fill: settings.colors.text,
    ),
  )
}

// frame: a single thin rule border inset from the slide edge closes the
// composition; the stack is centered inside it.
#let resolve-frame-title(fields, settings) = {
  let parts = details-parts(fields, settings)
  styled-cell(
    id: "title",
    content: context block(
      width: 100%,
      height: 100%,
      stroke: if has-rule(fields) {
        (
          paint: rule-paint(fields, settings),
          thickness: settings.title-metrics.accent-stroke-thickness * settings.base-size,
        )
      } else {
        none
      },
      inset: settings.title-metrics.card-inset * settings.spacing.inset,
      {
        align(center + horizon, {
          set align(center)
          text(size: settings.title-metrics.card-title-scale, heading-stack(fields, settings))
        })
        if has-details(parts) {
          place(
            bottom + center,
            align(center, details-stack(parts, settings)),
          )
        }
      },
    ),
    style: (inset: settings.title-metrics.card-outer-inset * settings.spacing.inset),
  )
}

#let academic-author(author, settings, show-numbers: true) = {
  author-name(author, settings)
  if show-numbers and author.numbers.len() > 0 {
    super(join-content(author.numbers.map(str), separator: [,]))
  }
  if author.corresponding { super[\*] }
}

#let academic-affiliation(item, settings) = {
  super(str(item.at(0) + 1))
  box(width: settings.title-metrics.affiliation-marker-gap)
  as-content(item.at(1))
}

#let contact-items(author) = {
  let items = ()
  let email = author.email
  if email != none {
    items.push(link("mailto:" + email, email))
  }
  items
}

// The byline already names each author (with an asterisk for the
// corresponding author), so the contact line shows only the marker and the
// address.
#let academic-contact(author, settings) = {
  if author.corresponding {
    [\*]
    box(width: settings.title-metrics.affiliation-marker-gap)
  }
  join-content(contact-items(author), separator: [ · ])
}

#let resolve-academic-title(fields, settings) = {
  let academic = analyze-authors(fields.authors)
  // Metadata compresses to three tiers: a byline, one fine-print line for
  // the affiliation legend, and one fine-print line joining contacts and
  // date. More rows than that would scatter the composition.
  let affiliation-items = academic.affiliations.enumerate()
    .map(item => academic-affiliation(item, settings))
  let contact-line = academic.authors
    .filter(author => author.email != none)
    .map(author => academic-contact(author, settings))
  if fields.date != none {
    contact-line.push(as-content(fields.date))
  }
  let details-count = affiliation-items.len() + contact-line.len()
  let children = ()
  // The heading stack takes the flexible track and aligns to its bottom, so
  // the whole composition anchors to the lower edge of the slide.
  children.push(t(1fr, title-body-cell(
    settings,
    scale: settings.title-metrics.academic-scale,
    content: title-stack-content(
      fields,
      settings,
      include-details: false,
    ),
    bottom-inset: settings.spacing.gap,
  )))
  if academic.authors.len() > 0 {
    let author-content = join-content(academic.authors.map(author => academic-author(author, settings)))
    children.push(t(
      auto,
      fixed-cell(
        author-content,
        "authors",
        settings,
        inset: title-inset(
          settings,
          top: settings.spacing.compact-gap,
          bottom: if details-count > 0 {
            settings.spacing.compact-gap
          } else {
            settings.spacing.inset
          },
        ),
      ),
    ))
  }
  if details-count > 0 {
    let details-content = {
      if affiliation-items.len() > 0 {
        join-content(affiliation-items, separator: [ · ])
      }
      if affiliation-items.len() > 0 and contact-line.len() > 0 {
        linebreak()
      }
      if contact-line.len() > 0 {
        join-content(contact-line, separator: [ · ])
      }
    }
    children.push(t(
      auto,
      academic-small-cell(
        details-content,
        "details",
        settings,
        bottom: settings.spacing.inset,
      ),
    ))
  }
  v(..children)
}

#let resolve-directional-image-title(fields, image, settings) = {
  let text-column = title-stack(
    fields,
    settings,
    scale: settings.title-metrics.image-title-scale,
  )
  let position = semantic-image-position(fields.variant)
  let tracks = if fields.tracks == auto {
    if position in ("left", "top") {
      settings.title-metrics.image-tracks
    } else {
      settings.title-metrics.image-tracks.rev()
    }
  } else {
    fields.tracks
  }
  directional-image-layout(
    position,
    image-cell(image),
    text-column,
    tracks: tracks,
  )
}

#let background-stack-inset(alignment, settings) = {
  let side-reserve = settings.title-metrics.side-reserve
  let centered-inset = settings.title-metrics.centered-inset
  if alignment in (right, right + top, right + horizon, right + bottom) {
    (
      top: settings.spacing.inset,
      right: settings.spacing.inset,
      bottom: settings.spacing.inset,
      left: side-reserve,
    )
  } else if alignment in (center, center + top, center + horizon, center + bottom) {
    (
      top: settings.spacing.inset,
      right: centered-inset,
      bottom: settings.spacing.inset,
      left: centered-inset,
    )
  } else {
    (
      top: settings.spacing.inset,
      right: side-reserve,
      bottom: settings.spacing.inset,
      left: settings.spacing.inset,
    )
  }
}

#let resolve-background-title(fields, image, settings) = {
  // The image carries the contrast, so the stack inherits the surrounding
  // native text color. Pass a pre-adjusted image and override the title cell's
  // text fill for light-on-dark compositions.
  image-background-cell(styled-cell(
    id: "title",
    content: align(
      fields.align,
      title-stack-content(fields, settings),
    ),
    style: (
      inset: background-stack-inset(fields.align, settings),
    ),
  ), image)
}

#let resolve-title(command, settings) = {
  let inherited = command.fields
  let fields = validate-fields(inherited + (
    title: if inherited.title == auto { settings.deck.title } else { inherited.title },
    subtitle: if inherited.subtitle == auto { settings.deck.subtitle } else { inherited.subtitle },
    authors: if inherited.authors == auto { settings.deck.authors } else { inherited.authors },
    date: if inherited.date == auto { settings.deck.date } else { inherited.date },
    accent: if inherited.accent == auto { settings.colors.accent } else { inherited.accent },
  ))
  // Marked text variants default their structural rule to the deck's text
  // color; only an explicit accent recolors it. The resolved accent above
  // still feeds the image variants' short rule.
  let fields = fields + (
    mark-accent: if inherited.accent == auto { none } else { inherited.accent },
  )
  let image = optional-fixed-image(fields.image, "layout \"title\" image")
  // The recipe rides on `settings`, which every helper below already receives,
  // so the measurements reach the whole composition without threading an extra
  // argument through seven variants.
  let settings = settings + (title-metrics: title-metrics)
  if fields.variant == "academic" {
    resolve-academic-title(fields, settings)
  } else if fields.variant == "swiss" {
    resolve-swiss-title(fields, settings)
  } else if fields.variant == "centered" {
    resolve-centered-title(fields, settings)
  } else if fields.variant == "plate" {
    resolve-plate-title(fields, settings)
  } else if fields.variant == "frame" {
    resolve-frame-title(fields, settings)
  } else if fields.variant in semantic-directional-variants {
    resolve-directional-image-title(fields, image, settings)
  } else {
    resolve-background-title(fields, image, settings)
  }
}
