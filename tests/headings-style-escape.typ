#import "@local/mosaic:0.0.3" as mosaic

// A heading written inside a scoped block keeps that block's styles, and
// content written after the block, outside it, does not inherit them: the
// slide is no longer wrapped whole in the heading's styles.
#show: mosaic.setup.with(
  paper: (width: 160pt, height: 90pt),
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

= Section

#[
  #set text(style: "italic")
  == Scoped heading #context [#metadata(text.style) <heading-style>]

  Inside the block. #context [#metadata(text.style) <inside-style>]
]

Outside the block. #context [#metadata(text.style) <outside-style>]

#[
  #set text(style: "italic")
  = Scoped section
]

Tagline outside. #context [#metadata(text.style) <tagline-style>]

#context {
  let style(target) = query(target).first().value
  assert(style(<heading-style>) == "italic")
  assert(style(<inside-style>) == "italic")
  assert(style(<outside-style>) == "normal")
  assert(style(<tagline-style>) == "normal")
  assert(query(heading).len() == 3)
  assert(counter(page).final().first() == 3)
}
