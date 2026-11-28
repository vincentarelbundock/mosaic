# Install

Mosaic requires Typst 0.15 or newer. The released version, 0.0.2, is published on [Typst Universe](https://typst.app/universe/package/mosaic), so using it needs no installation step: the first compile downloads the package.

```typ
#import "@preview/mosaic:0.0.2" as m
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

## A skill for AI coding assistants

The repository ships an [agent skill](https://agentskills.io) that teaches an AI coding assistant to write and debug Mosaic decks. Its `SKILL.md` is a working tutorial: the authoring workflow, the common slide types, the setup options, and how to diagnose a failed compile. Beside it, a `docs/` folder holds this whole website as Markdown, including every guide page with its example sources, the API reference with each parameter's type and default, and the source of every example deck. The assistant opens one page at a time when a task needs it, so the full documentation is available without filling its context.

Install it with the [`skills`](https://github.com/vercel-labs/skills) command-line tool, which needs Node.js. It detects the assistants on your machine and asks which of them should get the skill:

```sh
npx skills add vincentarelbundock/mosaic
```

That installs the skill into the current project, where it can be committed for everyone who works there. Add `--global` to install it for your user account instead, in every project. The assistant then uses the skill on its own whenever a task involves Mosaic slides.

The skill tracks the repository's `main` branch, so it describes the development version and marks what the released version lacks, as this site does. To pick up a newer version later:

```sh
npx skills update mosaic
```
