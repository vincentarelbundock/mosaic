// Private Dark theme design tokens.
// `colors` is this theme's stable palette export and carries exactly the six
// canonical roles. The named constants above it are private mixing values:
// a derived theme should extend `colors`, never reach for them by name.
#let canvas = rgb("#0d1117")
#let surface = rgb("#161b22")
#let text = rgb("#e6edf3")
#let muted = rgb("#8b949e")
#let accent = rgb("#58a6ff")
#let secondary = rgb("#bc8cff")
#let attention = rgb("#d29922")
#let error = rgb("#ff7b72")
#let line = rgb("#30363d")
#let colors = (
  canvas: canvas,
  surface: surface,
  accent: accent,
  text: text,
  muted: muted,
  line: line,
)

// The complete semantic component palette. Dark states it as data here rather
// than as a parallel component module: the components take their geometry from
// the base defaults and their colors from this table.
//
// `information` aliases `accent`, as in the light palette.
#let _accent-role = (fill: rgb("#13233a"), accent: accent, text: text)
#let roles = (
  neutral: (fill: surface, accent: line, text: text),
  accent: _accent-role,
  information: _accent-role,
  success: (fill: rgb("#102a22"), accent: rgb("#56d364"), text: text),
  warning: (fill: rgb("#2f2710"), accent: attention, text: text),
  danger: (fill: rgb("#321b1e"), accent: error, text: text),
  takeaway: (fill: rgb("#241d33"), accent: secondary, text: text),
)
