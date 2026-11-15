#import "@local/mosaic:0.0.3" as mosaic
#import mosaic.themes.metropolis as m

// a slide is composed of a grid
#let footered = m.grids.rows(
  // one height per row: the header and footer hug their content (auto),
  // and the body takes all the space left between them (1fr)
  tracks: (auto, 1fr, auto),
  // 1st row cell is called "header"
  "header",
  // 2nd row cell is called "body"
  "body",
  // 3rd row cell is called "footer"
  m.grids.cell(
    "footer",
    // the footer cell has default content that will appear on every slide using that layout
    content: [
      #text(fill: orange, "Mosaic")	// text in orange accent color
      #h(1fr)                    	// space
      #m.components.progress()   	// slide number
    ],
  ),
)

#show: m.setup.with(
  title: [Slides with a footer],
  subtitle: [A variant of metropolis],
  authors: [Vincent Arel-Bundock],
  layouts: (content: footered),
  // Metropolis puts a progress line in the foreground of every numbered
  // slide. The footer counter now says the same thing, so drop the line.
  foreground: none,
)

#m.slide("title")

= First section

== A slide

The `==` heading fills the header and this paragraph fills the body. The footer cell fills itself.

== Another slide

- The footer content lives in the grid, so it repeats without being written anywhere else.
- The title and section slides use other layouts, so they carry no footer.

= Second section

== The last slide

Only slides built from `footered` show the footer.
