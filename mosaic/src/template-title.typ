// Construction, validation, and resolution of the title template.
#import "shared.typ": fail
#import "author.typ": validate-author
#import "grid-model.typ": styled-cell, h, v, t
#import "template-core.typ": (
  make-grid,
  validate-visual-spec,
)
#import "template-support.typ": (
  affix,
  as-content,
  fixed-text-cell,
)
#import "template-image.typ": (
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


#let validate-structured-authors(authors) = {
  let known-affiliations = (:)
  for (author-index, author) in authors.enumerate() {
    let subject = "template \"title\" author " + str(author-index + 1)
    let author = validate-author(author, subject: subject)
    for affiliation in author.affiliations {
      let id = affiliation.id
      if id in known-affiliations {
        if repr(known-affiliations.at(id)) != repr(affiliation.name) {
          fail(
            "template \"title\" affiliation id " + repr(id)
              + " has conflicting names",
          )
        }
      } else {
        known-affiliations.insert(id, affiliation.name)
      }
    }
  }
}

#let panel-alignments = (
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

#let validate-fields(fields) = {
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "template \"title\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  if type(fields.authors) != array {
    fail("template \"title\" authors must be an array")
  }
  validate-structured-authors(fields.authors)
  let _ = validate-semantic-image-use(fields, "template \"title\"")
  if fields.image != none {
    let _ = validate-visual-spec(
      fields.image,
      "template \"title\" image",
      allow-size: false,
    )
  }
  if variant == "academic" {
    if fields.authors.len() == 0 {
      fail("template \"title\" variant " + repr(variant) + " requires at least one author")
    }
  }
  if variant in semantic-directional-variants {
    let _ = validate-directional-tracks(fields.tracks, "template \"title\" tracks")
  } else if fields.tracks != auto {
    fail("template \"title\" tracks apply only to directional image variants")
  }
  if variant == "image-background" {
    if fields.panel-align not in panel-alignments {
      fail(
        "template \"title\" panel-align must use left, center, or right, optionally combined with top, horizon, or bottom",
      )
    }
  } else if fields.panel-align != left + bottom {
    fail("template \"title\" panel-align applies only to variant \"image-background\"")
  }
  fields
}

/// Creates a presentation title grid.
///
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
/// directional two-region structure in visual order. Every variant consumes exactly one
/// slide body in the `title` cell.
#let title(
  subtitle: none,
  date: none,
  image: none,
  variant: "left-aligned",
  authors: (),
  tracks: auto,
  panel-align: left + bottom,
) = {
  let fields = validate-fields((
    subtitle: subtitle,
    date: date,
    image: image,
    variant: variant,
    authors: authors,
    tracks: tracks,
    panel-align: panel-align,
  ))
  make-grid("title", fields, suppress-global-logo: true)
}

#let title-typography(settings) = {
  let base = settings.type.body.size
  // Display type wants tighter lines and tracking than body text; multi-line
  // titles should read as one mass, not stacked strips. `leading` is split
  // out and applied as paragraph leading by the renderer.
  let display-metrics = (leading: 0.42em, tracking: -0.015em)
  (
    display: settings.type.title + (size: 2 * base) + display-metrics,
    compact-display: settings.type.title + (size: 1.7 * base) + display-metrics,
    academic-display: settings.type.title + (size: 1.6 * base) + display-metrics,
    subtitle: settings.type.subtitle + (size: 1.05 * base),
    byline: settings.type.caption + (size: 0.8 * base),
    metadata: settings.type.caption + (size: 0.72 * base),
    small: settings.type.small + (size: 0.55 * base),
  )
}

#let title-inset(settings, top: 0pt, bottom: 0pt) = (
  top: top,
  right: settings.spacing.inset,
  bottom: bottom,
  left: settings.spacing.inset,
)

#let title-fixed-cell(
  body,
  id,
  settings,
  text-style,
  align: left + horizon,
  inset: 0pt,
  fill: auto,
  content-sized: true,
) = fixed-text-cell(
  body,
  id,
  settings,
  text-style,
  align: align,
  inset: inset,
  content-sized: content-sized,
  surface: (
    fill: if fill == auto { settings.colors.canvas } else { fill },
  ),
)

#let title-body-cell(
  settings,
  title-style: none,
  content-sized: false,
  after: none,
  align: left + bottom,
  bottom-inset: auto,
) = styled-cell(
  id: "title",
  style: (
    after: after,
    content-sized: content-sized,
    inset: title-inset(
      settings,
      top: settings.spacing.inset,
      // Anchored compositions want real breathing room at the bottom edge.
      bottom: if bottom-inset == auto { settings.spacing.inset } else { bottom-inset },
    ),
    align: align,
    fill: settings.colors.canvas,
    text: (if title-style == none { title-typography(settings).display } else { title-style })
      + (fill: settings.colors.text),
  ),
)

#let academic-small-cell(body, id, settings, bottom: auto) = title-fixed-cell(
  body,
  id,
  settings,
  title-typography(settings).small,
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
        "../assets/orcid.svg",
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
  let author-names = fields.authors.map(author => author-name(author))
  let affiliation-ids = ()
  let affiliations = ()
  for author in fields.authors {
    for affiliation in author.affiliations {
      if affiliation.id not in affiliation-ids {
        affiliation-ids.push(affiliation.id)
        affiliations.push(as-content(affiliation.name))
      }
    }
  }
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
#let accent-rule(settings, above: 0pt) = {
  let base = settings.type.body.size
  block(
    above: above,
    line(
      length: 1.6 * base,
      stroke: (
        paint: settings.colors.accent,
        thickness: 0.12 * base,
        cap: "round",
      ),
    ),
  )
}

#let compact-title-after(
  fields,
  settings,
  foreground: auto,
  include-details: true,
) = {
  let foreground = if foreground == auto { settings.colors.text } else { foreground }
  let details = if include-details { ordinary-title-details(fields) } else { none }
  let after = {
    // The subtitle sits tight below the title: together they form the
    // heavy mass of the page.
    if fields.subtitle != none {
      block(
        above: 0.55 * settings.spacing.gap,
        text(
          ..(
            title-typography(settings).subtitle
              + (fill: foreground, weight: "regular")
          ),
          fields.subtitle,
        ),
      )
    }
    // A deliberate break, marked by the accent rule, separates the title
    // mass from the metadata mass.
    accent-rule(settings, above: 1.3 * settings.spacing.gap)
    if details != none {
      block(
        above: 0.8 * settings.spacing.gap,
        {
          set par(leading: 0.55em)
          text(
            ..(
              title-typography(settings).metadata
                + (fill: foreground, weight: "regular")
            ),
            details,
          )
        },
      )
    }
  }
  affix(after)
}

#let title-stack(
  fields,
  settings,
  title-style: none,
) = title-body-cell(
  settings,
  title-style: title-style,
  after: compact-title-after(fields, settings),
)

#let resolve-centered-title(fields, settings) = {
  let after = compact-title-after(fields, settings)
  styled-cell(
    id: "title",
    style: (
      after: after,
      inset: settings.spacing.inset,
      align: center + horizon,
      fill: settings.colors.canvas,
      text: title-typography(settings).display + (fill: settings.colors.text),
    ),
  )
}

#let structured-academic-data(authors) = {
  let affiliation-ids = ()
  let affiliations = ()
  let normalized-authors = ()
  for author in authors {
    let record = author
    let numbers = ()
    for affiliation in record.affiliations {
      let index = affiliation-ids.position(id => id == affiliation.id)
      if index == none {
        affiliation-ids.push(affiliation.id)
        affiliations.push(affiliation)
        index = affiliation-ids.len() - 1
      }
      numbers.push(index + 1)
    }
    normalized-authors.push(record + (numbers: numbers,))
  }
  (
    authors: normalized-authors,
    affiliations: affiliations,
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

#let academic-contact(author) = {
  let items = contact-items(author)
  if author.corresponding {
    [\*]
    box(width: 0.2em)
  }
  as-content(author.name)
  [: ]
  join-content(items, separator: [ · ])
}

#let resolve-academic-title(fields, settings) = {
  let academic = structured-academic-data(fields.authors)
  let typography = title-typography(settings)
  // Metadata compresses to two tiers: a byline, then one fine-print line
  // joining affiliations, contacts, and date. Stacking each of those in its
  // own row would scatter the composition.
  let details-items = academic.affiliations.enumerate().map(academic-affiliation)
  details-items += academic.authors
    .filter(author => author.email != none)
    .map(academic-contact)
  if fields.date != none {
    details-items.push(as-content(fields.date))
  }
  let children = ()
  // The title mass takes the flexible track and aligns to its bottom, so
  // the whole composition anchors to the lower edge of the slide.
  children.push(t(1fr, title-body-cell(
    settings,
    title-style: typography.academic-display,
    after: compact-title-after(
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
      title-fixed-cell(
        author-content,
        "authors",
        settings,
        typography.byline + (
          fill: settings.colors.text,
          weight: "medium",
        ),
        inset: title-inset(
          settings,
          top: settings.spacing.compact-gap,
          bottom: if details-items.len() > 0 {
            settings.spacing.compact-gap
          } else {
            settings.spacing.inset
          },
        ),
      ),
    ))
  }
  if details-items.len() > 0 {
    children.push(t(
      auto,
      academic-small-cell(
        join-content(details-items, separator: [ · ]),
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
    t(4%, title-fixed-cell(
      [],
      "accent",
      settings,
      title-typography(settings).subtitle + (fill: settings.colors.inverse-text),
      align: left + bottom,
      inset: 0pt,
      fill: settings.colors.accent,
      content-sized: false,
    )),
    t(1fr, title-stack(fields, settings)),
  )
}

#let resolve-directional-image-title(fields, image, settings) = {
  let text-region = title-stack(
    fields,
    settings,
    title-style: title-typography(settings).compact-display,
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

#let background-panel-inset(alignment, settings) = {
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

#let background-scrim(alignment) = {
  let dark = black.transparentize(35%)
  let clear = black.transparentize(100%)
  if alignment in (right, right + top, right + horizon, right + bottom) {
    gradient.linear(
      (clear, 0%),
      (clear, 5%),
      (dark, 40%),
      (dark, 100%),
      angle: 0deg,
    )
  } else if alignment in (center, center + top, center + horizon, center + bottom) {
    gradient.linear(
      (clear, 0%),
      (dark, 15%),
      (dark, 85%),
      (clear, 100%),
      angle: 0deg,
    )
  } else {
    gradient.linear(
      (dark, 0%),
      (dark, 60%),
      (clear, 95%),
      (clear, 100%),
      angle: 0deg,
    )
  }
}

#let resolve-background-title(fields, image, settings) = {
  let foreground = settings.colors.inverse-text
  let after = compact-title-after(fields, settings, foreground: foreground)
  image-background-cell(styled-cell(
    id: "title",
    style: (
      after: after,
      inset: background-panel-inset(fields.panel-align, settings),
      align: fields.panel-align,
      text: title-typography(settings).display + (fill: foreground),
    ),
  ), image, overlay: background-scrim(fields.panel-align))
}

#let resolve-title(command, settings) = {
  let fields = validate-fields(command.fields)
  let image = optional-fixed-image(fields.image, "template \"title\" image")
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
