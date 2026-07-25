// Public Mosaic facade. Implementation details live in coherent src modules.
#import "src/setup.typ": setup
#import "src/deck-commands.typ": deck, slide
#import "src/deck-state.typ": (
  slide-number,
  section-number,
  page-number,
  current-heading,
)
#import "src/slide-runtime.typ": step-number
#import "src/incremental.typ": on, reveal, replace, reduce
#import "src/grid-api.typ" as grid
#import "src/image.typ": image
#import "src/author.typ": author
#import "src/color-api.typ" as color
#import "src/component-api.typ" as components
#import "src/template-api.typ" as templates
