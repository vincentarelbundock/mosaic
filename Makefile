.DEFAULT_GOAL := help

.PHONY: help doctor install build check api-contract core-tests negative-tests layout-tests doc-integrity web-images embedded-examples showcase-video components api-sources examples website docs clean clean-generated distclean

TYPST ?= typst
CALEPIN ?= calepin
PYTHON ?= uv run python
PACKAGE_DIR := mosaic
PACKAGE_NAME := mosaic
PACKAGE_VERSION := 0.0.1
TYPST_DATA_DIR ?= $(or $(XDG_DATA_HOME),$(HOME)/.local/share)
TYPST_PACKAGE_PATH ?= $(or \
  $(strip $(shell $(TYPST) info 2>/dev/null | awk '/Package path/{print $$3; exit}')), \
  $(TYPST_DATA_DIR)/typst/packages)
LOCAL_PACKAGE_DIR := $(TYPST_PACKAGE_PATH)/local/$(PACKAGE_NAME)/$(PACKAGE_VERSION)
DOCS_DIR := docs

# Full example decks shipped under docs/examples/decks/. Each has its own Makefile
# that builds <slug>.pdf; the top-level rule below also renders a cover.jpg.
DECK_EXAMPLES_DIR := $(DOCS_DIR)/examples/decks
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

EMBEDDED_EXAMPLES_DIR := $(DOCS_DIR)/examples/embedded
EMBEDDED_ASSETS_DIR := $(DOCS_DIR)/assets/examples
EMBEDDED_STAMP_DIR := .build/embedded-examples
WEB_IMAGE_DIR := $(DOCS_DIR)/assets/images
BONSAI_SOURCE := $(WEB_IMAGE_DIR)/bonsai.png
BONSAI_WEBP := $(WEB_IMAGE_DIR)/bonsai.webp
DOG_SOURCE := $(WEB_IMAGE_DIR)/dog.jpg
DOG_WEBP := $(WEB_IMAGE_DIR)/dog.webp
WEB_IMAGES := $(BONSAI_WEBP) $(DOG_WEBP)
API_MODULES_DIR := $(DOCS_DIR)/api/modules
# Staged Tidy module name -> package source path, both without the .typ suffix.
# The staged names stay flat because the docs pages reference them by name.
API_MODULE_MAP := \
  author:author \
  component-frame:component/frame \
  component-callout:component/callout \
  component-label:component/label \
  component-quote:component/quote \
  component-divider:component/divider \
  component-progress:component/progress \
  slide-command:slide/command \
  note-command:note/command \
  pause-command:incremental/pause \
  surface:surface \
  fit:fit \
  grid-constructors:grid/constructors \
  image:component/image \
  component-figure:component/figure \
  incremental-command:incremental/command \
  theme-extension:themes/extension \
  layout-content:layout/content \
  layout-image:layout/image \
  layout-section:layout/section \
  layout-title:layout/title
API_MAPPED_MODULES := $(foreach entry,$(API_MODULE_MAP),$(API_MODULES_DIR)/$(word 1,$(subst :, ,$(entry))).typ)
API_STAGED_MODULES := $(API_MAPPED_MODULES) $(API_MODULES_DIR)/setup.typ
# These files are both compiled below and embedded verbatim in their owning pages.
# Files whose name starts with "_" are shared includes, not standalone decks.
EMBEDDED_EXAMPLE_SOURCES := $(shell find $(EMBEDDED_EXAMPLES_DIR) -type f -name '*.typ' ! -name '_*' 2>/dev/null | sort)
# Multi-frame examples are shipped as one PDF plus a first-frame SVG cover.
# Derive that set from the docs so adding an embedded slideshow needs no build manifest.
EMBEDDED_SLIDESHOW_INDEXER := scripts/list-embedded-slideshows.py
# Recurse into the docs tree: authored pages live in subdirectories (start/,
# slides/, ...), and a page missed here silently demotes its slideshow to a
# per-frame image build. Mirror check-doc-assets.py's authored_pages().
EMBEDDED_DOC_PAGES := $(shell find $(DOCS_DIR) -type f -name '*.typ' \
  -not -path '*/_calepin/*' -not -path '*/.calepin/*' \
  -not -path '$(DOCS_DIR)/examples/*' -not -path '$(DOCS_DIR)/api/modules/*' \
  -not -path '$(DOCS_DIR)/api/sources/*' 2>/dev/null | sort)
EMBEDDED_SLIDESHOW_SLUGS := $(shell $(PYTHON) $(EMBEDDED_SLIDESHOW_INDEXER) $(EMBEDDED_DOC_PAGES))
EMBEDDED_SLIDESHOW_SOURCES := $(addprefix $(EMBEDDED_EXAMPLES_DIR)/,$(addsuffix .typ,$(EMBEDDED_SLIDESHOW_SLUGS)))
EMBEDDED_IMAGE_SOURCES := $(filter-out $(EMBEDDED_SLIDESHOW_SOURCES),$(EMBEDDED_EXAMPLE_SOURCES))
EMBEDDED_SLIDESHOW_STAMPS := $(patsubst $(EMBEDDED_EXAMPLES_DIR)/%.typ,$(EMBEDDED_STAMP_DIR)/%.stamp,$(EMBEDDED_SLIDESHOW_SOURCES))
EMBEDDED_IMAGE_STAMPS := $(patsubst $(EMBEDDED_EXAMPLES_DIR)/%.typ,$(EMBEDDED_STAMP_DIR)/%.stamp,$(EMBEDDED_IMAGE_SOURCES))
EMBEDDED_STAMPS := $(EMBEDDED_SLIDESHOW_STAMPS) $(EMBEDDED_IMAGE_STAMPS)
# Adjacent underscore-prefixed modules are private support for executable
# entries and must trigger the same rebuilds without becoming entry points.
$(foreach source,$(EMBEDDED_EXAMPLE_SOURCES),$(eval \
  $(patsubst $(EMBEDDED_EXAMPLES_DIR)/%.typ,$(EMBEDDED_STAMP_DIR)/%.stamp,$(source)): \
  $(wildcard $(dir $(source))_*.typ)))
PACKAGE_SOURCES := $(shell find $(PACKAGE_DIR) -type f 2>/dev/null | sort)
SHOWCASE_VIDEO := $(WEB_IMAGE_DIR)/showcase.webm
SHOWCASE_POSTER := $(WEB_IMAGE_DIR)/showcase-poster.webp
# Content hash of the frames the committed reel was encoded from. A slide PDF
# rebuilt with identical content still has new bytes and a new mtime, so this is
# what decides whether the reel is actually stale.
SHOWCASE_FINGERPRINT := $(WEB_IMAGE_DIR)/showcase.fingerprint
# The reel's opening frame. No page embeds it, so it is not an embedded example.
SHOWCASE_OPENING_SOURCE := $(DOCS_DIR)/examples/showcase/opening.typ
SHOWCASE_OPENING := $(DOCS_DIR)/examples/showcase/opening.pdf
# The reel draws on every complete deck plus a few structural examples, so any
# of them can make it stale.
SHOWCASE_STAMPS := $(DECK_STAMPS) $(SHOWCASE_OPENING) \
	$(EMBEDDED_STAMP_DIR)/getting-started/first-slideshow.stamp \
	$(EMBEDDED_STAMP_DIR)/structure/grid-dashboard.stamp \
	$(EMBEDDED_STAMP_DIR)/structure/title-layout.stamp \
	$(EMBEDDED_STAMP_DIR)/structure/section-layout.stamp

help: ## Display this help screen
	@echo -e "\033[1mAvailable commands:\033[0m\n"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' | sort

doctor: ## Check mandatory, documentation, and optional build prerequisites
	$(PYTHON) scripts/doctor.py all

# ==============================================================================
# Build targets
# ==============================================================================

install: ## Copy Mosaic into Typst's local package index
	rm -rf "$(LOCAL_PACKAGE_DIR)"
	mkdir -p "$(LOCAL_PACKAGE_DIR)"
	cp -R "$(PACKAGE_DIR)/." "$(LOCAL_PACKAGE_DIR)/"
	@echo "Installed @local/$(PACKAGE_NAME):$(PACKAGE_VERSION) in $(LOCAL_PACKAGE_DIR)"

build: doctor install check website ## Validate prerequisites, then compile tests and documentation

check: install api-contract core-tests layout-tests negative-tests doc-integrity ## Run package, fixture, and documentation integrity tests

api-contract: ## Verify exact neutral, themed, and nested facade exports
	cd tests && $(PYTHON) -m unittest test_check_api_exports test_theme_architecture
	$(PYTHON) scripts/check-api-exports.py

core-tests: install ## Run explicitly classified non-layout positive tests
	$(PYTHON) scripts/run-tests.py core --typst "$(TYPST)"

negative-tests: install ## Require every invalid fixture to emit its exact diagnostic contract
	$(PYTHON) scripts/run-tests.py negative --typst "$(TYPST)"

layout-tests: install web-images ## Run explicitly classified semantic layout tests
	$(PYTHON) scripts/run-tests.py layout --typst "$(TYPST)"

doc-integrity: embedded-examples examples ## Validate docs consumers, artifacts, frame counts, and deck metadata
	$(PYTHON) scripts/check-doc-assets.py

web-images: $(WEB_IMAGES) ## Generate compact WebP derivatives while retaining source images

# Each derivative is bounded on its long edge, which differs per source aspect.
$(BONSAI_WEBP): $(BONSAI_SOURCE)
$(BONSAI_WEBP): WEB_IMAGE_BOUND := --max-width 1600
$(DOG_WEBP): $(DOG_SOURCE)
$(DOG_WEBP): WEB_IMAGE_BOUND := --max-height 1600

$(WEB_IMAGES):
	mkdir -p $(WEB_IMAGE_DIR)
	$(PYTHON) scripts/convert-web-image.py $< $@ $(WEB_IMAGE_BOUND) --quality 80

embedded-examples: $(EMBEDDED_STAMPS) ## Render embedded examples to PDF slideshows or SVG gallery items

# Both flavours emit the same PDF; they differ only in which SVGs accompany it.
# A slideshow keeps a single first-frame cover, a gallery item one SVG per frame.
$(EMBEDDED_SLIDESHOW_STAMPS): EMBEDDED_SVG = --pages 1 $(EMBEDDED_ASSETS_DIR)/$*-cover.svg
$(EMBEDDED_IMAGE_STAMPS): EMBEDDED_SVG = '$(EMBEDDED_ASSETS_DIR)/$*-{0p}.svg'

$(EMBEDDED_STAMPS): $(EMBEDDED_STAMP_DIR)/%.stamp: $(EMBEDDED_EXAMPLES_DIR)/%.typ $(PACKAGE_SOURCES) $(WEB_IMAGES) $(EMBEDDED_SLIDESHOW_INDEXER) scripts/embedded_examples.py Makefile | install
	@mkdir -p "$(dir $(EMBEDDED_ASSETS_DIR)/$*)" "$(@D)"
	@echo "typst compile $< $(EMBEDDED_ASSETS_DIR)/$*.pdf $(EMBEDDED_SVG)"
	@find "$(dir $(EMBEDDED_ASSETS_DIR)/$*)" -maxdepth 1 -type f -name "$(notdir $*)-*.svg" -delete
	@$(TYPST) compile --root . "$<" "$(EMBEDDED_ASSETS_DIR)/$*.pdf"
	@$(TYPST) compile --root . --format svg "$<" $(EMBEDDED_SVG)
	@touch "$@"

showcase-video: $(SHOWCASE_VIDEO) $(SHOWCASE_POSTER) ## Build the animated home-page showcase

$(SHOWCASE_OPENING): $(SHOWCASE_OPENING_SOURCE) $(PACKAGE_SOURCES) | install
	$(TYPST) compile --root . "$<" "$@"

# One run writes both the reel and its poster, which is the reel's first frame.
# A newer prerequisite only makes the script re-render and re-hash the frames;
# unless a slide really changed it leaves both files untouched.
$(SHOWCASE_VIDEO) $(SHOWCASE_POSTER) &: scripts/build-docs-showcase-video.sh $(DECK_MANIFEST) $(SHOWCASE_STAMPS)
	./scripts/build-docs-showcase-video.sh $(PYTHON)

components: install ## Compile the public facade and components test deck
	$(TYPST) compile --root . tests/components.typ /tmp/mosaic-components.pdf

api-sources: $(API_STAGED_MODULES) ## Stage public modules for Tidy inside the Calepin root

$(foreach entry,$(API_MODULE_MAP),$(eval \
  $(API_MODULES_DIR)/$(word 1,$(subst :, ,$(entry))).typ: \
  $(PACKAGE_DIR)/src/$(word 2,$(subst :, ,$(entry))).typ))

$(API_MAPPED_MODULES):
	mkdir -p $(API_MODULES_DIR)
	cp $< $@

$(API_MODULES_DIR)/setup.typ: $(DOCS_DIR)/api/sources/setup.typ
	mkdir -p $(API_MODULES_DIR)
	cp $< $@

examples: $(DECK_STAMPS) ## Compile the docs/examples/decks projects (PDF slideshows + cover thumbnails)

# Build each example deck via its own Makefile (which knows its typst flags and
# fonts), then render the first page to a JPEG cover for the Examples gallery.
$(DECK_STAMP_DIR)/%.stamp: $(PACKAGE_SOURCES) $(DECK_METADATA) Makefile | install
	@mkdir -p "$(@D)"
	@echo "examples: building $*"
	@$(MAKE) --no-print-directory -C "$(DECK_EXAMPLES_DIR)/$*"
	@pdftoppm -jpeg -jpegopt quality=82 -singlefile -f 1 -l 1 -scale-to 1200 \
		"$(DECK_EXAMPLES_DIR)/$*/$*.pdf" "$(DECK_EXAMPLES_DIR)/$*/cover"
	@touch "$@"

website: install embedded-examples showcase-video api-sources examples ## Install Mosaic and build the Calepin website
	$(CALEPIN) compile $(DOCS_DIR) $(DOCS_DIR)
	$(PYTHON) scripts/normalize-html.py
	$(PYTHON) scripts/check-doc-assets.py --site

docs: website ## Build the Calepin documentation website

clean: ## Remove ephemeral staging files and build stamps
	rm -f $(API_MODULES_DIR)/*.typ
	rm -rf $(EMBEDDED_STAMP_DIR)
	rm -rf $(DECK_STAMP_DIR)
	rm -rf $(DOCS_DIR)/.calepin

clean-generated: clean ## Remove reproducible media and rendered example outputs
	find $(EMBEDDED_ASSETS_DIR) -type f \( -name '*.pdf' -o -name '*.svg' \) -delete
	for slug in $(DECK_SLUGS); do rm -f "$(DECK_EXAMPLES_DIR)/$$slug/$$slug.pdf" "$(DECK_EXAMPLES_DIR)/$$slug/cover.jpg"; done
	rm -f $(BONSAI_WEBP) $(DOG_WEBP) $(SHOWCASE_VIDEO) $(SHOWCASE_POSTER) $(SHOWCASE_FINGERPRINT) $(SHOWCASE_OPENING)

distclean: clean-generated ## Also remove published HTML and Calepin's generated cache
	find $(DOCS_DIR) -type f -name '*.html' -delete
	find $(DOCS_DIR)/_calepin -mindepth 1 ! -name favicon.svg -delete 2>/dev/null || true
