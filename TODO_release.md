# Typst Universe release TODO

Typst Universe packages are submitted by pull request to [`typst/packages`](https://github.com/typst/packages). Mosaic must be copied to `packages/preview/mosaic/{version}`. Published versions are permanent, so fixes require a new version.

## Reorganize the repository

Make the repository root the package source root:

```text
typst.toml
lib.typ
README.md
LICENSE
THIRD_PARTY_LICENSES.md
src/
preview/mosaic-slide.svg
docs/
tests/
scripts/
skills/
Makefile
```

- [ ] Move `mosaic/typst.toml`, `mosaic/lib.typ`, and `mosaic/src/` to the repository root, then update all paths in the Makefile, tests, scripts, documentation, and license notices.
- [ ] Replace `PACKAGE_DIR := mosaic` with an explicit package file list. Read the version from `typst.toml` instead of repeating it in the Makefile.
- [x] Add the MIT license at `LICENSE`.
- [x] Remove `mosaic/assets/orcid.svg`, replace its title-slide icon with a text link, and remove the empty asset directory.
- [ ] Ignore `dist/` and Syncthing temporary files.

## Prepare the package

Use this manifest shape after choosing the release version:

```toml
[package]
name = "mosaic"
version = "0.1.0"
entrypoint = "lib.typ"
authors = ["Vincent Arel-Bundock <@vincentarelbundock>"]
license = "MIT"
description = "Build slides with tree-based grids and incremental reveals."
repository = "https://github.com/vincentarelbundock/mosaic"
keywords = ["presentation", "slides", "grid", "incremental"]
categories = ["presentation", "layout", "components"]
compiler = "0.15.0"
exclude = ["/preview/"]
```

- [ ] Decide between `0.0.1` and `0.1.0`, then use the selected version in the manifest, README, tests, and release directory.
- [ ] Make the repository public before adding `repository`. Add `homepage` only after the documentation site is deployed.
- [ ] Verify that the package works with exactly Typst 0.15.0. Do not add a `[template]` section.
- [ ] Confirm the `mosaic` name with package reviewers. It was available when checked on 2026-08-05.

## Fix documentation and licensing

- [ ] Rewrite README imports as `@preview/mosaic:{version}` and update stale theme names and API calls. Compile every example.
- [x] Add `preview/mosaic-slide.svg` as the Universe image. It is an exact copy of the navbar logo. Keep it in the submission and exclude it from package downloads.
- [ ] Check `THIRD_PARTY_LICENSES.md` against the files that ship, especially Touying-derived code, the Metropolis theme, and `code-dark.tmTheme`.
- [ ] Confirm that `MIT` accurately describes the published files. If not, update the SPDX expression and identify the affected files. Include no fonts or unlicensed assets.

## Build and test the release copy

Create this exact staging directory:

```text
dist/packages/preview/mosaic/{version}/
```

It should contain only:

```text
typst.toml
lib.typ
README.md
LICENSE
THIRD_PARTY_LICENSES.md
src/**
preview/mosaic-slide.svg
```

- [ ] Add `scripts/build-release.py`, `make release-stage`, and `make release-check`. Copy from an explicit allowlist and fail on missing files, mismatched versions, broken imports, or extra files.
- [ ] Run `make build`, then run `typst-package-check check` inside the staged package.
- [ ] Compile a smoke deck and every README example through `@preview/mosaic:{version}` using only the staged package.
- [ ] Test with Typst 0.15.0 and the current stable release. Confirm that staging contains no tests, scripts, generated pages, PDFs, caches, temporary files, secrets, or Git metadata.

The official checker can run in Docker:

```sh
docker run --rm -v "$PWD/dist/packages/preview/mosaic/0.1.0:/data" ghcr.io/typst/package-check check
```

## Submit

- [ ] Fork `typst/packages`, create `packages/preview/mosaic/{version}`, and copy the staged files there. Do not use a submodule or symlink.
- [ ] Run `typst-package-check check @preview/mosaic:{version}` from the `packages/` directory of that checkout.
- [ ] Open a pull request containing only the new package directory.
- [ ] After merge, verify the Universe page and a fresh import, then tag the matching source commit as `v{version}`. Publish future fixes as new versions.

## Official references

- [Submission guidelines](https://github.com/typst/packages/blob/main/docs/README.md)
- [Manifest fields](https://github.com/typst/packages/blob/main/docs/manifest.md)
- [Files to include](https://github.com/typst/packages/blob/main/docs/tips.md)
- [README rules](https://github.com/typst/packages/blob/main/docs/documentation.md)
- [Licensing rules](https://github.com/typst/packages/blob/main/docs/licensing.md)
- [Package checker](https://github.com/typst/package-check)
