// Quotation treatment with optional attribution.
#import "../shared.typ": fail
#import "card.typ": card-panel
#import "style.typ": component-tokens, deck-colors, role-colors
#import "../incremental/container.typ": make-container

#let _native-quote = quote

/// Creates a quotation treatment with optional attribution.
///
/// The quotation sits in a lightly tinted `card`; attribution and source share
/// one right-aligned line beneath it, joined by a comma when both are present.
///
/// ```typ
/// #mosaic.components.quote(
///   attribution: [Ada Lovelace],
///   source: [Notes on the Analytical Engine, 1843],
/// )[
///   The Analytical Engine weaves algebraic patterns.
/// ]
/// ```
///
/// To set a portrait beside the quotation, compose one natively:
///
/// ```typ
/// #grid(
///   columns: (auto, 1fr),
///   gutter: 0.6em,
///   mosaic.components.image(path("ada.webp"), width: 4em, height: 4em),
///   mosaic.components.quote(attribution: [Ada Lovelace])[...],
/// )
/// ```
///
/// *Roles*
///
/// A plain quotation carries no border at all. Naming a role other than
/// `neutral`, or passing `accent`, hangs the quotation on a rail down its left
/// edge in that color, the way a pull quote is marked in print.
///
/// ```typ
/// #mosaic.components.quote(role: "accent")[
///   Bounded work beats unbounded intent.
/// ]
/// ```
///
/// *The native quote*
///
/// This is a superset of Typst's own `quote`: `block`, `quotes`, and
/// `attribution` keep their native meaning, and the quoted text is a native
/// `quote` element inside the panel, so a deck's `show quote` rules and the
/// document's structure see a quotation. `block` defaults to `true` here,
/// because the component is a panel; `block: false` gives the plain inline
/// quotation Typst would, with no panel, and the panel's own arguments then
/// have nothing to apply to. `quotes: auto` follows the native rule, which
/// adds quotation marks to an inline quotation and none to a block.
///
/// ```typ
/// #mosaic.components.quote(quotes: true, attribution: <lovelace1843>)[
///   The Analytical Engine weaves algebraic patterns.
/// ]
/// ```
///
/// See `card` for the list of roles and the full list of overrides.
///
/// -> content
#let quote(
  /// The quoted text.
  /// -> content
  body,
  /// Whether this is a block quotation, drawn as a panel, or an inline one,
  /// drawn as Typst draws it.
  /// -> bool
  block: true,
  /// Whether to wrap the text in quotation marks. `auto` adds them to an
  /// inline quotation only.
  /// -> auto | bool
  quotes: auto,
  /// Who is being quoted, set on the fine-print line below the quotation. A
  /// label cites that bibliography entry, as it does natively.
  /// -> content | label | none
  attribution: none,
  /// Where the quotation comes from, appended after the attribution.
  /// -> content | none
  source: none,
  /// Semantic role name: `neutral`, `accent`, `warning`, or `error`. Any role
  /// but `neutral` draws the left rail in that role's color.
  /// -> str
  role: "neutral",
  /// Panel fill. `auto` is a faint wash of the deck's text color.
  /// -> auto | color | gradient | tiling | none
  fill: auto,
  /// Rail color. `auto` uses the role's own color, and draws no rail under
  /// the `neutral` role.
  /// -> auto | color
  accent: auto,
  /// Border stroke. `auto` draws the left rail when a role or an `accent`
  /// asks for one and nothing otherwise; an explicit stroke replaces the rail.
  /// -> auto | stroke | dictionary | none
  stroke: auto,
  /// Corner radius. `auto` uses the shared component radius.
  /// -> auto | length | dictionary
  radius: auto,
  /// Padding inside the panel. `auto` uses the shared component inset.
  /// -> auto | length | relative | dictionary
  inset: auto,
  /// Horizontal alignment of the body. `auto` is `left`.
  /// -> auto | alignment
  align: auto,
  /// Native `text` arguments merged over the role's text color.
  /// -> dictionary
  text: (:),
  /// Further named arguments forwarded unchanged to the native `quote`.
  /// -> arguments
  ..native,
) = {
  if native.pos().len() != 0 {
    fail("quote takes one body; further arguments must be named")
  }
  if type(block) != bool {
    fail("quote block must be a boolean, received " + repr(block))
  }
  if quotes != auto and type(quotes) != bool {
    fail("quote quotes must be auto or a boolean, received " + repr(quotes))
  }
  if not block {
    // An inline quotation is the native element and nothing else. The source
    // has no place in a run of text, so it is refused rather than dropped.
    if source != none {
      fail("quote source applies only to a block quotation")
    }
    return make-container((body: body), render: parts => _native-quote(
      block: false,
      quotes: quotes,
      attribution: attribution,
      ..native,
      parts.body,
    ))
  }
  // A label is resolved by the citation it names, not by anything a walk
  // could step through, so only a content attribution is a part.
  let parts = (
    body: body,
    attribution: if type(attribution) == label { none } else { attribution },
    source: source,
  )
  make-container(parts, render: parts => context {
    // The tint is the deck's own text color laid over the canvas, not a fixed
    // black: on a dark deck a black tint is invisible, while a tint of the
    // text color reads as the same faint lift in either direction. Pass
    // `fill` to replace it outright.
    let tint = deck-colors().text
    // The rail is the only place a quotation shows its role, so a neutral
    // quotation with no accent of its own stays the bare wash it always was.
    let rail = if accent != auto {
      accent
    } else if role != "neutral" {
      role-colors(role).accent
    } else {
      none
    }
    let stroke = if stroke != auto {
      stroke
    } else if rail == none {
      none
    } else {
      (left: component-tokens.callout-rail + rail, rest: none)
    }
    let credit = if type(attribution) == label {
      cite(attribution)
    } else {
      parts.attribution
    }
    card-panel(
      role: role,
      fill: if fill == auto {
        tint.transparentize(component-tokens.quote-tint)
      } else {
        fill
      },
      accent: accent,
      stroke: stroke,
      radius: radius,
      inset: inset,
      align: align,
      text: text,
    )[
      // The native element carries the quotation marks and the meaning; the
      // panel draws the attribution itself, so none is handed over.
      #_native-quote(block: false, quotes: quotes == true, ..native, parts.body)
      #if credit != none or parts.source != none {
        // `block(above:)` rather than a `linebreak()` followed by block-level
        // content: that stacked an empty line on top of the paragraph break
        // before the block, leaving the attribution floating far below the
        // quotation.
        std.block(above: component-tokens.quote-attribution-gap, width: 100%, std.align(right)[
          #std.text(size: component-tokens.quote-attribution-size)[
            // Joined in code mode: separate markup lines would each contribute
            // a newline, setting a space before the comma.
            #{
              if credit != none { credit }
              if credit != none and parts.source != none { [, ] }
              if parts.source != none { parts.source }
            }
          ]
        ])
      }
    ]
  })
}
