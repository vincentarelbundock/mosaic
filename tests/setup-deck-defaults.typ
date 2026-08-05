#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  layouts: (
    content: m.layouts.content(variant: "header-body"),
    title: m.layouts.title(title: [DEFAULT TITLE]),
    section: m.layouts.section(),
  ),
  background: place(bottom + left)[SETUP BACKGROUND],
  foreground: place(bottom + right)[SETUP FOREGROUND],
)

#m.slide(layout: "title")

#m.slide(cells: (
  header: [EXPLICIT HEADER],
  body: [EXPLICIT BODY],
))

= AUTOMATIC SECTION

== AUTOMATIC CONTENT

Automatic body.

#context assert(counter(page).final().first() == 4)
