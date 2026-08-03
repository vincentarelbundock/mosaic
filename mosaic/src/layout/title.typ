// Construction, validation, and resolution of the title layout.
#import "../shared.typ": fail
#import "../author.typ": analyze-authors
#import "../grid/constructors.typ": styled-cell, h, v, t
#import "core.typ": (
  make-layout,
  validate-accent,
  validate-visual-spec,
)
#import "support.typ": (
  adapt-fill,
  affix,
  as-content,
  fixed-cell,
)
#import "image-support.typ": (
  directional-image-layout,
  image-background-cell,
  image-region,
  optional-fixed-image,
  semantic-directional-variants,
  semantic-image-position,
  semantic-image-variants,
  validate-directional-tracks,
  validate-semantic-image-use,
)

#let variants = (
  "academic",
  "left-aligned",
  "centered-stack",
  "accent-block",
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
  validate-accent(fields, "title", allow-auto: allow-auto)
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
    let _ = analyze-authors(fields.authors)
  }
  validate-semantic-image-use(fields, "layout \"title\"")
  if fields.image != none {
    let _ = validate-visual-spec(
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
    validate-directional-tracks(fields.tracks, "layout \"title\" tracks")
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
/// With no explicit metadata, the layout inherits `title`, `subtitle`,
/// `authors`, and `date` from `setup`. Explicit values override setup; use
/// `none` for optional text/date fields and `()` for authors to suppress an
/// inherited value. The layout supplies every cell's content, so the
/// surrounding `mosaic.slide` consumes no slide bodies.
/// `academic` places author names and affiliations inline, with a numbered
/// affiliation legend.
/// Every variant accepts the same `authors` array of records created by the
/// standalone `author()` function. The `academic` variant exposes the complete
/// scholarly metadata; compact variants show names, affiliations, and linked
/// ORCID icons while omitting contact details. The `academic` variant requires
/// at least one author. Author affiliations use `id` and `name`.
/// The other variants are named for their visible structure: `left-aligned`, `centered-stack`,
/// `accent-block`, `image-left`, `image-right`, `image-top`, `image-bottom`,
/// and `image-background`. Image variants require `image`; `tracks` controls
/// directional two-cell structure in visual order.
/// `rule` controls the short accent-colored rule between the title mass and
/// the metadata. The `auto` default draws it on the text variants and omits
/// it on the image variants.
/// `align` anchors the title stack for `image-background`. That variant
/// places the stack directly over the image in the surrounding native text
/// color; quiet the photograph with the image spec's `scrim` key, as in
/// `image: (path: "cover.webp", scrim: black.transparentize(55%))`, and
/// override the `title` cell's text fill for light-on-dark compositions.
#let title(
  title: auto,
  subtitle: auto,
  date: auto,
  image: none,
  variant: "left-aligned",
  authors: auto,
  tracks: auto,
  align: left + bottom,
  rule: auto,
  /// Color used by the title rule and accent-block spine. `auto` inherits the
  /// semantic accent resolved by `setup`.
  /// -> color | auto
  accent: auto,
  ..legacy-title,
) = {
  let positional = legacy-title.pos()
  if legacy-title.named().len() > 0 or positional.len() > 1 {
    fail("layout \"title\" accepts one legacy positional title and named arguments")
  }
  if positional.len() == 1 {
    if title != auto {
      fail("layout \"title\" cannot receive both a positional title and title:")
    }
    title = positional.first()
  }
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

// Metadata tiers inside the composed title stack keep pt-anchored sizes so
// they do not compound with the display scale supplied by the
// <mosaic-cell-title> label rules. `setup` sets `size: 2em` on the whole title
// cell, so an em-relative subtitle would resolve to 1.05em x 2em and overflow.
//
// The cost is that a native `set text(size: ..)` on that label moves only the
// display line, since that rule *is* the display size. Scaling the stack as a
// unit would mean applying the display size to the title line rather than to
// the cell, which is a change to every title composition rather than a local
// fix.
//
// Their muted `fill` survives only while the cell carries the deck's ordinary
// text color; see `adapt-fill`. That is what lets one rule on
// <mosaic-cell-title> recolor the whole stack for a light-on-dark
// composition, which is the case the image-* variants exist to serve.
#let title-typography(settings) = {
  let base = settings.type.body.size
  (
    subtitle: settings.type.subtitle + (size: 1.05 * base),
    metadata: settings.type.caption + (size: 0.72 * base),
  )
}

#let title-inset(settings, top: 0pt, bottom: 0pt) = (
  top: top,
  right: settings.spacing.inset,
  bottom: bottom,
  left: settings.spacing.inset,
)

// The title cell's display typography comes from the <mosaic-cell-title>
// label rules that `setup` emits. Variants that want a smaller display scale
// apply a relative `scale` factor inline, so a user or theme rule that
// resizes the title scales every variant proportionally. The `anchor` is
// variant semantics and is applied inline; pick another variant (or the
// image-background `align:` field) to change it.
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
#let orcid-link(author, size: 0.9em) = if author.orcid != none {
  box(width: 0.22em)
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

#let author-name(author, corresponding: false) = {
  as-content(author.name)
  orcid-link(author)
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

#let ordinary-title-details(fields) = {
  let analyzed = analyze-authors(fields.authors)
  let author-names = analyzed.authors.map(author => author-name(author))
  let affiliations = analyzed.affiliations.map(item => as-content(item.name))
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
// variant. Sized from the body type so it is stable across display scales.
#let accent-rule(accent, settings, above: 0pt) = {
  let base = settings.type.body.size
  block(
    above: above,
    line(
      length: 1.6 * base,
      stroke: (
        paint: accent,
        thickness: 0.12 * base,
        cap: "round",
      ),
    ),
  )
}

#let compact-title-after(
  fields,
  settings,
  include-details: true,
) = {
  let details = if include-details { ordinary-title-details(fields) } else { none }
  // The auto default gives the looks variety: the accent rule anchors the
  // text variants, while image variants stay purely photographic.
  let show-rule = if fields.rule == auto {
    fields.variant not in semantic-image-variants
  } else {
    fields.rule
  }
  let after = {
    // The subtitle sits tight below the title: together they form the
    // heavy mass of the page.
    if fields.subtitle != none {
      block(
        above: 0.55 * settings.spacing.gap,
        // The muted fill yields to the cell's text fill once a rule sets one,
        // so label-targeted color overrides reach the whole stack.
        context text(
          ..(
            adapt-fill(title-typography(settings).subtitle, settings)
              + (weight: "regular")
          ),
          fields.subtitle,
        ),
      )
    }
    // A deliberate break, marked by the accent rule, separates the title
    // mass from the metadata mass. Without the rule, extra space marks the
    // same break.
    if show-rule {
      accent-rule(fields.accent, settings, above: 1.3 * settings.spacing.gap)
    }
    if details != none {
      block(
        above: if show-rule { 0.8 } else { 1.3 } * settings.spacing.gap,
        {
          set par(leading: 0.55em)
          context text(
            ..(
              adapt-fill(title-typography(settings).metadata, settings)
                + (weight: "regular")
            ),
            details,
          )
        },
      )
    }
  }
  affix(after)
}

// The complete fixed content of the title cell: the title text followed by
// the subtitle and metadata stack.
#let title-stack-content(
  fields,
  settings,
  include-details: true,
) = {
  as-content(fields.title)
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

#let resolve-centered-title(fields, settings) = {
  styled-cell(
    id: "title",
    content: align(
      center + horizon,
      title-stack-content(fields, settings),
    ),
    style: (inset: settings.spacing.inset),
  )
}


#let academic-author(author, show-numbers: true) = {
  author-name(author)
  if show-numbers and author.numbers.len() > 0 {
    super(join-content(author.numbers.map(str), separator: [,]))
  }
  if author.corresponding { super[\*] }
}

#let academic-affiliation(item) = {
  super(str(item.at(0) + 1))
  box(width: 0.2em)
  as-content(item.at(1).name)
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
#let academic-contact(author) = {
  if author.corresponding {
    [\*]
    box(width: 0.2em)
  }
  join-content(contact-items(author), separator: [ · ])
}

#let resolve-academic-title(fields, settings) = {
  let academic = analyze-authors(fields.authors)
  // Metadata compresses to three tiers: a byline, one fine-print line for
  // the affiliation legend, and one fine-print line joining contacts and
  // date. More rows than that would scatter the composition.
  let affiliation-items = academic.affiliations.enumerate().map(academic-affiliation)
  let contact-line = academic.authors
    .filter(author => author.email != none)
    .map(academic-contact)
  if fields.date != none {
    contact-line.push(as-content(fields.date))
  }
  let details-count = affiliation-items.len() + contact-line.len()
  let children = ()
  // The title mass takes the flexible track and aligns to its bottom, so
  // the whole composition anchors to the lower edge of the slide.
  children.push(t(1fr, title-body-cell(
    settings,
    scale: 0.8em,
    content: title-stack-content(
      fields,
      settings,
      include-details: false,
    ),
    bottom-inset: settings.spacing.gap,
  )))
  if academic.authors.len() > 0 {
    let author-content = join-content(academic.authors.map(academic-author))
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

#let resolve-accent-title(fields, settings) = {
  // A narrow spine, not a slab: an empty panel wide enough to dominate the
  // page reads as missing content, while a spine reads as a deliberate mark.
  h(
    t(4%, fixed-cell(
      [],
      "accent",
      settings,
      inset: 0pt,
      content-sized: false,
      surface: (fill: fields.accent),
    )),
    t(1fr, title-stack(fields, settings)),
  )
}

#let resolve-directional-image-title(fields, image, settings) = {
  let text-region = title-stack(
    fields,
    settings,
    scale: 0.85em,
  )
  let position = semantic-image-position(fields.variant)
  let tracks = if fields.tracks == auto {
    if position in ("left", "top") { (2fr, 3fr) } else { (3fr, 2fr) }
  } else {
    fields.tracks
  }
  directional-image-layout(
    position,
    image-region(image, settings),
    text-region,
    tracks: tracks,
  )
}

#let background-stack-inset(alignment, settings) = {
  let side-reserve = 35%
  let centered-margin = 18%
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
      right: centered-margin,
      bottom: settings.spacing.inset,
      left: centered-margin,
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
  let image = optional-fixed-image(fields.image, "layout \"title\" image")
  if fields.variant == "academic" {
    resolve-academic-title(fields, settings)
  } else if fields.variant == "left-aligned" {
    title-stack(fields, settings)
  } else if fields.variant == "centered-stack" {
    resolve-centered-title(fields, settings)
  } else if fields.variant == "accent-block" {
    resolve-accent-title(fields, settings)
  } else if fields.variant in semantic-directional-variants {
    resolve-directional-image-title(fields, image, settings)
  } else {
    resolve-background-title(fields, image, settings)
  }
}
