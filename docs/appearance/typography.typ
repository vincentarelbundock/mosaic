#set document(title: [Typography])
#metadata((title: "Typography")) <website-metadata>

#title()

Place native Typst text and heading rules after `m.setup` so they apply across the deck:

```typ
#show: m.setup
#set text(font: "EB Garamond", size: 26pt)
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
#show heading.where(depth: 2): set text(size: 1.4em)
```

A semantic heading feeds outlines, bookmarks, and content slides. Use `text` directly for display type that should not appear in navigation, or exclude the heading:

```typ
#text(size: 60pt, weight: "black")[BOLD]
#heading(outlined: false, bookmarked: false)[Aside]
```

Leading, lists, and captions remain native `par`, `list`, `enum`, `terms`, and `figure.caption` styling.

A heading cannot be placed inside an incremental grid node (`m.grids.on`, `m.steps.reveal`, and related step commands); keep it structurally stable across a slide's frames.

Everything about the deck's palette, overriding entries, the bundled palette collection, and inverting a slide, lives on the #link("colors.html")[Colors] page.
