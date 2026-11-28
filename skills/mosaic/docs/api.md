# API reference

Every exported function, grouped by reference page. The `palettes` collection is plain data rather than a function; [Colors](appearance/colors.md#bundled-palettes) lists it. [Labels](api/labels.md) lists every label a rendered slide emits, which is the surface a deck or a theme writes `show` rules against.

- [Document setup](api/setup.md): `setup()`

- [Theme authoring](api/theme.md): `themes.setup()`, `themes.decorate-heading()`

- [Slides](api/slides.md): `slide()`, `info()`, `appendix()`, `note()`, `fit()`

- [Incremental steps](api/steps.md): `steps.on()`, `steps.reveal()`, `steps.replace()`, `steps.drawing()`, `steps.pause()`

- [mosaic.grids constructors](api/grids.md): `grids.cell()`, `grids.track()`, `grids.columns()`, `grids.rows()`

- [Semantic layouts](api/layouts.md): `layouts.author()`, `layouts.content()`, `layouts.image()`, `layouts.title()`, `layouts.section()`

- [Components and furniture](api/components.md): `components.card()`, `components.callout()`, `components.badge()`, `components.quote()`, `components.divider()`, `components.progress()`, `components.image()`, `components.figure()`
