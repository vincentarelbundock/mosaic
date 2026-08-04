// Construction, validation, and resolution of the section layout.
#import "../shared.typ": fail
#import "../grid/constructors.typ": styled-cell
#import "../deck-state.typ": logical-section
#import "core.typ": (
  make-layout,
  validate-accent,
  validate-visual-spec,
)

#import "support.typ": adapt-fill, as-content, subordinate-block, affix
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

#let text-variants = (
  "plain",
  "rule",
  "numeral",
  "baseline",
  "toc",
)
#let variants = text-variants + semantic-image-variants

// The visual recipe for each designed variant, in one place.
//
// A variant is a composition, not just typography: it interleaves text tiers
// with explicit spacers and rules, and a `v(0.24em)` is not something a show
// rule can reach. So the measurements live here as named fields rather than as
// literals buried in the rendering, and `section(style: ..)` merges over them.
//
// Typography is still reachable natively. Every text tier a variant emits is
// labeled (`<mosaic-section-number>`, `<mosaic-section-subtitle>`), so a theme
// or deck can restyle the type with an ordinary rule and leave the geometry
// alone:
//
//   #show label("mosaic-section-number"): set text(weight: "black")
//
// Sizes are em against the section cell's display type, so a theme that
// rescales the deck rescales the whole composition with it.
#let section-styles = (
  plain: (
    number-size: 0.65em,
    subtitle-size: 1.05em,
  ),
  rule: (
    paragraph-spacing: 0.06em,
    number-size: 0.5em,
    number-weight: "semibold",
    gap-below-number: 0.24em,
    rule-thickness: 0.16em,
    gap-below-rule: 0.28em,
    title-size: 1.15em,
    title-weight: "bold",
    title-tracking: -0.01em,
    gap-below-title: 0.16em,
    subtitle-size: 0.44em,
  ),
  numeral: (
    paragraph-spacing: 0.12em,
    paragraph-leading: 0.8em,
    number-dx: -0.75em,
    number-dy: -1.15em,
    number-size: 6.8em,
    number-weight: 200,
    number-tracking: -0.03em,
    title-size: 1.05em,
    title-weight: "bold",
    title-tracking: -0.01em,
    gap-below-title: 0.2em,
    gap-below-subtitle: 0.5em,
    subtitle-size: 0.44em,
  ),
  baseline: (
    paragraph-spacing: 0.12em,
    paragraph-leading: 0.8em,
    gutter: 0.5em,
    title-size: 1.07em,
    title-weight: "bold",
    title-tracking: -0.01em,
    number-size: 1.07em,
    number-weight: 200,
    gap-above-rule: 0.2em,
    rule-thickness: 0.025em,
    gap-below-rule: 0.2em,
    subtitle-size: 0.41em,
  ),
  toc: (
    item-spacing: 0.4em,
    gutter: 0.45em,
    item-size: 0.64em,
    current-weight: "semibold",
    other-weight: "medium",
    gap-above-subtitle: 0.35em,
    subtitle-size: 0.41em,
  ),
)

// Image variants compose their text exactly as `plain` does, so they share its
// entry rather than repeating it.
#let variant-style(variant, overrides) = (
  section-styles.at(variant, default: section-styles.plain) + overrides
)

#let validate-fields(fields, allow-auto: false) = {
  validate-accent(fields, "section", allow-auto: allow-auto)
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "layout \"section\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  validate-semantic-image-use(fields, "layout \"section\"")
  if fields.image != none {
    let _ = validate-visual-spec(
      fields.image,
      "layout \"section\" image",
    )
  }
  if variant in semantic-directional-variants {
    validate-directional-tracks(fields.tracks, "layout \"section\" tracks")
  } else if fields.tracks != auto {
    fail("layout \"section\" tracks apply only to directional image variants")
  }
  fields
}

/// Creates a section divider grid.
///
/// The section cell's text is the slide's own content, so the surrounding
/// `mosaic.slide` supplies one block. Automatic level-one headings resolve to
/// this layout.
///
/// ```typ
/// #mosaic.slide(
///   layout: "section",
///   number: [02],
///   subtitle: [How the grid resolves],
/// )[Structure]
/// ```
///
/// *Variants*
///
/// - `plain`: one centered `section` cell. The default.
/// - `rule`: a heavy full-width rule with the title hanging beneath it, flush
///   left, the number above the rule.
/// - `numeral`: the section number set enormous in the line color, bleeding
///   off the top-right edge behind a lower-left title stack.
/// - `baseline`: title flush left and number flush right sharing one
///   baseline, tied together by a full-width hairline.
/// - `toc`: every section in the deck listed, the current one alive with its
///   number, the others ghosted.
/// - `image-left`, `image-right`, `image-top`, `image-bottom`: that cell beside
///   or above a full-bleed `image` cell, sized by `tracks`.
/// - `image-background`: the section text directly over a full-slide picture.
///
/// Every image variant requires `image`. The designed text variants (every
/// variant but `plain` and the image ones) treat an omitted `number` as the
/// automatic section counter, so they need no argument in the ordinary case.
///
/// *Styling*
///
/// The layout is structural. The centered arrangement and title typography come
/// from the `<mosaic-cell-section>` label rules `setup` emits, and the picture
/// sits in `<mosaic-cell-image>`. Over a photograph the text inherits the
/// surrounding native text color, so quiet the picture with the image spec's
/// `scrim` key and override the cell's text fill.
///
/// ```typ
/// #show label("mosaic-cell-section"): set text(fill: white)
/// #mosaic.slide(
///   layout: "section",
///   variant: "image-background",
///   image: (path: "cover.webp", scrim: black.transparentize(55%)),
/// )[Structure]
/// ```
///
/// -> dictionary
#let section(
  /// Optional subtitle set below the section title.
  /// -> content | str | none
  subtitle: none,
  /// Optional section number or label. `plain` and the image variants set it
  /// above the title and omit it when `none`; the designed text variants build
  /// their composition around it and read the automatic section counter when
  /// it is `none`.
  /// -> content | str | none
  number: none,
  /// The picture used by the image variants, and rejected by the others. Give a
  /// path, ready-made content, or a dictionary spec whose `scrim` key quiets the
  /// photograph enough to read text over it.
  /// -> none | content | str | path | dictionary
  image: none,
  /// Structural arrangement: `plain`, `image-left`, `image-right`, `image-top`,
  /// `image-bottom`, or `image-background`.
  /// -> str
  variant: "plain",
  /// Color used by the optional section number. `auto` inherits the semantic
  /// muted color resolved by `setup`, so numbers stay subordinate to the
  /// title; pass a color to override.
  /// -> color | auto
  accent: auto,
  /// Sizes the split of a directional image variant, and is rejected by the
  /// others. One native Typst track size sizes the picture and is
  /// side-independent, so `image-left` and `image-right` stay mirror images;
  /// the section region takes the remaining `1fr`. An array of two is in visual
  /// order instead.
  /// -> auto | length | ratio | relative | fraction | array
  tracks: auto,
  /// Partial overrides of the variant's visual recipe: its type sizes, weights,
  /// spacers, and rule thickness. Merges over the variant's defaults, so state
  /// only what changes. Typography can also be restyled natively through the
  /// `<mosaic-section-number>` and `<mosaic-section-subtitle>` labels.
  /// -> dictionary
  style: (:),
) = {
  let fields = validate-fields((
    subtitle: subtitle,
    number: number,
    image: image,
    variant: variant,
    accent: accent,
    tracks: tracks,
    style: style,
  ), allow-auto: true)
  make-layout("section", fields)
}

// The designed text variants build their composition around the section
// number, so an omitted `number` means the automatic section counter rather
// than nothing. `pad` zero-pads to two digits, the editorial spelling the
// numeric variants use.
#let auto-number(number, pad: true) = if number != none {
  as-content(number)
} else {
  context {
    let n = logical-section.get().first()
    if pad and n < 10 [0#str(n)] else [#str(n)]
  }
}

// One title treatment for the slide body whether or not it carries a heading.
// A heading's own show-set typography (display size, weight, block spacing)
// applies around anything a scoped rule produces, so it would override the
// variant's treatment and make automatic `=` slides render differently from
// explicit section slides. The scoped transform therefore replaces the
// heading with its body wrapped in the same treatment at the *absolute* size
// captured just outside the heading, which an em-based show-set cannot
// compound. The heading stays realized exactly once, keeping its outline
// entry, bookmark, and link target.
#let title-text(body, styles, transform: none) = text(..styles, context {
  let size = text.size
  let rest = styles
  let _ = rest.remove("size", default: none)
  show heading: it => text(size: size, ..rest, it.body)
  if transform == none { body } else { transform(body) }
})

// Subordinate subtitle line for the designed variants. Sizes are em against
// the section cell's display type, so a theme that rescales the deck rescales
// the composition with it. The muted fill yields to a recolored cell through
// `adapt-fill`.
#let subtitle-line(fields, settings, size: 0.44em, style: (:)) = if fields.subtitle == none {
  []
} else {
  [#context text(
    ..(adapt-fill((fill: settings.colors.muted, size: size), settings) + style),
    fields.subtitle,
  )<mosaic-section-subtitle>]
}

// The section number as a labeled tier, so a theme can restyle it without
// reaching into the variant's composition.
#let number-text(styles, body) = [#text(..styles, body)<mosaic-section-number>]

// A heavy full-width rule with the title mass hanging beneath it, everything
// flush left. The rule carries the design; the number sits above it like a
// running head.
#let resolve-rule-section(fields, settings, style) = styled-cell(
  id: "section",
  style: (
    align: left + horizon,
    inset: settings.spacing.inset,
    map: body => {
      set par(spacing: style.paragraph-spacing)
      number-text(
        (
          size: style.number-size,
          weight: style.number-weight,
          fill: fields.accent,
        ),
        auto-number(fields.number),
      )
      v(style.gap-below-number)
      line(length: 100%, stroke: style.rule-thickness + settings.colors.text)
      v(style.gap-below-rule)
      title-text(body, (
        size: style.title-size,
        weight: style.title-weight,
        tracking: style.title-tracking,
      ))
      v(style.gap-below-title)
      subtitle-line(fields, settings, size: style.subtitle-size)
    },
  ),
)

// The section number set enormous in the line color, bleeding off the
// top-right edge. It reads as texture rather than text and counterweights the
// lower-left title stack.
#let resolve-numeral-section(fields, settings, style) = styled-cell(
  id: "section",
  style: (
    align: left,
    inset: settings.spacing.inset,
    background: place(
      top + right,
      dx: style.number-dx,
      dy: style.number-dy,
      number-text(
        (
          size: style.number-size,
          weight: style.number-weight,
          tracking: style.number-tracking,
          fill: settings.colors.line,
        ),
        auto-number(fields.number),
      ),
    ),
    map: body => {
      set par(
        spacing: style.paragraph-spacing,
        leading: style.paragraph-leading,
      )
      v(1fr)
      title-text(body, (
        size: style.title-size,
        weight: style.title-weight,
        tracking: style.title-tracking,
      ))
      v(style.gap-below-title)
      subtitle-line(fields, settings, size: style.subtitle-size)
      v(style.gap-below-subtitle)
    },
  ),
)

// Title and number share one baseline, tied together by a full-width
// hairline: title flush left in bold, number flush right in a thin weight of
// the same size. The subtitle hangs under the rule like a caption.
#let resolve-baseline-section(fields, settings, style) = styled-cell(
  id: "section",
  style: (
    align: left + horizon,
    inset: settings.spacing.inset,
    map: body => {
      set par(
        spacing: style.paragraph-spacing,
        leading: style.paragraph-leading,
      )
      grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        column-gutter: style.gutter,
        title-text(body, (
          size: style.title-size,
          weight: style.title-weight,
          tracking: style.title-tracking,
        )),
        number-text(
          (
            size: style.number-size,
            weight: style.number-weight,
            fill: settings.colors.muted,
          ),
          auto-number(fields.number),
        ),
      )
      v(style.gap-above-rule)
      line(length: 100%, stroke: style.rule-thickness + settings.colors.text)
      v(style.gap-below-rule)
      subtitle-line(fields, settings, size: style.subtitle-size)
    },
  ),
)

// The divider shows the whole deck: every section listed, past and future
// ones ghosted in the line color, the current one alive with its accent
// number. Reads the <mosaic-section-title> records the slide runtime emits.
#let resolve-toc-section(fields, settings, style) = styled-cell(
  id: "section",
  style: (
    align: left + horizon,
    // A deck with many sections shrinks the list to fit rather than clipping.
    fit: "contain",
    inset: settings.spacing.inset,
    map: body => context {
      let mine = logical-section.get().first()
      let entries = query(label("mosaic-section-title"))
      stack(
        spacing: style.item-spacing,
        ..entries.map(entry => {
          let n = logical-section.at(entry.location()).first()
          if n == mine {
            grid(
              columns: (auto, 1fr),
              column-gutter: style.gutter,
              align: (left + bottom, left + bottom),
              number-text(
                (
                  size: style.item-size,
                  weight: style.current-weight,
                  fill: fields.accent,
                ),
                auto-number(fields.number),
              ),
              title-text(body, (
                size: style.item-size,
                weight: style.current-weight,
              )),
            )
          } else {
            text(
              size: style.item-size,
              weight: style.other-weight,
              fill: settings.colors.line,
              entry.value.title,
            )
          }
        }),
      )
      if fields.subtitle != none {
        v(style.gap-above-subtitle)
        subtitle-line(fields, settings, size: style.subtitle-size)
      }
    },
  ),
)

#let resolve-section(command, settings) = {
  let fields = validate-fields(command.fields + (
    // Numbers are subordinate furniture, never the deck's accent: `auto`
    // resolves to the muted color, and an explicit accent stays an override.
    accent: if command.fields.accent == auto { settings.colors.muted } else { command.fields.accent },
  ))
  let image = optional-fixed-image(fields.image, "layout \"section\" image")
  let style = variant-style(fields.variant, fields.at("style", default: (:)))
  if fields.variant == "rule" {
    return resolve-rule-section(fields, settings, style)
  } else if fields.variant == "numeral" {
    return resolve-numeral-section(fields, settings, style)
  } else if fields.variant == "baseline" {
    return resolve-baseline-section(fields, settings, style)
  } else if fields.variant == "toc" {
    return resolve-toc-section(fields, settings, style)
  }
  let before = if fields.number != none {
    number-text(
      (size: style.number-size, fill: fields.accent),
      fields.number,
    )
    parbreak()
  } else {
    []
  }
  let after = subordinate-block(
    fields.subtitle,
    (fill: settings.colors.muted, size: style.subtitle-size),
    settings,
    above: settings.spacing.compact-gap,
  )
  // Structural only: the section cell's arrangement and title typography come
  // from the <mosaic-cell-section> label rules the active theme emits.
  let section-cell = styled-cell(
    id: "section",
    style: (
      before: affix(before),
      after: affix(after),
      content-sized: fields.variant in semantic-directional-variants,
      fit: "width",
      inset: settings.spacing.inset,
    ),
  )
  if fields.variant in semantic-directional-variants {
    let position = semantic-image-position(fields.variant)
    directional-image-layout(
      position,
      image-region(image, settings),
      section-cell,
      tracks: fields.tracks,
      gutter: settings.spacing.gap,
    )
  } else if fields.variant == "image-background" {
    image-background-cell(section-cell, image)
  } else {
    section-cell
  }
}
