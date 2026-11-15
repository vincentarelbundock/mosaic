#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup

#let progress(variant, color) = if variant == "line" {
  [#place(bottom + left)[
    #mosaic.components.progress(
      variant: "line",
      width: 100%,
      thickness: 0.12em,
      accent: color,
    )
  ]]
} else {
  [#place(bottom + right, dx: -1.25em, dy: -0.35em)[
    #mosaic.components.progress(
      variant: variant,
      width: 1em,
      thickness: 0.12em,
      accent: color,
    )
  ]]
}

#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body"),
  foreground: progress("1/1", rgb("#d97706")),
)[
  == Foreground number
][
  The number is ordinary foreground content.
]

// The footer is filled by name: positional bodies never reach it.
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body-footer"),
  foreground: progress("circle", rgb("#ffffff")),
  cells: (
    header: [== White circle],
    body: [The circle is composed with the public progress component.],
    footer: [Footer],
  ),
)

#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body-footer"),
  foreground: progress("circle", rgb("#fedcba")),
  cells: (
    header: [== Styled circle],
    body: [Explicit component color styles progress.],
    footer: [Styled footer],
  ),
)

#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body"),
  foreground: progress("line", rgb("#123456")),
)[
  == Foreground line
][
  The line is ordinary foreground content.
]

#mosaic.slide(
  layout: mosaic.layouts.content(variant: "header-body"),
  foreground: none,
)[
  == No progress
][
  `none` adds no foreground content.
]

#context assert(counter(page).final().first() == 5)
