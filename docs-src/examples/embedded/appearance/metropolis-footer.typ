#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m

// a slide is composed of a grid
#let footered = m.grids.rows(         
  // 1st row cell is called "header" and its height is automatic based on content (auto)
  m.grids.track(auto, "header"),      
  // 2nd row cell is called "body" and its height takes all the available space (1fr)
  m.grids.track(1fr, "body"),
  // 3rd row cell is called "footer" and its height is automatic based on content (auto)
  m.grids.track(auto, m.grids.cell(
    "footer",
    // the footer cell has default content that will appear on every slide using that layout
    content: [
      #text(fill: orange, "Mosaic")	// text in orange accent color
      #h(1fr)                    	// space
      #m.components.progress()   	// slide number
    ],
  )),
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
