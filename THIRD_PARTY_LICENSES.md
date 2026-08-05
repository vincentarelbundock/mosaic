# Third-party licenses

## Touying fitting utilities and frozen-state mechanism

Parts of `mosaic/src/fit.typ` are adapted from Touying 0.7.4, commit
[`a8abe0d`](https://github.com/touying-typ/touying/commit/a8abe0d832024038c4174d9bb8182f202bde1209),
including work credited by Touying to Andreas Kröpelin / Polylux PR #91 and
ntjess.

The selected counter/state rewind in `mosaic/src/deck-state.typ` and
`mosaic/src/slide-runtime.typ` was informed by Touying's `_rewind-states` helper and
subslide preamble at the same commit. Mosaic uses an explicit opt-in API and a
renderer-local pre-slide location rather than Touying's broader configuration.

Touying copyright notice and license:

> Copyright (c) 2026 OrangeX4 <orangex4@qq.com>
> Copyright (c) 2026 zral0kh
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

## SlidesCarnival presentation templates

Some example decks in `docs/examples/decks/` are adapted from free
presentation templates published by SlidesCarnival:

- `docs/examples/decks/editorial/`: adapted from the *Cream, Green,
  and Black Geometric Blocks Clean Minimal Presentation* template.
- `docs/examples/decks/manifesto/`: adapted from the *Minimalist White
  Slides* template.
- `docs/examples/decks/portfolio/`: adapted from the *Photojournalist
  Portfolio* template.

Each deck is a Mosaic/Typst re-creation of the corresponding template's layout,
built on a bundled Mosaic theme; the original PowerPoint files are not
distributed here. The photographs bundled in each deck's `assets/` directory
come from Pexels and Pixabay, as credited on the source templates.

- <https://www.slidescarnival.com/>

SlidesCarnival templates are distributed under the Creative Commons Attribution
4.0 International License (CC BY 4.0):
<https://creativecommons.org/licenses/by/4.0/>. Attribution is given to
SlidesCarnival with a link to its website, and the material has been adapted.

## Metropolis Beamer theme

Mosaic's bundled `metropolis` theme, and the `docs/examples/decks/metropolis/`
deck built on it, adapt the visual design of the **Metropolis** Beamer theme
by Matthias Vogelgesang:

- <https://github.com/matze/mtheme>

The Metropolis theme is licensed under the Creative Commons
Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0):
<https://creativecommons.org/licenses/by-sa/4.0/>. Attribution is given to
Matthias Vogelgesang and the adaptation is offered under the same CC BY-SA 4.0
license. The original theme sources are not redistributed here.

## Calmly Touying theme

The `docs/examples/decks/calmly/` deck re-creates the visual design of the
**Calmly** presentation theme for Touying by Yichen Han:

- <https://github.com/YHan228/calmly-touying>

Calmly is licensed under the MIT License. The deck is a Mosaic/Typst
re-creation of its appearance; the original theme sources are not
redistributed here.

> MIT License
>
> Copyright (c) 2024 Yichen Han
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

## Simpres Touying template

The `docs/examples/decks/simpres/` deck re-creates the visual design of the
**Simpres** presentation template for Touying by thy0s:

- <https://github.com/thy0s/touying-simpres>

Simpres is licensed under the MIT License. The deck is a Mosaic/Typst
re-creation of its appearance; the original template sources are not
redistributed here.

> MIT License
>
> Copyright (c) 2025 Theodor
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

## Clean Touying and Quarto theme

The `docs/examples/decks/quarto-clean/` deck re-creates the visual design of
the **Clean** theme for Touying and Quarto by Kazuharu Yanagimoto:

- <https://github.com/kazuyanagimoto/quarto-clean-typst>

Clean is licensed under the MIT License. The deck is a Mosaic/Typst
re-creation of its appearance; the original theme sources are not
redistributed here.

> MIT License
>
> Copyright (c) 2024 Kazuharu Yanagimoto
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

## Okabe-Ito palette

The explicit color arrays in the grid and incremental tutorial examples use
the Color Universal Design palette developed by Masataka Okabe and Kei Ito:

- <https://jfly.uni-koeln.de/color/>
