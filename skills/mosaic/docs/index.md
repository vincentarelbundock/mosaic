# Mosaic documentation

The Mosaic website as Markdown, generated from `docs-src/` by `scripts/build-skill-docs.py`. Do not edit these files; edit the website sources and run `make skill`. Pages describe the released version (0.0.1) unless a callout says a feature requires the development version (0.0.3); the API reference describes the development version throughout.

Each entry lists the page's sections, so open only the page a task needs.

## Start

- [Install](start/install.md): The development version; A skill for AI coding assistants
- [Get started](start/first-deck.md)
- [Concepts](reference/concepts.md): Vocabulary; Anatomy of a slide deck
- [Examples](examples.md)

## Slides

- [Content slides](slides/content.md): Choosing a structure; Two columns
- [Title slides](slides/title.md): A simple title slide; Variants; Inverted; Custom title page
- [Section slides](slides/section.md): Sections from headings; Explicit section slides; Variants
- [Image slides](slides/image.md): A figure with a caption; A picture beside text; A full-bleed picture
- [Custom slides](slides/custom.md): Walkthrough; Grids with `columns()` and `rows()`; Nesting; Grid sizes (tracks); Filling cells; Refine a layout; Replace or reuse a layout; What cells hold
- [Background](slides/background.md): Placed content; Photographic backgrounds
- [Foreground](slides/foreground.md): Placed content; A logo on every slide

## Styles & Themes

- [Styling cells](appearance/styling.md): Deck typography; Styling cells; Content rules and block rules; Scoping a fill to one slide; Header depth; Properties an element pins on itself; Styling a whole slide; Type and geometry in designed layouts; Reusable looks; Inverting cells by hand
- [Colors](appearance/colors.md): Overriding colors; Bundled palettes; One deck, every palette; Inverting one slide
- [Fonts](appearance/fonts.md): Typst ships no sans font; The warnings; Choosing your own fonts
- [Themes](appearance/themes.md): Selecting themes; Running example; Bundled themes; Customizing; Writing; Case study

## Incremental

- [Steps and pauses](incremental/steps.md): Commands; Pause between blocks; Hold back a whole block; Where steps work
- [Reveal and replace](incremental/reveals.md): Reveal bullets; Reveal cells; Reveal text; Replace content; CeTZ drawings; Fletcher diagrams
- [Handouts](incremental/handouts.md)

## Content

- [Images](content/images.md): Asset paths; Pictures in layouts; Slide-sized images; Figures in a cell; Scrims; Image fitting; Full-bleed cells; Native figures
- [Components](content/components.md): `card()`; `callout()`; `badge()`; `quote()`; `divider()`
- [Math](content/math.md): Incremental equations; LaTeX; Theorem; Accessible math
- [Citations](content/citations.md): Citation keys and a reference slide; Footnotes

## More

- [Footer and progress](presenting/footer.md): Default footer content; Progress; What the deck knows about itself
- [Navigation](presenting/navigation.md): Table of contents; Breadcrumbs; Section links
- [Speaker notes](presenting/notes.md): Printed outputs; On a second screen; Inside the PDF
- [Overflow and fitting](presenting/overflow.md): Inspecting overflowing cells; Fitting a block to its cell; Breakable slides
- [Executable code](presenting/executable-code.md)
- [FAQ](help/faq.md): Reuse; Links; Repeated titles; Margins; Aspect ratio; Repeated counters; Accessibility; Touying
- [Acknowledgments](acknowledgments.md): Acknowledgments

## API reference

- [API reference](api.md)
- [Document setup](api/setup.md): `setup`
- [Theme authoring](api/theme.md): `themes.setup`, `themes.decorate-heading`
- [Slides](api/slides.md): `slide`, `info`, `appendix`, `note`, `fit`
- [Incremental steps](api/steps.md): `steps.on`, `steps.reveal`, `steps.replace`, `steps.drawing`, `steps.pause`
- [mosaic.grids constructors](api/grids.md): `grids.cell`, `grids.track`, `grids.columns`, `grids.rows`
- [Semantic layouts](api/layouts.md): `layouts.author`, `layouts.content`, `layouts.image`, `layouts.title`, `layouts.section`
- [Components and furniture](api/components.md): `components.card`, `components.callout`, `components.badge`, `components.quote`, `components.divider`, `components.progress`, `components.image`, `components.figure`
- [Labels](api/labels.md): Cells; Composed tiers; Whole slide and planes; Engine-owned labels
