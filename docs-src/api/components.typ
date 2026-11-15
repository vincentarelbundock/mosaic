#import "/.calepin/calepin.typ" as calepin
#import "/api/_page.typ": api-page

#show: api-page.with("Components and furniture")

#calepin.elements.callout(kind: "warning", title: [Describes Mosaic 0.0.3])[
  This reference is generated from the development sources, 0.0.3, which is not on Typst Universe yet. One entry below differs from the released 0.0.1: `progress` quiets itself on unnumbered slides and takes a `quiet:` argument, where the released component always displays. One command installs the development version — `curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh` — and then it imports as `#import "@local/mosaic:0.0.3" as m`. See #link("../start/install.html")[Install] for the full instructions.
]

#include "/api/generated/components/index.typ"
