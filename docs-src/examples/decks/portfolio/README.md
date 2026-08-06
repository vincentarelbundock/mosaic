# Greyscale: hand-built slides on the default theme

A Mosaic/Typst adaptation of the *Photojournalist Portfolio* presentation
template published by [SlidesCarnival](https://www.slidescarnival.com/), which
distributes its templates under the
[Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
license. Photographs are from Pixabay and Pexels.

The deck builds every slide by hand from named cells, splits, and painted
surfaces. Its monochrome look is one dictionary: a full eight-entry greyscale
palette passed to the bundled default theme through `m.setup(colors: ..)`.
All photographs are stored as true greyscale images, so the black, white, and
neutral-gray palette is preserved in every output format.

It reproduces 14 of the 17 source slides. It omits the original
“How to use this presentation,” resource, and credits pages because those are
template-administration slides rather than presentation content.

Build the PDF (run from this directory):

```sh
make
```

The photographs in `assets/` are reused from the source template only to
reproduce the deck's appearance.
