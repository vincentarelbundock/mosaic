#import "/.calepin/calepin.typ" as calepin
#import "/api/_page.typ": api-page

#show: api-page.with("Incremental steps", calepin.elements.callout)

#include "/api/generated/steps/index.typ"
