# Metropolis — Mosaic adaptation

A technical Mosaic/Typst deck that adapts the visual design of the
**Metropolis** Beamer theme by Matthias Vogelgesang
([github.com/matze/mtheme](https://github.com/matze/mtheme)), whose layout
inspired this example.

The deck demonstrates the material common to a technical talk: substantive
bullet points, incrementally annotated mathematics, Fletcher and CeTZ diagrams,
executable R code, a generated ggplot2 figure, computed model results, inline
citations, a bibliography, and backup slides. Its workhorse `frame` helper is
derived from `m.layouts.default`.

The Metropolis theme is licensed under
[Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).
This deck adapts its visual design; see the repository's
`THIRD_PARTY_LICENSES.md` for the full notice.

Build the executable PDF with
[Calepin](https://vincentarelbundock.github.io/calepin/) (run from this
directory):

```sh
make
```

The build requires R and ggplot2. It resolves the Fira Sans and Fira Mono fonts
through `kpsewhich`, so a TeX distribution that ships the Fira fonts must also
be installed.
