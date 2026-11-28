# Install

Mosaic requires Typst 0.15 or newer. The released version, 0.0.1, is published on [Typst Universe](https://typst.app/universe/package/mosaic), so using it needs no installation step: the first compile downloads the package.

```typ
#import "@preview/mosaic:0.0.1" as m
```

## The development version

The repository is the development version, 0.0.3. It carries features the released package does not have, and this documentation marks each of them with a warning callout where it describes them. One command installs a snapshot, on macOS, Linux, or a Unix shell on Windows such as Git Bash or WSL:

```sh
curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh
```

Decks then import the `local` namespace, Typst's namespace for packages that come from somewhere other than Universe. The two namespaces keep the two versions apart, so the released package stays available under its own spelling:

```typ
#import "@local/mosaic:0.0.3" as m
```

The snapshot tracks the repository's `main` branch, so running the command again after a version bump replaces the old development version with the new one. Passing `--ref` pins a tag or commit instead, and `--uninstall` removes every installed development version, after which only the published release resolves:

```sh
curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh -s -- --uninstall
```

To work on Mosaic itself, clone [the repository](https://github.com/vincentarelbundock/mosaic) and run `make install`, which runs the same script against the working tree instead of fetching a snapshot; `make uninstall` removes it.
