// An `auto` track sizes to its child's content on both axes, whether the child
// is a cell or a nested split. Regressions:
// - A split in an `auto` row filled the whole slide, pushing every later track
//   off the page without an overflow report.
// - A cell in an `auto` column took the full slide width, squeezing its `1fr`
//   siblings to nothing.
// Cells side by side in an `auto` row also share the row's height, so a header
// bar and a logo cell beside it paint one strip, and cells anywhere below an
// `auto` row take the compact inset like a plain `auto`-row header does.
#import "@local/mosaic:0.0.3" as mosaic
#import mosaic.themes.metropolis as m

#show: m.setup.with(spacing: (compact-inset: 10pt))

// Page 1: a header beside a logo that is taller than the header text, in an
// `auto` row; an `auto` side column in the body; a two-row footer split in an
// `auto` row.
#let logo-header = m.grids.rows(
  tracks: (auto, 1fr, auto),
  m.grids.columns(
    tracks: (1fr, auto),
    "header",
    m.grids.cell("logo", content: text(size: 2em)[LOGO]),
  ),
  m.grids.columns(tracks: (1fr, auto), "main", "side"),
  m.grids.rows("foot-a", "foot-b"),
)
#m.slide(layout: logo-header)[== Logo][Main][Side][Foot A][Foot B]

// Page 2: the same nested header with a logo no taller than the heading, next
// to a plain `auto`-row header on page 3. Compact insets on both sides make
// the two strips the same depth.
#let small-logo = m.grids.rows(
  tracks: (auto, 1fr),
  m.grids.columns(
    tracks: (1fr, auto),
    "header",
    m.grids.cell("logo", content: text(size: 0.5em)[L]),
  ),
  "body",
)
#m.slide(layout: small-logo)[== Strip][Body]
#m.slide(layout: m.grids.rows(tracks: (auto, 1fr), "header", "body"))[== Strip][Body]

// Pages 4-7: an incremental split in an `auto` row appears on step two and
// sizes to its content once it is there. Removed before its step (pages
// 4-5), it leaves no space; hidden (pages 6-7), it keeps its measured space,
// so the body does not jump. The header holds plain text because a heading
// may not sit in an incremental node.
#let revealed(before) = m.grids.rows(
  tracks: (auto, 1fr),
  m.steps.on("2-", before: before, m.grids.columns(
    tracks: (1fr, auto),
    "header",
    m.grids.cell("logo", content: [LOGO]),
  )),
  "body",
)
#m.slide(layout: revealed("removed"))[Removed][Body]
#m.slide(layout: revealed("hidden"))[Hidden][Body]

#let corner(id, name) = {
  let found = query(label("mosaic-cell-" + id + "-" + name))
  found.map(it => it.location().position())
}
#let one(id, name, page) = {
  let found = corner(id, name).filter(it => it.page == page)
  assert(found.len() == 1, message: id + "-" + name + " on page " + str(page) + ": " + repr(found))
  found.first()
}

#context {
  let slide-width = page.width
  let slide-height = page.height

  // The measuring pass is never placed: each cell is in the document once
  // per frame that renders it (page 4 removes it; page 6 hides it in place).
  let headers = corner("header", "top-left")
  assert(
    headers.map(it => it.page) == (1, 2, 3, 5, 6, 7),
    message: "header cells placed on pages " + repr(headers.map(it => it.page)),
  )

  // Page 1: the header row ends well above the slide's bottom edge, and the
  // body and footer tracks are on the page beneath it.
  let header-bottom = one("header", "bottom-left", 1).y
  assert(header-bottom < slide-height / 4, message: "header row too deep: " + repr(header-bottom))
  let main-top = one("main", "top-left", 1).y
  assert(main-top == header-bottom, message: "body starts at " + repr(main-top))
  let foot-b-bottom = one("foot-b", "bottom-left", 1).y
  assert(
    foot-b-bottom <= slide-height and foot-b-bottom > slide-height * 0.9,
    message: "footer ends at " + repr(foot-b-bottom),
  )
  let foot-a-bottom = one("foot-a", "bottom-left", 1).y
  let foot-b-top = one("foot-b", "top-left", 1).y
  assert(foot-a-bottom == foot-b-top, message: "footer rows overlap or gap")
  assert(one("main", "bottom-left", 1).y == one("foot-a", "top-left", 1).y)

  // Page 1: the header and the taller logo share one strip.
  assert(one("logo", "top-right", 1).y == one("header", "top-left", 1).y)
  assert(
    one("logo", "bottom-right", 1).y == header-bottom,
    message: "logo and header heights differ",
  )

  // Page 1: `auto` columns take their content's width, and the `1fr` sibling
  // takes the rest.
  let logo-left = one("logo", "top-left", 1).x
  assert(logo-left > slide-width * 0.6, message: "logo column too wide: starts at " + repr(logo-left))
  assert(one("header", "top-right", 1).x == logo-left)
  assert(one("logo", "top-right", 1).x == slide-width)
  let side-left = one("side", "top-left", 1).x
  assert(side-left > slide-width * 0.6, message: "side column too wide: starts at " + repr(side-left))
  assert(one("main", "top-right", 1).x == side-left)

  // Pages 2-3: the nested header strip is exactly as deep as a plain one.
  let nested = one("header", "bottom-left", 2).y
  let plain = one("header", "bottom-left", 3).y
  assert(nested == plain, message: "nested strip " + repr(nested) + " vs plain " + repr(plain))

  // Pages 4-5: before the reveal the body fills the slide; after it, the
  // revealed strip is content-sized and the body starts beneath it.
  let body-before = one("body", "top-left", 4).y
  let strip = one("header", "bottom-left", 5).y
  assert(strip < slide-height / 4, message: "revealed strip too deep: " + repr(strip))
  assert(one("body", "top-left", 5).y == strip)
  assert(body-before < strip, message: "body did not move down after the reveal")

  // Pages 6-7: a hidden strip already holds its measured space.
  let hidden-strip = one("header", "bottom-left", 6).y
  assert(hidden-strip == one("header", "bottom-left", 7).y)
  assert(one("body", "top-left", 6).y == one("body", "top-left", 7).y)
  assert(hidden-strip == strip, message: "hidden strip " + repr(hidden-strip) + " vs shown " + repr(strip))
}
