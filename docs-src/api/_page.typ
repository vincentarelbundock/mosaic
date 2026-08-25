// Shared frame for the generated API reference pages. Each page names its
// group and then includes generated/<group>/index.typ, which typst-doc writes
// from the package's `///` comments on every website build.
#let api-page(group-title, body) = {
  set document(title: group-title)

  // typst-doc gives every entry a level-1 heading and labels its per-entry
  // "Description" and "Arguments" sections one level down. Those are real
  // headings and should be: they are the document's structure. But Calepin
  // builds its "On this page" rail by collecting heading elements and does not
  // honour `outlined: false`, so the only lever that keeps them out of the rail
  // here is to stop them being headings in the first place. Verified against
  // this Calepin build: `show heading.where(level: 2): set heading(outlined:
  // false)` leaves all sixteen of them in the rail; the rule below is what
  // trims it back to the eight entry names.
  show heading.where(level: 2): it => block(above: 1.25em, below: 0.5em, strong(it.body))

  [
    #metadata((title: group-title)) <website-metadata>
    #title()

    The contents below link to each definition. Function entries show the
    signature, then a description, then the parameters with their types and
    defaults; variable entries show the declared type.

    #body
  ]
}
