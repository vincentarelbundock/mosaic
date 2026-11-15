#import "/.calepin/calepin.typ" as calepin
#import "/api/_page.typ": api-page

#show: api-page.with("Document setup")

#calepin.elements.callout(kind: "warning", title: [Describes Mosaic 0.0.3])[
  This reference is generated from the development sources, 0.0.3, which is not on Typst Universe yet. Three options below are not in the released 0.0.1: the `compact-inset` key of `spacing`, the `"split"` value of `output`, and the `split-inset` key of `notes`. One command installs the development version — `curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh` — and then it imports as `#import "@local/mosaic:0.0.3" as m`. See #link("../start/install.html")[Install] for the full instructions.
]

#include "/api/generated/setup/index.typ"
