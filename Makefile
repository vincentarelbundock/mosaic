.DEFAULT_GOAL := help

# Only the verbs a person types. Everything else in this file is a file rule
# that a verb depends on, so it stays out of `make help` and out of the way.
.PHONY: help doctor install uninstall check artifacts website publish-docs release-stage build clean distclean

TYPST ?= typst
CALEPIN ?= calepin
# Generates the API reference entries from the package's `///` doc comments.
TYPSTDOC ?= typst-doc
PYTHON ?= uv run python
# The directory name is also the package name.
PACKAGE_DIR := mosaic
# Single source of truth: the manifest the package ships with.
PACKAGE_VERSION := $(shell awk -F'"' '/^version[[:space:]]*=/{print $$2; exit}' $(PACKAGE_DIR)/typst.toml)
TYPST_PACKAGE_PATH ?= $(or \
  $(strip $(shell $(TYPST) info 2>/dev/null | awk '/Package path/{print $$3; exit}')), \
  $(or $(XDG_DATA_HOME),$(HOME)/.local/share)/typst/packages)
# The development version installs into the `local` namespace, Typst's namespace
# for packages that come from somewhere other than Universe, and the tests import
# it as @local/mosaic. The two namespaces keep the two versions apart with no
# shadowing: @preview/mosaic resolves the released package from Universe, which
# is what every website example imports, and @local/mosaic resolves this working
# tree. Installing an unpublished version under `preview` instead would claim a
# Universe version that does not exist, and would silently mask the real one
# once it did.
LOCAL_PACKAGE_DIR := $(TYPST_PACKAGE_PATH)/local/$(PACKAGE_DIR)/$(PACKAGE_VERSION)
# The website has two halves. DOCS_SRC is everything authored by hand plus the
# example artifacts the rules below render: pages, calepin.toml, the theme, the
# assets, the example projects. SITE_DIR is what Calepin writes from it. Nothing
# in SITE_DIR is edited directly and it is gitignored; `make website` reproduces
# all of it and `make publish-docs` force-stages it for GitHub Pages.
DOCS_SRC := docs-src
SITE_DIR := docs
# Illustrations the README links to. The README points at the published copies
# under $(SITE_DIR)/assets, so one text works on GitHub and on the website; the
# package mirrors them at those same relative paths for Typst Universe.
PACKAGE_README_ASSETS := \
  $(PACKAGE_DIR)/docs/assets/mosaic-slide.svg \
  $(PACKAGE_DIR)/docs/assets/images/showcase-contact-sheet.webp
# Staging tree for a Typst Universe pull request: copy RELEASE_DIR into
# packages/preview/$(PACKAGE_DIR)/$(PACKAGE_VERSION) of a typst/packages fork.
RELEASE_DIR := dist/packages/preview/$(PACKAGE_DIR)/$(PACKAGE_VERSION)

# Full example decks shipped under docs-src/examples/decks/. Each has its own Makefile
# that builds <slug>.pdf; the top-level rule below also renders a cover.jpg.
DECK_EXAMPLES_DIR := $(DOCS_SRC)/examples/decks
DECK_METADATA := scripts/deck_metadata.py
DECK_MANIFEST := $(DECK_EXAMPLES_DIR)/manifest.json
DECK_SLUGS := $(shell $(PYTHON) $(DECK_METADATA) slugs)
DECK_STAMP_DIR := .build/examples
DECK_STAMPS := $(addprefix $(DECK_STAMP_DIR)/,$(addsuffix .stamp,$(DECK_SLUGS)))
# Watch each example's hand-authored inputs independently. Generated decks,
# gallery covers, and Calepin caches cannot make their own stamps stale.
deck_sources = $(shell find $(DECK_EXAMPLES_DIR)/$(1) -type f \
	! -path '*/.calepin/*' ! -name '*.pdf' ! -name 'cover.jpg' 2>/dev/null | sort)
$(foreach slug,$(DECK_SLUGS),$(eval $(DECK_STAMP_DIR)/$(slug).stamp: $(call deck_sources,$(slug)) $(DECK_MANIFEST)))

EMBEDDED_EXAMPLES_DIR := $(DOCS_SRC)/examples/embedded
EMBEDDED_ASSETS_DIR := $(DOCS_SRC)/assets/examples
EMBEDDED_STAMP_DIR := .build/embedded-examples
WEB_IMAGE_DIR := $(DOCS_SRC)/assets/images
# The photographs the examples use. These are committed source, not derivatives:
# the examples re-render whenever one of them changes.
WEB_IMAGES := $(WEB_IMAGE_DIR)/bonsai.webp $(WEB_IMAGE_DIR)/dog.webp
API_DIR := $(DOCS_SRC)/api
API_GENERATED_DIR := $(API_DIR)/generated
API_STAMP_DIR := .build/api
# One typst-doc run per API reference page. typst-doc reads the `///` comments
# straight out of the package sources, so nothing is staged first, and it
# resolves a cross-reference only within a single run: grouping the inputs page
# by page is what makes a link between two entries on the same page a real link
# rather than plain code. Each list stays in the order the page presents them,
# because typst-doc emits entries in the order it is given them.
API_GROUP_setup := $(API_DIR)/sources/setup.typ
API_GROUP_theme := $(PACKAGE_DIR)/src/themes/extension.typ
API_GROUP_slides := $(addprefix $(PACKAGE_DIR)/src/,\
  slide/command.typ info.typ note/command.typ surface.typ fit.typ)
API_GROUP_steps := $(addprefix $(PACKAGE_DIR)/src/incremental/,command.typ pause.typ)
API_GROUP_grids := $(PACKAGE_DIR)/src/grid/constructors.typ
API_GROUP_layouts := $(addprefix $(PACKAGE_DIR)/src/,\
  author.typ layout/content.typ layout/image.typ layout/title.typ layout/section.typ)
API_GROUP_components := $(addprefix $(PACKAGE_DIR)/src/component/,\
  card.typ callout.typ badge.typ quote.typ divider.typ progress.typ image.typ figure.typ)
# The group name is the page stem: docs-src/api/<group>.typ includes
# docs-src/api/generated/<group>/index.typ.
API_GROUPS := setup theme slides steps grids layouts components
API_GROUP_STAMPS := $(addprefix $(API_STAMP_DIR)/,$(addsuffix .stamp,$(API_GROUPS)))
# These files are both compiled below and embedded verbatim in their owning pages.
# Files whose name starts with "_" are shared includes, not standalone decks.
EMBEDDED_EXAMPLE_SOURCES := $(shell find $(EMBEDDED_EXAMPLES_DIR) -type f -name '*.typ' ! -name '_*' 2>/dev/null | sort)
# Multi-frame examples are shipped as one PDF plus a first-frame SVG cover.
# Derive that set from the docs so adding an embedded slideshow needs no build manifest.
EMBEDDED_SLIDESHOW_INDEXER := scripts/list-embedded-slideshows.py
# Recurse into the docs tree: authored pages live in subdirectories (start/,
# slides/, ...), and a page missed here silently demotes its slideshow to a
# per-frame image build. Mirror check-doc-assets.py's authored_pages().
EMBEDDED_DOC_PAGES := $(shell find $(DOCS_SRC) -type f -name '*.typ' \
  -not -path '*/_calepin/*' -not -path '*/.calepin/*' \
  -not -path '$(DOCS_SRC)/examples/*' -not -path '$(DOCS_SRC)/api/generated/*' \
  -not -path '$(DOCS_SRC)/api/sources/*' 2>/dev/null | sort)
EMBEDDED_SLIDESHOW_SOURCES := $(addprefix $(EMBEDDED_EXAMPLES_DIR)/,$(addsuffix .typ,\
  $(shell $(PYTHON) $(EMBEDDED_SLIDESHOW_INDEXER) $(EMBEDDED_DOC_PAGES))))
EMBEDDED_SLIDESHOW_STAMPS := $(patsubst $(EMBEDDED_EXAMPLES_DIR)/%.typ,$(EMBEDDED_STAMP_DIR)/%.stamp,$(EMBEDDED_SLIDESHOW_SOURCES))
EMBEDDED_IMAGE_STAMPS := $(patsubst $(EMBEDDED_EXAMPLES_DIR)/%.typ,$(EMBEDDED_STAMP_DIR)/%.stamp,\
  $(filter-out $(EMBEDDED_SLIDESHOW_SOURCES),$(EMBEDDED_EXAMPLE_SOURCES)))
EMBEDDED_STAMPS := $(EMBEDDED_SLIDESHOW_STAMPS) $(EMBEDDED_IMAGE_STAMPS)
# Adjacent underscore-prefixed modules are private support for executable
# entries and must trigger the same rebuilds without becoming entry points.
$(foreach source,$(EMBEDDED_EXAMPLE_SOURCES),$(eval \
  $(patsubst $(EMBEDDED_EXAMPLES_DIR)/%.typ,$(EMBEDDED_STAMP_DIR)/%.stamp,$(source)): \
  $(wildcard $(dir $(source))_*.typ)))
# Package README illustrations do not affect compiled output. Excluding that
# mirrored documentation tree also prevents the showcase sheet from becoming
# both an input and an output of its own build.
PACKAGE_SOURCES := $(shell find $(PACKAGE_DIR) -type f \
  ! -path '$(PACKAGE_DIR)/docs/*' ! -name 'README.md' 2>/dev/null | sort)
SHOWCASE_VIDEOS := $(WEB_IMAGE_DIR)/showcase.webm $(WEB_IMAGE_DIR)/showcase.mp4
SHOWCASE_POSTER := $(WEB_IMAGE_DIR)/showcase-poster.webp
# One still of every slide the reel visits, three across.
SHOWCASE_SHEET := $(WEB_IMAGE_DIR)/showcase-contact-sheet.webp
# Content hash of the frames the committed reel was encoded from. A slide PDF
# rebuilt with identical content still has new bytes and a new mtime, so this is
# what decides whether the reel is actually stale.
SHOWCASE_FINGERPRINT := $(WEB_IMAGE_DIR)/showcase.fingerprint
# The reel's opening frame. No page embeds it, so it is not an embedded example.
SHOWCASE_OPENING := $(DOCS_SRC)/examples/showcase/opening.pdf
# The reel draws on every complete deck plus a few structural examples, so any
# of them can make it stale.
SHOWCASE_STAMPS := $(DECK_STAMPS) $(SHOWCASE_OPENING) \
	$(EMBEDDED_STAMP_DIR)/getting-started/first-slideshow.stamp \
	$(EMBEDDED_STAMP_DIR)/structure/grid-dashboard.stamp \
	$(EMBEDDED_STAMP_DIR)/structure/title-image-bottom.stamp \
	$(EMBEDDED_STAMP_DIR)/structure/section-layout.stamp

help: ## Display this help screen
	@echo -e "\033[1mAvailable commands:\033[0m\n"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' | sort

doctor: ## Check mandatory, documentation, and optional build prerequisites
	$(PYTHON) scripts/doctor.py all

# ==============================================================================
# The package
# ==============================================================================

install: ## Copy Mosaic into Typst's package index as @local/mosaic
	rm -rf "$(LOCAL_PACKAGE_DIR)"
	mkdir -p "$(LOCAL_PACKAGE_DIR)"
	cp -R "$(PACKAGE_DIR)/." "$(LOCAL_PACKAGE_DIR)/"
	@echo "Installed @local/$(PACKAGE_DIR):$(PACKAGE_VERSION) in $(LOCAL_PACKAGE_DIR)"

uninstall: ## Remove the working-tree copy, leaving only the released @preview/mosaic
	rm -rf "$(LOCAL_PACKAGE_DIR)"
	@echo "Removed $(LOCAL_PACKAGE_DIR)"

# ==============================================================================
# Tests
# ==============================================================================

# Five groups, in cheapest-first order so a broken facade fails before minutes of
# compiling: the exact export contract, the classified positive fixtures, the
# negative fixtures and their exact diagnostics, and the documentation's sources,
# artifacts, and frame counts. To run one group by hand, call it directly:
#   uv run python scripts/run-tests.py core|layout|negative --typst typst
check: install $(WEB_IMAGES) ## Run package, fixture, and documentation integrity tests
	cd tests && $(PYTHON) -m unittest test_check_api_exports test_theme_architecture test_palettes
	$(PYTHON) scripts/check-api-exports.py
	$(PYTHON) scripts/run-tests.py core --typst "$(TYPST)"
	$(PYTHON) scripts/run-tests.py layout --typst "$(TYPST)"
	$(PYTHON) scripts/run-tests.py negative --typst "$(TYPST)"
	$(PYTHON) scripts/check-doc-assets.py

# ==============================================================================
# Example artifacts. The rendered artifacts (embedded PDFs and SVGs, deck PDFs
# and covers, the showcase reel) are committed, so the site builds from the
# files on hand. Rebuild them deliberately after changing an example or the
# package's visual output; check-doc-assets.py still fails if a page and its
# artifact disagree.
# ==============================================================================

artifacts: $(EMBEDDED_STAMPS) $(DECK_STAMPS) $(SHOWCASE_VIDEOS) $(SHOWCASE_POSTER) $(SHOWCASE_SHEET) ## Re-render every committed example artifact

# Both flavours emit the same PDF; they differ only in what preview accompanies
# it. A slideshow keeps a single first-frame cover, which the page only ever
# shows as a bounded poster, so it is a 2x raster; a gallery item keeps one SVG
# per frame, because those are read inline at arbitrary zoom.
COVER_PPI := 115
$(EMBEDDED_SLIDESHOW_STAMPS): EMBEDDED_PREVIEW = cover
$(EMBEDDED_IMAGE_STAMPS): EMBEDDED_PREVIEW = frames

$(EMBEDDED_STAMPS): $(EMBEDDED_STAMP_DIR)/%.stamp: $(EMBEDDED_EXAMPLES_DIR)/%.typ $(PACKAGE_SOURCES) $(WEB_IMAGES) $(EMBEDDED_SLIDESHOW_INDEXER) scripts/embedded_examples.py scripts/encode-cover.py Makefile | install
	@mkdir -p "$(dir $(EMBEDDED_ASSETS_DIR)/$*)" "$(@D)"
	@echo "typst compile $< $(EMBEDDED_ASSETS_DIR)/$*.pdf ($(EMBEDDED_PREVIEW))"
	@find "$(dir $(EMBEDDED_ASSETS_DIR)/$*)" -maxdepth 1 -type f -name "$(notdir $*)-*.svg" -delete
	@$(TYPST) compile --root . "$<" "$(EMBEDDED_ASSETS_DIR)/$*.pdf"
	@if [ "$(EMBEDDED_PREVIEW)" = cover ]; then \
		$(TYPST) compile --root . --format png --ppi $(COVER_PPI) --pages 1 "$<" "$(EMBEDDED_ASSETS_DIR)/$*-cover.png" && \
		$(PYTHON) scripts/encode-cover.py "$(EMBEDDED_ASSETS_DIR)/$*-cover.png" "$(EMBEDDED_ASSETS_DIR)/$*-cover.webp"; \
	else \
		$(TYPST) compile --root . --format svg "$<" '$(EMBEDDED_ASSETS_DIR)/$*-{0p}.svg'; \
	fi
	@touch "$@"

$(SHOWCASE_OPENING): $(DOCS_SRC)/examples/showcase/opening.typ $(PACKAGE_SOURCES) | install
	$(TYPST) compile --root . "$<" "$@"

# One run writes the reel, its poster (the reel's first frame), and the contact
# sheet of every slide it visits. A newer prerequisite only makes the script
# re-render and re-hash the frames; unless a slide really changed it leaves all
# four files untouched.
$(SHOWCASE_VIDEOS) $(SHOWCASE_POSTER) $(SHOWCASE_SHEET) &: scripts/build-docs-showcase-video.sh $(DECK_MANIFEST) $(SHOWCASE_STAMPS)
	./scripts/build-docs-showcase-video.sh $(PYTHON)

# A group's manual is a directory of files whose names come from the entries
# typst-doc finds, so the stamp, not the output, is what make tracks. The
# directory is wiped first: a renamed or deleted entry must not leave its old
# file behind for index.typ to stop including but Calepin to keep serving.
# Makefile too: a group's input list lives up in API_GROUP_<group>, so editing
# it must rebuild that group's manual.
$(foreach group,$(API_GROUPS),$(eval \
  $(API_STAMP_DIR)/$(group).stamp: $(API_GROUP_$(group)) Makefile))

$(API_GROUP_STAMPS): $(API_STAMP_DIR)/%.stamp:
	@mkdir -p "$(@D)"
	rm -rf "$(API_GENERATED_DIR)/$*"
	$(TYPSTDOC) $(API_GROUP_$*) --output "$(API_GENERATED_DIR)/$*"
# The manual labels every entry heading with the entry's name, so the group's
# own index is authoritative about what it contains and what each anchor is.
# Ask it, rather than inferring names from file stems: the query cannot drift
# from what was generated. The filter drops the outline's own "Contents"
# heading, the one level-1 heading in the document that carries no label.
	$(TYPST) eval --root . --format json --in "$(API_GENERATED_DIR)/$*/index.typ" \
	  'query(heading.where(level: 1)).filter(it => it.at("label", default: none) != none).map(it => str(it.label))' \
	  > "$(API_GENERATED_DIR)/$*/entries.json"
	@touch "$@"

# Build each example deck via its own Makefile (which knows its typst flags and
# fonts), then render the first page to a JPEG cover for the Examples gallery.
$(DECK_STAMP_DIR)/%.stamp: $(PACKAGE_SOURCES) $(DECK_METADATA) Makefile | install
	@mkdir -p "$(@D)"
	@echo "examples: building $*"
	@$(MAKE) --no-print-directory -C "$(DECK_EXAMPLES_DIR)/$*"
	@pdftoppm -jpeg -jpegopt quality=82 -singlefile -f 1 -l 1 -scale-to 1200 \
		"$(DECK_EXAMPLES_DIR)/$*/$*.pdf" "$(DECK_EXAMPLES_DIR)/$*/cover"
	@touch "$@"

# ==============================================================================
# The website
# ==============================================================================

website: install $(API_GROUP_STAMPS) ## Render docs-src into the published docs/ site from committed artifacts
# Calepin refuses to overwrite an output directory it does not recognise, and
# Syncthing can re-materialise stray files under $(SITE_DIR) between builds.
# Removing it first is safe because every byte in it is generated, and it makes
# the build independent of whatever state the directory was left in.
	rm -rf $(SITE_DIR)
	$(CALEPIN) compile $(DOCS_SRC) $(SITE_DIR)
	$(PYTHON) scripts/normalize-html.py
	$(PYTHON) scripts/check-doc-assets.py --site
# GitHub Pages runs Jekyll unless this file is present, and Jekyll drops every
# path beginning with an underscore, including the $(SITE_DIR)/_calepin favicon
# every page links. Last, so it exists whatever the build did before it.
	@touch $(SITE_DIR)/.nojekyll

# $(SITE_DIR) is gitignored, so a routine commit never carries a rebuild of it.
# Publishing to GitHub Pages is this deliberate step: stage the rendered site,
# minus Calepin's own manifest and any Syncthing conflict copies, and leave the
# commit to you.
publish-docs: website ## Force-stage the rendered site for a GitHub Pages commit
	git add -f $(SITE_DIR) \
		':(exclude)$(SITE_DIR)/.calepin' \
		':(exclude,glob)$(SITE_DIR)/**/*sync-conflict*'
	@echo "Staged $(SITE_DIR). Review with 'git diff --cached --stat', then commit."

# ==============================================================================
# Release and housekeeping
# ==============================================================================

# The package ships the repository README verbatim, because that is the text
# Typst Universe displays. Its illustrations must therefore resolve at the same
# relative paths inside the package; `exclude` keeps them out of the download.
release-stage: $(PACKAGE_DIR)/README.md $(PACKAGE_README_ASSETS) install ## Stage the exact file set to copy into a typst/packages fork
	rm -rf "$(RELEASE_DIR)"
	mkdir -p "$(RELEASE_DIR)"
	cp -R "$(PACKAGE_DIR)/." "$(RELEASE_DIR)/"
	@echo "Staged $(PACKAGE_DIR) $(PACKAGE_VERSION) in $(RELEASE_DIR)"

$(PACKAGE_DIR)/README.md: README.md
	cp $< $@

# The package copies keep the README's published `docs/assets/...` spelling, but
# take their bytes from the authored tree so a stale site cannot leak into a
# release.
$(PACKAGE_DIR)/docs/assets/mosaic-slide.svg: $(DOCS_SRC)/assets/mosaic-slide.svg
$(PACKAGE_DIR)/docs/assets/images/showcase-contact-sheet.webp: $(SHOWCASE_SHEET)

$(PACKAGE_README_ASSETS):
	@mkdir -p "$(@D)"
	cp $< $@

build: doctor install check website ## Validate prerequisites, then compile tests and documentation

# Everything this removes is derived and cheap to rebuild, and none of it is
# committed, so `make clean && make website` is a working sequence: the site
# rebuilds from the example artifacts, which a clean deliberately leaves alone.
# Removing those is `distclean`.
clean: ## Remove build stamps, generated API manuals, Calepin caches, and the rendered site
	rm -rf $(API_GENERATED_DIR) $(API_STAMP_DIR)
	rm -rf $(EMBEDDED_STAMP_DIR) $(DECK_STAMP_DIR) $(SITE_DIR)
# Calepin scatters caches through the source tree rather than keeping one: a
# `_calepin` beside every page directory, a `.calepin` inside every example
# deck, and stray per-page entry files. Sweep for them by name so a new page
# directory never leaves a cache behind that clean does not know about.
	find $(DOCS_SRC) -type d -name '.calepin' -exec rm -rf {} +
# The favicon lives inside an otherwise-ignored `_calepin` directory and is
# force-added to the index, so it is source that a name-based sweep must spare.
	find $(DOCS_SRC) -path '*/_calepin/*' ! -name favicon.svg -delete 2>/dev/null || true
# Emptying by content leaves the `_calepin` directories themselves behind, since
# the pattern above only ever matches what is inside one. Take every directory
# the sweep stripped bare; the favicon's parent is the one that survives.
	find $(DOCS_SRC) -type d -name '_calepin' -empty -delete
	find $(DOCS_SRC) -name '.calepin-entry.*' -delete

# The example artifacts and the showcase reel are committed, so this shows up as
# deletions in `git status` until `make artifacts` re-renders them, which is
# minutes of work. If all you wanted was a fresh cache, use `clean`; if you
# already ran this, `git checkout -- $(DOCS_SRC)` restores the committed bytes
# in seconds.
distclean: clean ## Also remove the committed example artifacts and the showcase reel
	find $(EMBEDDED_ASSETS_DIR) -type f \( -name '*.pdf' -o -name '*.svg' -o -name '*.webp' \) -delete
	for slug in $(DECK_SLUGS); do rm -f "$(DECK_EXAMPLES_DIR)/$$slug/$$slug.pdf" "$(DECK_EXAMPLES_DIR)/$$slug/cover.jpg"; done
	rm -f $(SHOWCASE_VIDEOS) $(SHOWCASE_POSTER) $(SHOWCASE_SHEET) $(SHOWCASE_FINGERPRINT) $(SHOWCASE_OPENING)
