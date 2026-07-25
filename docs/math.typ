#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Math])
#metadata((title: "Math")) <website-metadata>

#title()

Typst's native math notation works inside Mosaic slides. Incremental commands
can then focus attention on one part of an equation at a time without changing
its layout.

= Incremental

Start with the complete equation so the audience can see its overall
structure. On later frames, replace each plain term with a colored underbrace
and a short explanation. Keeping earlier annotations visible makes the
interpretation accumulate across the sequence.

This example breaks a Bellman optimality equation into its immediate reward,
discount factor, and expected optimal future value.

#verbatim-example("incremental/math.typ")

#slideshow(
  calepin.elements.gallery,
  "incremental/math",
  4,
  "Annotate a Bellman equation component by component",
)

= LaTeX

The #link("https://typst.app/universe/package/mitex/")[MiTeX package] converts
LaTeX math source into Typst content. Import `mi` for inline equations and
`mitex` for display equations. This is useful when reusing existing equations
or when collaborators are more comfortable writing LaTeX notation.

#verbatim-example("math/mitex.typ")

#slideshow(
  calepin.elements.gallery,
  "math/mitex",
  1,
  "Render LaTeX equations with MiTeX",
)

= Theorem

The #link("https://typst.app/universe/package/ctheorems/")[ctheorems package]
provides numbered, referenceable theorem and proof environments. Define the
environments once, install its `thmrules` show rule, and use them normally
inside a Mosaic slide.

#verbatim-example("math/theorem.typ")

#slideshow(
  calepin.elements.gallery,
  "math/theorem",
  1,
  "Typeset a theorem and proof",
)
