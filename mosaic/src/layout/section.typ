// Construction, validation, and resolution of the section layout.
#import "../incremental/heading.typ": decorate-heading
#import "../shared.typ": fail
#import "../grid/constructors.typ": make-cell
#import "../deck-state.typ": logical-section
#import "core.typ": (
  make-layout,
  validate-accent,
  validate-variant,
)

#import "support.typ": adapt-fill, as-content
#import "../component/style.typ": component-tokens
#import "image-support.typ": (
  directional-image-layout,
  directional-positions,
  image-background-cell,
  image-cell,
  optional-fixed-image,
  resolve-image-position,
  validate-image-fields,
)

#let text-variants = (
  "plain",
  "rule",
  "numeral",
  "baseline",
  "toc",
)
#let variants = text-variants + ("image",)

// The five variants that named the picture's place before `position` did.
// Each fails with the spelling that replaced it.
#let removed-image-variants = (
  "image-left": "left",
  "image-right": "right",
  "image-top": "top",
  "image-bottom": "bottom",
  "image-background": "background",
)

// The visual recipe for each designed variant, in one place.
//
// A variant is a composition, not just typography: it interleaves text tiers
// with explicit spacers and rules, and a `v(0.24em)` is not something a show
// rule can reach. So the measurements live here as named internal constants
// rather than as literals buried in the rendering. They are design decisions,
// not API: a deck that wants different geometry draws its own layout.
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
#let section-tokens = (
  plain: (
    number-size: 0.65em,
    // An em of the cell's display type, like every other subtitle below: the
    // subtitle is a caption under the title, never a second title.
    subtitle-size: 0.44em,
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

// The image variant composes its text exactly as `plain` does, so it shares
// that entry rather than repeating it.
#let variant-tokens(variant) = (
  section-tokens.at(variant, default: section-tokens.plain)
)

#let validate-fields(fields, allow-auto: false) = {
  let fields = validate-accent(fields, "section", allow-auto: allow-auto)
  if fields.variant in removed-image-variants {
    fail(
      "layout \"section\" variant " + repr(fields.variant)
        + " was removed; write variant: \"image\", position: "
        + repr(removed-image-variants.at(fields.variant)),
    )
  }
  _ = validate-variant(fields.variant, variants, "layout \"section\"")
  for name in ("subtitle", "number") {
    let value = fields.at(name)
    if value != none and type(value) not in (content, str) {
      fail("layout \"section\" " + name + " must be content, a string, or none")
    }
  }
  validate-image-fields(fields, "layout \"section\"")
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
/// - `plain`: one centered `section` cell. The default of this constructor; a
///   theme's own `layouts.section` and its automatic headings may select
///   another.
/// - `rule`: a heavy full-width rule with the title hanging beneath it, flush
///   left, the number above the rule.
/// - `numeral`: the section number set enormous in the line color, bleeding
///   off the top-right edge behind a lower-left title stack.
/// - `baseline`: title flush left and number flush right sharing one
///   baseline, tied together by a full-width hairline.
/// - `toc`: every section in the deck listed, the current one alive with its
///   number, the others ghosted.
/// - `image`: the `plain` composition with a picture, placed by `position`.
///   Requires `image`.
///
/// The designed text variants (`rule`, `numeral`, `baseline`, `toc`) treat an
/// omitted `number` as the automatic section counter, so they need no argument
/// in the ordinary case. They are compositions of type alone and take no
/// picture.
///
/// *Pictures*
///
/// `variant` names the text design and `position` names the picture's place,
/// in the vocabulary every layout with a picture shares:
///
/// - `"left"`, `"right"`, `"top"`, `"bottom"`: the section cell beside or
///   above a full-bleed `image` cell, sized by `tracks`. `auto` means
///   `"left"`.
/// - `"background"`: the section text directly over a full-slide picture.
///
/// *Labels*
///
/// Every resolved cell carries a label, so appearance comes from native Typst
/// rules:
///
/// - `mosaic-cell-section`: the section text, in every variant. The number and
///   subtitle are composed inside it, so one rule reaches the whole stack.
/// - `mosaic-cell-image`: the picture, at the four directional positions. At
///   `"background"` the picture is the section cell's background instead, so
///   it has no image cell of its own.
///
/// Three further labels are not cells. They mark the tiers composed inside
/// the section cell, so one tier can be restyled without the others:
/// `mosaic-section-title` on the title text, `mosaic-section-number` on the
/// number, and `mosaic-section-subtitle` on the subtitle.
///
/// ```typ
/// #show label("mosaic-section-title"): set text(style: "italic")
/// ```
///
/// *Styling*
///
/// The layout is structural. The centered arrangement and title typography come
/// from the `<mosaic-cell-section>` label rules `setup` emits. Over a
/// photograph the text inherits the surrounding native text color, so quiet the
/// picture with the `scrim` argument of `components.image` and override the
/// cell's text fill.
///
/// ```typ
/// #show label("mosaic-cell-section"): set text(fill: white)
/// #mosaic.slide(
///   layout: "section",
///   variant: "image",
///   position: "background",
///   image: mosaic.components.image(
///     path("cover.webp"),
///     scrim: black.transparentize(55%),
///   ),
/// )[Structure]
/// ```
///
/// -> dictionary
#let section(
  /// Optional subtitle set below the section title.
  /// -> content | str | none
  subtitle: none,
  /// Optional section number or label. `plain` and `image` set it above the
  /// title and omit it when `none`; the designed text variants build their
  /// composition around it and read the automatic section counter when it is
  /// `none`.
  /// -> content | str | none
  number: none,
  /// The picture of the `image` variant, required there and rejected by the
  /// others. Give a native `path(..)` value, which fills its region, or
  /// ready-made content such as `components.image(path(..), scrim: ..)`,
  /// whose `scrim` quiets the photograph enough to read text over it. A bare
  /// string is rejected: it would resolve inside the package rather than in
  /// the deck's project.
  /// -> none | content | path
  image: none,
  /// The text design: `plain`, `rule`, `numeral`, `baseline`, `toc`, or
  /// `image`.
  /// -> str
  variant: "plain",
  /// Where the `image` variant's picture sits, and rejected by the others:
  /// `"left"`, `"right"`, `"top"`, `"bottom"`, or `"background"`. `auto`
  /// means `"left"`.
  /// -> auto | str
  position: auto,
  /// Color of the section number, in every variant that draws one. `auto`
  /// keeps the number subordinate to the title: the semantic muted color
  /// resolved by `setup`, or the line color for the `numeral` variant, whose
  /// number is texture rather than text. Pass a color to override either. The
  /// `baseline` variant ties its number to the title with a hairline, which
  /// takes the same color and defaults to the semantic accent. `plain` and
  /// `image` draw a number only when `number` is given, so without one there
  /// is nothing for the color to reach.
  /// -> color | auto
  accent: auto,
  /// Sizes the split of a directional position, and is rejected elsewhere.
  /// One native Typst track size sizes the picture and is side-independent, so
  /// the `left` and `right` positions stay mirror images; the section region
  /// takes the remaining `1fr`. An array of two is in visual order instead,
  /// and must be mirrored by hand when the position flips. `auto` splits the
  /// slide evenly.
  /// -> auto | length | ratio | relative | fraction | array
  tracks: auto,
) = {
  let fields = validate-fields((
    subtitle: subtitle,
    number: number,
    image: image,
    variant: variant,
    position: position,
    accent: accent,
    tracks: tracks,
  ), allow-auto: true)
  make-layout("section", fields)
}

// The designed text variants build their composition around the section
// number, so an omitted `number` means the automatic section counter rather
// than nothing. The counter zero-pads to two digits, the editorial spelling
// the numeric variants use.
#let auto-number(number) = if number != none {
  as-content(number)
} else {
  context {
    let n = logical-section.get().first()
    if n < 10 [0#str(n)] else [#str(n)]
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
//
// The transform is declared through `decorate-heading` rather than as a bare
// `show heading` rule. A slide with several frames carries its real heading on
// one of them only, and a bare transforming rule has nothing to match on the
// others, which would then set the title at the theme's own heading size.
// A declared decoration is replayed on every frame. It reads `.body`, which
// the heading and its stand-in block both carry.
//
// The title is a labeled tier like the number and the subtitle, so
// `show label("mosaic-section-title"): set text(..)` restyles it alone. The
// label sits on the context element, inside the variant's own treatment: a
// rule on it is read by the capture below and therefore reaches a heading
// body and a plain body alike.
#let title-text(body, styles) = text(..styles, [#context {
  let size = text.size
  let rest = styles
  _ = rest.remove("size", default: none)
  show: decorate-heading.with(it => text(size: size, ..rest, it.body))
  body
}<mosaic-section-title>])

// The same label for the `plain` composition, which states no treatment of
// its own: the cell's label rules style the body, and this only names it.
#let plain-title(body) = [#context body<mosaic-section-title>]

// The title treatment every designed variant states from its own tokens. The
// toc variant styles its entries differently and calls title-text itself.
#let variant-title(body, tokens) = title-text(body, (
  size: tokens.title-size,
  weight: tokens.title-weight,
  tracking: tokens.title-tracking,
))

// Subordinate subtitle line for the designed variants. Sizes are em against
// the section cell's display type, so a theme that rescales the deck rescales
// the composition with it. The muted fill yields to a recolored cell through
// `adapt-fill`.
#let subtitle-line(fields, settings, size: 0.44em) = if fields.subtitle == none {
  []
} else {
  [#context text(
    ..adapt-fill((fill: settings.colors.muted, size: size), settings),
    as-content(fields.subtitle),
  )<mosaic-section-subtitle>]
}

// The section number as a labeled tier, so a theme can restyle it without
// reaching into the variant's composition.
#let number-text(body, styles) = [#text(..styles, body)<mosaic-section-number>]

// A heavy full-width rule with the heading stack hanging beneath it, everything
// flush left. The rule carries the design; the number sits above it like a
// running head.
#let resolve-rule-section(fields, settings, tokens) = make-cell(
  id: "section",
  style: (
    align: left + horizon,
    inset: settings.spacing.inset,
    map: body => {
      set par(spacing: tokens.paragraph-spacing)
      number-text(
        auto-number(fields.number),
        (
          size: tokens.number-size,
          weight: tokens.number-weight,
          fill: fields.accent,
        ),
      )
      v(tokens.gap-below-number)
      line(length: 100%, stroke: tokens.rule-thickness + settings.colors.text)
      v(tokens.gap-below-rule)
      variant-title(body, tokens)
      v(tokens.gap-below-title)
      subtitle-line(fields, settings, size: tokens.subtitle-size)
    },
  ),
)

// The section number set enormous in the line color, bleeding off the
// top-right edge. It reads as texture rather than text and counterweights the
// lower-left title stack.
#let resolve-numeral-section(fields, settings, tokens) = make-cell(
  id: "section",
  style: (
    align: left,
    inset: settings.spacing.inset,
    background: place(
      top + right,
      dx: tokens.number-dx,
      dy: tokens.number-dy,
      number-text(
        auto-number(fields.number),
        (
          size: tokens.number-size,
          weight: tokens.number-weight,
          tracking: tokens.number-tracking,
          // Texture by default; an explicit accent is the author's choice.
          fill: if fields.number-accent == none {
            settings.colors.line
          } else {
            fields.number-accent
          },
        ),
      ),
    ),
    map: body => {
      set par(
        spacing: tokens.paragraph-spacing,
        leading: tokens.paragraph-leading,
      )
      v(1fr)
      variant-title(body, tokens)
      v(tokens.gap-below-title)
      subtitle-line(fields, settings, size: tokens.subtitle-size)
      v(tokens.gap-below-subtitle)
    },
  ),
)

// Title and number share one baseline, tied together by a full-width
// hairline: title flush left in bold, number flush right in a thin weight of
// the same size. The subtitle hangs under the rule like a caption.
#let resolve-baseline-section(fields, settings, tokens) = make-cell(
  id: "section",
  style: (
    align: left + horizon,
    inset: settings.spacing.inset,
    map: body => {
      set par(
        spacing: tokens.paragraph-spacing,
        leading: tokens.paragraph-leading,
      )
      grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        column-gutter: tokens.gutter,
        variant-title(body, tokens),
        number-text(
          auto-number(fields.number),
          (
            size: tokens.number-size,
            weight: tokens.number-weight,
            fill: fields.accent,
          ),
        ),
      )
      v(tokens.gap-above-rule)
      // The tie between title and number takes the semantic accent by
      // default: it is the one drawn gesture of the variant, and the number
      // above it already holds the subordinate muted color. An explicit
      // `accent:` recolors the pair, number and tie together.
      // The tie is drawn at the shared component rule weight, so the section
      // baseline, the progress bars, and the dividers read as one gesture.
      line(
        length: 100%,
        stroke: component-tokens.rule-thickness + if fields.number-accent == none {
          settings.colors.accent
        } else {
          fields.number-accent
        },
      )
      v(tokens.gap-below-rule)
      subtitle-line(fields, settings, size: tokens.subtitle-size)
    },
  ),
)

// The divider shows the whole deck: every section listed, past and future
// ones ghosted in the line color, the current one alive with its accent
// number. Reads the <mosaic-section-record> records the slide runtime emits,
// one per section slide.
#let resolve-toc-section(fields, settings, tokens) = make-cell(
  id: "section",
  style: (
    align: left + horizon,
    // A deck with many sections shrinks the list to fit rather than clipping.
    fit: "contain",
    inset: settings.spacing.inset,
    map: body => context {
      let mine = logical-section.get().first()
      let current = grid(
        columns: (auto, 1fr),
        column-gutter: tokens.gutter,
        align: (left + bottom, left + bottom),
        number-text(
          auto-number(fields.number),
          (
            size: tokens.item-size,
            weight: tokens.current-weight,
            fill: fields.accent,
          ),
        ),
        title-text(body, (
          size: tokens.item-size,
          weight: tokens.current-weight,
        )),
      )
      let numbers = query(label("mosaic-section-record"))
        .map(entry => (
          number: logical-section.at(entry.location()).first(),
          title: entry.value.title,
        ))
      // The current section is drawn from the slide's own body, never from
      // its record, so it survives a slide the records do not list and is
      // realized exactly once.
      let others(keep) = numbers.filter(entry => keep(entry.number)).map(entry => text(
        size: tokens.item-size,
        weight: tokens.other-weight,
        fill: settings.colors.line,
        if entry.title == none { [] } else { entry.title },
      ))
      stack(
        spacing: tokens.item-spacing,
        ..others(n => n < mine),
        current,
        ..others(n => n > mine),
      )
      if fields.subtitle != none {
        v(tokens.gap-above-subtitle)
        subtitle-line(fields, settings, size: tokens.subtitle-size)
      }
    },
  ),
)

// The designed text variants, dispatched by name; `plain` and `image` share
// the one composition below instead.
#let designed-section-resolvers = (
  rule: resolve-rule-section,
  numeral: resolve-numeral-section,
  baseline: resolve-baseline-section,
  toc: resolve-toc-section,
)

#let resolve-section(command, settings) = {
  let fields = validate-fields(command.fields + (
    // Numbers are subordinate furniture, never the deck's accent: `auto`
    // resolves to the muted color, and an explicit accent stays an override.
    accent: if command.fields.accent == auto { settings.colors.muted } else { command.fields.accent },
  ))
  // The numeral variant defaults its number to the line color rather than the
  // muted one, so it needs to know whether the accent was the author's.
  let fields = fields + (
    number-accent: if command.fields.accent == auto { none } else { command.fields.accent },
  )
  let image = optional-fixed-image(fields.image, "layout \"section\" image")
  let tokens = variant-tokens(fields.variant)
  if fields.variant in designed-section-resolvers {
    return designed-section-resolvers.at(fields.variant)(fields, settings, tokens)
  }
  let before = if fields.number != none {
    number-text(
      as-content(fields.number),
      (size: tokens.number-size, fill: fields.accent),
    )
    parbreak()
  } else {
    []
  }
  let after = if fields.subtitle == none {
    []
  } else {
    block(
      above: settings.spacing.compact-gap,
      subtitle-line(fields, settings, size: tokens.subtitle-size),
    )
  }
  // Structural only: the section cell's arrangement and title typography come
  // from the <mosaic-cell-section> label rules the active theme emits.
  let section-cell = make-cell(
    id: "section",
    style: (
      before: before,
      after: after,
      map: plain-title,
      fit: "width",
      inset: settings.spacing.inset,
    ),
  )
  if fields.variant != "image" {
    return section-cell
  }
  let position = resolve-image-position(fields)
  if position in directional-positions {
    // No gutter, as in the title and image layouts: the picture is its own
    // edge, and the section cell already keeps the deck inset, so a recolored
    // cell reaches the picture rather than stopping short of it. The cell
    // fills its region like the plain one, so that same recoloring paints the
    // whole region and not a strip around the text.
    directional-image-layout(
      position,
      image-cell(image),
      section-cell,
      tracks: fields.tracks,
    )
  } else {
    image-background-cell(section-cell, image)
  }
}
