// Named semantic color schemes and categorical palettes.
#import "shared.typ": fail

/// Returns a complete named semantic color scheme for `mosaic.setup(colors: ...)`.
///
/// Includes neutral foundations and presentation-focused visual directions.
///
/// -> dictionary
#let scheme(
  /// Color scheme name.
  /// -> str
  name,
) = {
  let schemes = (
    light: (
      canvas: rgb("#fafaf9"),
      surface: white,
      accent: rgb("#2563eb"),
      text: rgb("#1c1917"),
      inverse-text: white,
      muted: rgb("#78716c"),
      line: rgb("#e7e5e4"),
    ),
    dark: (
      canvas: rgb("#111827"),
      surface: rgb("#1f2937"),
      accent: rgb("#60a5fa"),
      text: rgb("#f3f4f6"),
      inverse-text: rgb("#111827"),
      muted: rgb("#9ca3af"),
      line: rgb("#374151"),
    ),
    gallery: (
      canvas: rgb("#f4f0e8"),
      surface: rgb("#fffefa"),
      accent: rgb("#17324d"),
      text: rgb("#20262d"),
      inverse-text: white,
      muted: rgb("#646d76"),
      line: rgb("#d6d0c5"),
    ),
    editorial: (
      canvas: rgb("#f7f3ec"),
      surface: white,
      accent: rgb("#a3312d"),
      text: rgb("#211f1c"),
      inverse-text: white,
      muted: rgb("#716a61"),
      line: rgb("#d9d1c5"),
    ),
    botanical: (
      canvas: rgb("#f3f4ed"),
      surface: rgb("#fcfdf8"),
      accent: rgb("#315c49"),
      text: rgb("#202721"),
      inverse-text: white,
      muted: rgb("#687268"),
      line: rgb("#d4d9cf"),
    ),
    studio: (
      canvas: rgb("#f7f1f5"),
      surface: rgb("#fffdfe"),
      accent: rgb("#673a61"),
      text: rgb("#2b222a"),
      inverse-text: white,
      muted: rgb("#756a73"),
      line: rgb("#ddd1da"),
    ),
    conference: (
      canvas: rgb("#f4f6fb"),
      surface: white,
      accent: rgb("#2447a8"),
      text: rgb("#202536"),
      inverse-text: white,
      muted: rgb("#687087"),
      line: rgb("#d7ddea"),
    ),
    spotlight: (
      canvas: rgb("#171a21"),
      surface: rgb("#232733"),
      accent: rgb("#d9a441"),
      text: rgb("#f5f1e8"),
      inverse-text: rgb("#171a21"),
      muted: rgb("#b3b7c1"),
      line: rgb("#3a404c"),
    ),
  )
  if type(name) != str or name not in schemes {
    fail(
      "unknown color scheme " + repr(name)
        + "; available schemes: " + schemes.keys().map(repr).join(", "),
    )
  }
  schemes.at(name)
}

#let positional-palette(colors) = {
  let record = (:)
  for (index, value) in colors.enumerate() {
    record.insert("color-" + str(index + 1), value)
  }
  record
}

#let palette-records = (
  // Okabe and Ito's Color Universal Design palette, black variant.
  // https://jfly.uni-koeln.de/color/
  "okabe-ito": (
    orange: rgb("#E69F00"),
    sky-blue: rgb("#56B4E9"),
    bluish-green: rgb("#009E73"),
    yellow: rgb("#F0E442"),
    blue: rgb("#0072B2"),
    vermilion: rgb("#D55E00"),
    reddish-purple: rgb("#CC79A7"),
    black: rgb("#000000"),
  ),
  // Paul Tol, Colour schemes and layouts, qualitative schemes.
  // https://sronpersonalpages.nl/~pault/
  "tol-bright": (
    blue: rgb("#4477AA"),
    red: rgb("#EE6677"),
    green: rgb("#228833"),
    yellow: rgb("#CCBB44"),
    cyan: rgb("#66CCEE"),
    purple: rgb("#AA3377"),
    grey: rgb("#BBBBBB"),
  ),
  "tol-muted": (
    rose: rgb("#CC6677"),
    indigo: rgb("#332288"),
    sand: rgb("#DDCC77"),
    green: rgb("#117733"),
    cyan: rgb("#88CCEE"),
    wine: rgb("#882255"),
    teal: rgb("#44AA99"),
    olive: rgb("#999933"),
    purple: rgb("#AA4499"),
  ),
  // Cynthia Brewer's ColorBrewer qualitative schemes (Apache-2.0).
  // https://colorbrewer2.org/
  "brewer-dark2": (
    teal: rgb("#1B9E77"),
    orange: rgb("#D95F02"),
    purple: rgb("#7570B3"),
    magenta: rgb("#E7298A"),
    green: rgb("#66A61E"),
    mustard: rgb("#E6AB02"),
    brown: rgb("#A6761D"),
    gray: rgb("#666666"),
  ),
  "brewer-set2": (
    teal: rgb("#66C2A5"),
    coral: rgb("#FC8D62"),
    periwinkle: rgb("#8DA0CB"),
    pink: rgb("#E78AC3"),
    lime: rgb("#A6D854"),
    yellow: rgb("#FFD92F"),
    tan: rgb("#E5C494"),
    gray: rgb("#B3B3B3"),
  ),
  "brewer-paired": (
    light-blue: rgb("#A6CEE3"),
    blue: rgb("#1F78B4"),
    light-green: rgb("#B2DF8A"),
    green: rgb("#33A02C"),
    light-red: rgb("#FB9A99"),
    red: rgb("#E31A1C"),
    light-orange: rgb("#FDBF6F"),
    orange: rgb("#FF7F00"),
    light-purple: rgb("#CAB2D6"),
    purple: rgb("#6A3D9A"),
    light-yellow: rgb("#FFFF99"),
    brown: rgb("#B15928"),
  ),
  // CARTOColors qualitative schemes (CC BY 4.0), using each complete
  // 12-color variant displayed at https://carto.com/carto-colors/.
  // https://github.com/CartoDB/CartoColor
  // Qualitative schemes.
  "carto-antique": positional-palette((
    rgb("#855C75"),
    rgb("#D9AF6B"),
    rgb("#AF6458"),
    rgb("#736F4C"),
    rgb("#526A83"),
    rgb("#625377"),
    rgb("#68855C"),
    rgb("#9C9C5E"),
    rgb("#A06177"),
    rgb("#8C785D"),
    rgb("#467378"),
    rgb("#7C7C7C"),
  )),
  // Preserve the established Mosaic aliases for these two schemes.
  "carto-bold": (
    purple: rgb("#7F3C8D"),
    green: rgb("#11A579"),
    blue: rgb("#3969AC"),
    yellow: rgb("#F2B701"),
    pink: rgb("#E73F74"),
    light-green: rgb("#80BA5A"),
    orange: rgb("#E68310"),
    teal: rgb("#008695"),
    magenta: rgb("#CF1C90"),
    coral: rgb("#F97B72"),
    indigo: rgb("#4B4B8F"),
    gray: rgb("#A5AA99"),
  ),
  "carto-pastel": positional-palette((
    rgb("#66C5CC"),
    rgb("#F6CF71"),
    rgb("#F89C74"),
    rgb("#DCB0F2"),
    rgb("#87C55F"),
    rgb("#9EB9F3"),
    rgb("#FE88B1"),
    rgb("#C9DB74"),
    rgb("#8BE0A4"),
    rgb("#B497E7"),
    rgb("#D3B484"),
    rgb("#B3B3B3"),
  )),
  "carto-prism": positional-palette((
    rgb("#5F4690"),
    rgb("#1D6996"),
    rgb("#38A6A5"),
    rgb("#0F8554"),
    rgb("#73AF48"),
    rgb("#EDAD08"),
    rgb("#E17C05"),
    rgb("#CC503E"),
    rgb("#94346E"),
    rgb("#6F4070"),
    rgb("#994E95"),
    rgb("#666666"),
  )),
  "carto-safe": (
    sky-blue: rgb("#88CCEE"),
    rose: rgb("#CC6677"),
    sand: rgb("#DDCC77"),
    green: rgb("#117733"),
    indigo: rgb("#332288"),
    purple: rgb("#AA4499"),
    teal: rgb("#44AA99"),
    olive: rgb("#999933"),
    wine: rgb("#882255"),
    brown: rgb("#661100"),
    blue: rgb("#6699CC"),
    gray: rgb("#888888"),
  ),
  "carto-vivid": positional-palette((
    rgb("#E58606"),
    rgb("#5D69B1"),
    rgb("#52BCA3"),
    rgb("#99C945"),
    rgb("#CC61B0"),
    rgb("#24796C"),
    rgb("#DAA51B"),
    rgb("#2F8AC4"),
    rgb("#764E9F"),
    rgb("#ED645A"),
    rgb("#CC3A8E"),
    rgb("#A5AA99"),
  )),
)

#let palette-record(name) = {
  if type(name) != str or name not in palette-records {
    fail(
      "unknown palette " + repr(name)
        + "; available palettes: " + palette-records.keys().map(repr).join(", "),
    )
  }
  palette-records.at(name)
}

/// Returns a named categorical palette, optionally transformed as a whole.
///
/// Pass `color` as a zero-based integer index or stable color name to return one
/// color instead of the complete array.
///
/// Available palettes include qualitative systems from Okabe–Ito, Paul Tol,
/// ColorBrewer, and CARTOColors.
///
/// -> array | color
#let palette(
  /// Palette name.
  /// -> str
  name,
  /// Zero-based index or stable color name to select, or `none` for all colors.
  /// -> int | str | none
  color: none,
  /// Amount by which to lighten every color.
  /// -> ratio | none
  lighten: none,
  /// Amount by which to darken every color.
  /// -> ratio | none
  darken: none,
) = {
  if lighten != none and darken != none {
    fail("palette accepts either lighten or darken, not both")
  }

  let record = palette-record(name)
  let transformed = (:)
  for (key, value) in record {
    transformed.insert(
      key,
      if lighten != none {
        value.lighten(lighten)
      } else if darken != none {
        value.darken(darken)
      } else {
        value
      },
    )
  }

  if color == none {
    transformed.values()
  } else if type(color) == int {
    let values = transformed.values()
    if color < 0 or color >= values.len() {
      fail(
        "palette color index " + repr(color) + " out of range for "
          + repr(name) + "; expected 0 through " + str(values.len() - 1),
      )
    }
    values.at(color)
  } else if type(color) == str and color in transformed {
    transformed.at(color)
  } else {
    fail(
      "unknown color " + repr(color) + " in palette " + repr(name)
        + "; available names: " + record.keys().map(repr).join(", "),
    )
  }
}
