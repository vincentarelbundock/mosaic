#import "@local/mosaic:0.0.2" as mosaic

// The Metropolis section layout is a raw grid, so the automatic section
// tagline has no subtitle field to land in. It renders in the section cell
// below the heading instead of failing the compile.
#show: mosaic.themes.metropolis.setup

= Model

SECTION TAGLINE METRO

== After

BODY

#context {
  assert(counter(page).final().first() == 2)
  assert(query(heading.where(outlined: true)).len() == 2)
}
