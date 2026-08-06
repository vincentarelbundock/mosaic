#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Math])
#metadata((title: "Math")) <website-metadata>

#title()

Typst's native math notation works inside Mosaic slides. Incremental commands can then focus attention on one part of an equation at a time without changing its layout.

= Incremental equations

The timing commands documented on the #link("../incremental/reveals.html")[Reveal and replace] page work inside math as well. Wrapping each term in `m.steps.replace` annotates one part of an equation at a time, and because the largest alternative sets the slot, the surrounding math never moves.

#embedded-example(
  calepin.elements.gallery,
  "blocks/incremental-math",
  frames: 4,
  title: "Annotate an equation one part at a time",
)

= LaTeX

The #link("https://typst.app/universe/package/mitex/")[MiTeX package] converts LaTeX math source into Typst content. Import `mi` for inline equations and `mitex` for display equations, useful when reusing existing equations or collaborating with LaTeX authors.

#embedded-example(
  calepin.elements.gallery,
  "blocks/mitex",
  frames: 1,
  title: "Render LaTeX equations with MiTeX",
)

= Theorem

The #link("https://typst.app/universe/package/ctheorems/")[ctheorems package] provides numbered, referenceable theorem and proof environments. Define the environments once, install its `thmrules` show rule, and use them normally inside a Mosaic slide.

#embedded-example(
  calepin.elements.gallery,
  "blocks/theorem",
  frames: 1,
  title: "Typeset a theorem and proof",
)
