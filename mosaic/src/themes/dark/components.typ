// Exact callable Dark component namespace.
//
// Dark states its semantic palette as data in `tokens.typ` and the theme hands
// it to `setup`, so the base components already paint in dark colors. This file
// therefore re-exports them unchanged: there is no dark-specific component code
// left to hold.
#import "../../component/api.typ": (
  frame, callout, tag, quote, divider, progress, image, figure,
)
