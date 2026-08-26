#import "/.calepin/calepin.typ" as calepin

#set document(title: [Install])
#metadata((title: "Install")) <website-metadata>

#title()

Mosaic requires Typst 0.15 or newer. The released version, 0.0.1, is published on #link("https://typst.app/universe/package/mosaic")[Typst Universe], so using it needs no installation step: the first compile downloads the package.

```typ
#import "@preview/mosaic:0.0.1" as m
```

= The development version

The repository is the development version, 0.0.2. It carries features the released package does not have, and this documentation marks each of them with a warning callout where it describes them. One command installs a snapshot, on macOS, Linux, or a Unix shell on Windows such as Git Bash or WSL:

```sh
curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh
```

Decks then import the `local` namespace, Typst's namespace for packages that come from somewhere other than Universe. The two namespaces keep the two versions apart, so the released package stays available under its own spelling:

```typ
#import "@local/mosaic:0.0.2" as m
```

The snapshot tracks the repository's `main` branch, so running the command again after a version bump installs the new version alongside the old. Passing `--ref` pins a tag or commit instead, and `--uninstall` removes the installed version, after which only the published release resolves:

```sh
curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh -s -- --uninstall
```

To work on Mosaic itself, clone #link("https://github.com/vincentarelbundock/mosaic")[the repository] and run `make install`, which runs the same script against the working tree instead of fetching a snapshot; `make uninstall` removes it.
