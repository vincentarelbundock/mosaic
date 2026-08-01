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

The example decks in `docs/examples/` are adapted from free presentation
templates published by SlidesCarnival:

- `docs/examples/cream/`: adapted from the *Cream, Green,
  and Black Geometric Blocks Clean Minimal Presentation* template.
- `docs/examples/minimalist/`: adapted from the *Minimalist White
  Slides* template.
- `docs/examples/portfolio/`: adapted from the *Photojournalist
  Portfolio* template.

Each deck is a Mosaic/Typst re-creation of the corresponding template's layout;
the original PowerPoint files are not distributed here. The photographs bundled
in each deck's `assets/` directory come from Pexels and Pixabay, as credited on
the source templates.

- <https://www.slidescarnival.com/>

SlidesCarnival templates are distributed under the Creative Commons Attribution
4.0 International License (CC BY 4.0):
<https://creativecommons.org/licenses/by/4.0/>. Attribution is given to
SlidesCarnival with a link to its website, and the material has been adapted.

## Metropolis Beamer theme

The `docs/examples/metropolis/` deck is a Mosaic/Typst adaptation of the
demonstration slides for the **Metropolis** Beamer theme by Matthias
Vogelgesang, reconstructed from the theme's upstream `demo/demo.tex`:

- <https://github.com/matze/mtheme>

The Metropolis theme is licensed under the Creative Commons
Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0):
<https://creativecommons.org/licenses/by-sa/4.0/>. The deck adapts the theme's
visual design; attribution is given to Matthias Vogelgesang and the adaptation
is offered under the same CC BY-SA 4.0 license. The original theme sources are
not redistributed here.

## ColorBrewer palettes

The `brewer-dark2`, `brewer-set2`, and `brewer-paired` color definitions in
`mosaic/src/color.typ` are derived from ColorBrewer by Cynthia A. Brewer, Mark Harrower,
and The Pennsylvania State University:

- <https://colorbrewer2.org/>
- <https://github.com/axismaps/colorbrewer>

ColorBrewer is distributed under the Apache License 2.0:
<https://www.apache.org/licenses/LICENSE-2.0>.

## CARTOColors palettes

The `carto-*` color definitions in `mosaic/src/color.typ` reproduce the six complete
qualitative CARTOColors palettes displayed on CARTO's palette website:

- <https://carto.com/carto-colors/>
- <https://github.com/CartoDB/CartoColor>

CARTOColors is licensed under the Creative Commons Attribution 4.0
International License: <https://creativecommons.org/licenses/by/4.0/>.

## Paul Tol palettes

The `tol-bright` and `tol-muted` color definitions in `mosaic/src/color.typ` reproduce
the qualitative color schemes published by Paul Tol in *Colour schemes and
templates*:

- <https://sronpersonalpages.nl/~pault/>

The schemes are included with source attribution; the source page does not
state a separate software license for the published color values.

## Okabe-Ito palette

The `okabe-ito` color definitions in `mosaic/src/color.typ` reproduce the eight-color
black variant of the Color Universal Design palette developed by Masataka Okabe
and Kei Ito:

- <https://jfly.uni-koeln.de/color/>
