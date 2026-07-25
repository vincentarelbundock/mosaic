.DEFAULT_GOAL := help

.PHONY: help install build check core-tests negative-tests template-tests web-images tutorial-slides showcase-video components api-sources examples website docs clean

TYPST ?= typst
CALEPIN ?= calepin
RIMAGE ?= rimage
PACKAGE_DIR := mosaic
PACKAGE_NAME := mosaic
PACKAGE_VERSION := 0.0.1
TYPST_DATA_DIR ?= $(if $(XDG_DATA_HOME),$(XDG_DATA_HOME),$(HOME)/.local/share)
TYPST_PACKAGE_PATH ?= $(shell $(TYPST) info 2>/dev/null | awk '/Package path/{print $$3; exit}')
ifeq ($(strip $(TYPST_PACKAGE_PATH)),)
TYPST_PACKAGE_PATH := $(TYPST_DATA_DIR)/typst/packages
endif
LOCAL_PACKAGE_DIR := $(TYPST_PACKAGE_PATH)/local/$(PACKAGE_NAME)/$(PACKAGE_VERSION)
DOCS_DIR := docs

# Full example decks shipped under docs/examples/. Each has its own Makefile
# that builds <slug>.pdf; the top-level rule below also renders a cover.jpg.
EXAMPLES_DIR := $(DOCS_DIR)/examples
EXAMPLE_MAKEFILES := $(wildcard $(EXAMPLES_DIR)/*/Makefile)
EXAMPLE_SLUGS := $(notdir $(patsubst %/,%,$(dir $(EXAMPLE_MAKEFILES))))
EXAMPLE_STAMP_DIR := .build/examples
EXAMPLE_STAMPS := $(addprefix $(EXAMPLE_STAMP_DIR)/,$(addsuffix .stamp,$(EXAMPLE_SLUGS)))

TUTORIAL_EXAMPLES_DIR := $(DOCS_DIR)/tutorial-examples
TUTORIAL_ASSETS_DIR := $(DOCS_DIR)/assets/tutorials
TUTORIAL_STAMP_DIR := .build/tutorial-slides
WEB_IMAGE_DIR := $(DOCS_DIR)/assets/images
BONSAI_SOURCE := $(WEB_IMAGE_DIR)/bonsai.png
BONSAI_WEBP := $(WEB_IMAGE_DIR)/bonsai.webp
DOG_SOURCE := $(WEB_IMAGE_DIR)/dog.jpg
DOG_WEBP := $(WEB_IMAGE_DIR)/dog.webp
API_MODULES_DIR := $(DOCS_DIR)/api/modules
API_MODULE_NAMES := author color components deck-commands deck-state grid-model incremental-core incremental setup shared template-default template-image template-section template-table template-title
API_STAGED_MODULES := $(addprefix $(API_MODULES_DIR)/,$(addsuffix .typ,$(API_MODULE_NAMES)))
# These files are both compiled below and read verbatim by the tutorial pages.
TUTORIAL_EXAMPLE_SOURCES := $(shell find $(TUTORIAL_EXAMPLES_DIR) -type f -name '*.typ' 2>/dev/null | sort)
# Multi-frame examples are shipped as one PDF plus a first-frame SVG cover.
# Derive that set from the docs so adding a slideshow needs no build manifest.
TUTORIAL_DECK_SLUGS := $(shell perl scripts/list-tutorial-decks.pl $(wildcard $(DOCS_DIR)/*.typ))
TUTORIAL_DECK_SOURCES := $(addprefix $(TUTORIAL_EXAMPLES_DIR)/,$(addsuffix .typ,$(TUTORIAL_DECK_SLUGS)))
TUTORIAL_IMAGE_SOURCES := $(filter-out $(TUTORIAL_DECK_SOURCES),$(TUTORIAL_EXAMPLE_SOURCES))
TUTORIAL_DECK_STAMPS := $(patsubst $(TUTORIAL_EXAMPLES_DIR)/%.typ,$(TUTORIAL_STAMP_DIR)/%.stamp,$(TUTORIAL_DECK_SOURCES))
TUTORIAL_IMAGE_STAMPS := $(patsubst $(TUTORIAL_EXAMPLES_DIR)/%.typ,$(TUTORIAL_STAMP_DIR)/%.stamp,$(TUTORIAL_IMAGE_SOURCES))
TUTORIAL_STAMPS := $(TUTORIAL_DECK_STAMPS) $(TUTORIAL_IMAGE_STAMPS)
PACKAGE_SOURCES := $(shell find $(PACKAGE_DIR) -type f 2>/dev/null | sort)
SHOWCASE_VIDEO := $(WEB_IMAGE_DIR)/showcase.webm
SHOWCASE_STAMPS := \
	$(TUTORIAL_STAMP_DIR)/templates/title.stamp \
	$(TUTORIAL_STAMP_DIR)/templates/image-figure.stamp \
	$(TUTORIAL_STAMP_DIR)/color/schemes.stamp \
	$(TUTORIAL_STAMP_DIR)/incremental/fletcher.stamp \
	$(TUTORIAL_STAMP_DIR)/incremental/math.stamp

help: ## Display this help screen
	@echo -e "\033[1mAvailable commands:\033[0m\n"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' | sort

# ==============================================================================
# Build targets
# ==============================================================================

install: ## Copy Mosaic into Typst's local package index
	@test -n "$(TYPST_PACKAGE_PATH)" || { \
		echo "Could not determine Typst's package path; set TYPST_PACKAGE_PATH."; \
		exit 1; \
	}
	rm -rf "$(LOCAL_PACKAGE_DIR)"
	mkdir -p "$(LOCAL_PACKAGE_DIR)"
	cp -R "$(PACKAGE_DIR)/." "$(LOCAL_PACKAGE_DIR)/"
	@echo "Installed @local/$(PACKAGE_NAME):$(PACKAGE_VERSION) in $(LOCAL_PACKAGE_DIR)"

build: install check website ## Install the package, then compile tests and documentation

check: install core-tests template-tests negative-tests ## Install the package and run every test

core-tests: install ## Compile all non-template positive test decks
	@set -e; for source in tests/*.typ; do \
		case "$${source##*/}" in templates*.typ|fit.typ) continue ;; esac; \
		output=/tmp/mosaic-$${source##*/}; \
		output=$${output%.typ}.pdf; \
		echo "typst compile $$source $$output"; \
		$(TYPST) compile --root . "$$source" "$$output"; \
	done
	@$(TYPST) compile --root . tests/color.typ '/tmp/mosaic-color-{0p}.svg' --format svg
	@grep -Fi '#111827' /tmp/mosaic-color-1.svg >/dev/null
	@grep -Fi '#f3f4f6' /tmp/mosaic-color-1.svg >/dev/null
	@grep -Fi '#111827' /tmp/mosaic-color-2.svg >/dev/null
	@grep -Fi '#f3f4f6' /tmp/mosaic-color-2.svg >/dev/null
	@$(TYPST) compile --root . tests/image.typ '/tmp/mosaic-image-{0p}.svg' --format svg
	@grep -Fi '#00000059' /tmp/mosaic-image-1.svg >/dev/null
	@grep -Fi '#ffffff33' /tmp/mosaic-image-1.svg >/dev/null
	@$(TYPST) compile --root . tests/slide-colors.typ '/tmp/mosaic-slide-colors-{0p}.svg' --format svg
	@grep -Fi '#fafaf9' /tmp/mosaic-slide-colors-1.svg >/dev/null
	@grep -Fi '#1c1917' /tmp/mosaic-slide-colors-1.svg >/dev/null
	@grep -Fi '#f7f3ec' /tmp/mosaic-slide-colors-2.svg >/dev/null
	@grep -Fi '#211f1c' /tmp/mosaic-slide-colors-2.svg >/dev/null
	@grep -Fi '#a3312d' /tmp/mosaic-slide-colors-2.svg >/dev/null
	@grep -Fi '#fafaf9' /tmp/mosaic-slide-colors-3.svg >/dev/null
	@grep -Fi '#1c1917' /tmp/mosaic-slide-colors-3.svg >/dev/null
	@grep -Fi '#fafaf9' /tmp/mosaic-slide-colors-4.svg >/dev/null
	@grep -Fi '#d97706' /tmp/mosaic-slide-colors-4.svg >/dev/null
	@grep -Fi '#171a21' /tmp/mosaic-slide-colors-5.svg >/dev/null
	@grep -Fi '#f5f1e8' /tmp/mosaic-slide-colors-5.svg >/dev/null
	@grep -Fi '#d9a441' /tmp/mosaic-slide-colors-5.svg >/dev/null
	@grep -Fi '#171a21' /tmp/mosaic-slide-colors-6.svg >/dev/null
	@grep -Fi '#f5f1e8' /tmp/mosaic-slide-colors-6.svg >/dev/null
	@grep -Fi '#d9a441' /tmp/mosaic-slide-colors-6.svg >/dev/null
	@pdftotext -layout /tmp/mosaic-frozen-state.pdf /tmp/mosaic-frozen-state.txt
	@test "$$(grep -o 'Reveal: frozen 1/1' /tmp/mosaic-frozen-state.txt | wc -l)" -eq 2
	@test "$$(grep -o 'On: frozen 2/2' /tmp/mosaic-frozen-state.txt | wc -l)" -eq 2
	@test "$$(grep -o 'Replace: frozen 3/3' /tmp/mosaic-frozen-state.txt | wc -l)" -eq 2
	@grep -F 'Reveal: frozen 1/1 native 1/1' /tmp/mosaic-frozen-state.txt >/dev/null
	@grep -F 'Reveal: frozen 1/1 native 2/2' /tmp/mosaic-frozen-state.txt >/dev/null
	@grep -F 'On: frozen 2/2 native 3/3' /tmp/mosaic-frozen-state.txt >/dev/null
	@grep -F 'On: frozen 2/2 native 4/4' /tmp/mosaic-frozen-state.txt >/dev/null
	@grep -F 'Replace: frozen 3/3 native 5/5' /tmp/mosaic-frozen-state.txt >/dev/null
	@grep -F 'Replace: frozen 3/3 native 6/6' /tmp/mosaic-frozen-state.txt >/dev/null
	@grep -F 'Final: frozen 3/3 native 6/6.' /tmp/mosaic-frozen-state.txt >/dev/null
	@pdftotext -layout /tmp/mosaic-handout.pdf /tmp/mosaic-handout.txt
	@grep -F 'REPLACE FINAL' /tmp/mosaic-handout.txt >/dev/null
	@grep -F 'HANDOUT STEP 2 / 2' /tmp/mosaic-handout.txt >/dev/null
	@grep -F 'REVEAL FIRST' /tmp/mosaic-handout.txt >/dev/null
	@grep -F 'REVEAL FINAL' /tmp/mosaic-handout.txt >/dev/null
	@grep -F 'ON BASE ON FINAL' /tmp/mosaic-handout.txt >/dev/null
	@grep -F 'REDUCER BASE | REDUCER FINAL' /tmp/mosaic-handout.txt >/dev/null
	@grep -F 'BACKGROUND' /tmp/mosaic-handout.txt >/dev/null
	@grep -F 'FOREGROUND FINAL' /tmp/mosaic-handout.txt >/dev/null
	@grep -F 'STATIC FINAL: frozen 1/1 native 1/1.' /tmp/mosaic-handout.txt >/dev/null
	@! grep -F 'REPLACE FIRST' /tmp/mosaic-handout.txt >/dev/null
	@! grep -F 'BACKGROUND FIRST' /tmp/mosaic-handout.txt >/dev/null
	@! grep -F 'FOREGROUND FIRST' /tmp/mosaic-handout.txt >/dev/null
	@pdftotext -layout /tmp/mosaic-handout-off.pdf /tmp/mosaic-handout-off.txt
	@grep -F 'ORDINARY FIRST' /tmp/mosaic-handout-off.txt >/dev/null
	@grep -F 'ORDINARY FINAL' /tmp/mosaic-handout-off.txt >/dev/null
	@test "$$($(TYPST) eval --root . 'query(<mosaic-overflow-warning>).len()' --in tests/overflow-warning.typ)" -eq 2
	@$(TYPST) eval --root . 'query(<mosaic-overflow-warning>).map(it => it.value)' --in tests/overflow-warning.typ > /tmp/mosaic-overflow-warning.json
	@grep -F '"logical-slide":2' /tmp/mosaic-overflow-warning.json >/dev/null
	@grep -F '"frame":1' /tmp/mosaic-overflow-warning.json >/dev/null
	@grep -F '"frame":2' /tmp/mosaic-overflow-warning.json >/dev/null
	@grep -F '"cell":"body"' /tmp/mosaic-overflow-warning.json >/dev/null
	@grep -F 'mosaic: content overflows cell' /tmp/mosaic-overflow-warning.json >/dev/null
	@test "$$($(TYPST) eval --root . 'query(<mosaic-overflow-warning>).len()' --in tests/overflow-off.typ)" -eq 0
	@$(TYPST) compile --root . tests/overflow-warning.typ '/tmp/mosaic-overflow-warning-{0p}.svg' --format svg
	@! grep -F 'transform="scale(' /tmp/mosaic-overflow-warning-*.svg >/dev/null
	@pdftotext -layout /tmp/mosaic-section-counter.pdf /tmp/mosaic-section-counter.txt
	@grep -F '1 / 2' /tmp/mosaic-section-counter.txt >/dev/null
	@grep -F '2 / 2' /tmp/mosaic-section-counter.txt >/dev/null

negative-tests: install ## Require every diagnostic fixture to fail with a Mosaic error
	@set -e; for source in tests/invalid/*.typ; do \
		stem=$${source##*/}; stem=$${stem%.typ}; \
		output=/tmp/mosaic-invalid-$$stem.pdf; \
		log=/tmp/mosaic-invalid-$$stem.log; \
		echo "typst compile (expect failure) $$source"; \
		if $(TYPST) compile --root . "$$source" "$$output" >"$$log" 2>&1; then \
			echo "expected $$source to fail"; exit 1; \
		fi; \
		grep -F 'mosaic:' "$$log" >/dev/null; \
	done
	@while IFS='|' read -r stem expected; do \
		[ -z "$$stem" ] && continue; \
		grep -F -- "$$expected" "/tmp/mosaic-invalid-$$stem.log" >/dev/null || { \
			echo "missing expected diagnostic for $$stem: $$expected"; \
			exit 1; \
		}; \
	done < tests/invalid/expected-diagnostics.txt

template-tests: install web-images ## Compile every semantic template test deck
	@set -e; for source in tests/templates*.typ; do \
		case "$${source##*/}" in templates-title-responsive.typ) continue ;; esac; \
		output=/tmp/mosaic-$${source##*/}; \
		output=$${output%.typ}.pdf; \
		echo "typst compile $$source $$output"; \
		$(TYPST) compile --root . "$$source" "$$output"; \
	done
	@set -e; for paper in 16-9 4-3; do for scheme in light dark; do \
		output=/tmp/mosaic-templates-title-responsive-$$scheme-$$paper.pdf; \
		echo "typst compile title responsive $$scheme $$paper $$output"; \
		$(TYPST) compile --root . --input paper=$$paper --input scheme=$$scheme \
			tests/templates-title-responsive.typ "$$output"; \
		warnings=$$($(TYPST) eval --root . --input paper=$$paper --input scheme=$$scheme \
			'query(<mosaic-overflow-warning>).len()' --in tests/templates-title-responsive.typ); \
		test "$$warnings" -eq 0; \
	done; done
	@$(TYPST) compile --root . tests/fit.typ /tmp/mosaic-fit.pdf
	@pdftotext -layout /tmp/mosaic-templates-features.pdf /tmp/mosaic-templates-features.txt
	@grep -F 'Mosaic feature test' /tmp/mosaic-templates-features.txt >/dev/null
	@grep -F '1/2' /tmp/mosaic-templates-features.txt >/dev/null
	@grep -F '2/2' /tmp/mosaic-templates-features.txt >/dev/null
	@$(TYPST) compile --root . tests/templates-cell-style.typ '/tmp/mosaic-templates-cell-style-{p}.svg'
	@grep -Fi '#123456' /tmp/mosaic-templates-cell-style-1.svg >/dev/null
	@grep -Fi '#fedcba' /tmp/mosaic-templates-cell-style-1.svg >/dev/null
	@$(TYPST) compile --root . tests/templates-setup-settings.typ '/tmp/mosaic-setup-settings-{p}.svg'
	@grep -Fi '#123456' /tmp/mosaic-setup-settings-1.svg >/dev/null
	@grep -Fi '#abcdef' /tmp/mosaic-setup-settings-1.svg >/dev/null
	@$(TYPST) compile --root . tests/templates-progress.typ '/tmp/mosaic-templates-progress-{p}.svg'
	@grep -Fi '#d97706' /tmp/mosaic-templates-progress-1.svg >/dev/null
	@grep -Fi '#ffffff' /tmp/mosaic-templates-progress-2.svg >/dev/null
	@grep -Fi '#fedcba' /tmp/mosaic-templates-progress-3.svg >/dev/null
	@grep -Fi '#123456' /tmp/mosaic-templates-progress-4.svg >/dev/null
	@pdftotext -layout /tmp/mosaic-templates-logo.pdf /tmp/mosaic-templates-logo.txt
	@test "$$(grep -o 'GLOBAL-LOGO' /tmp/mosaic-templates-logo.txt | wc -l)" -eq 1
	@test "$$(grep -o 'LOCAL-LOGO' /tmp/mosaic-templates-logo.txt | wc -l)" -eq 0

web-images: $(BONSAI_WEBP) $(DOG_WEBP) ## Generate compact WebP derivatives while retaining source images

$(BONSAI_WEBP): $(BONSAI_SOURCE)
	mkdir -p $(WEB_IMAGE_DIR)
	$(RIMAGE) webp --resize 1600w --downscale -q 80 -x -d $(WEB_IMAGE_DIR) $<

$(DOG_WEBP): $(DOG_SOURCE)
	mkdir -p $(WEB_IMAGE_DIR)
	$(RIMAGE) webp --resize 1600h --downscale -q 80 -x -d $(WEB_IMAGE_DIR) $<

tutorial-slides: $(TUTORIAL_STAMPS) ## Render tutorial decks to PDF and gallery items to SVG

$(TUTORIAL_DECK_STAMPS): $(TUTORIAL_STAMP_DIR)/%.stamp: $(TUTORIAL_EXAMPLES_DIR)/%.typ $(PACKAGE_SOURCES) $(BONSAI_WEBP) $(DOG_WEBP) Makefile | install
	@mkdir -p "$(TUTORIAL_ASSETS_DIR)/$(@D:$(TUTORIAL_STAMP_DIR)/%=%)" "$(@D)"
	@echo "typst compile $< $(TUTORIAL_ASSETS_DIR)/$*.pdf"
	@find "$(TUTORIAL_ASSETS_DIR)/$(@D:$(TUTORIAL_STAMP_DIR)/%=%)" -maxdepth 1 -type f -name "$(@F:.stamp=)-*.svg" -delete
	@$(TYPST) compile --root . "$<" "$(TUTORIAL_ASSETS_DIR)/$*.pdf"
	@$(TYPST) compile --root . --pages 1 "$<" "$(TUTORIAL_ASSETS_DIR)/$*-cover.svg"
	@touch "$@"

$(TUTORIAL_IMAGE_STAMPS): $(TUTORIAL_STAMP_DIR)/%.stamp: $(TUTORIAL_EXAMPLES_DIR)/%.typ $(PACKAGE_SOURCES) $(BONSAI_WEBP) $(DOG_WEBP) Makefile | install
	@mkdir -p "$(TUTORIAL_ASSETS_DIR)/$(@D:$(TUTORIAL_STAMP_DIR)/%=%)" "$(@D)"
	@echo "typst compile $< $(TUTORIAL_ASSETS_DIR)/$*-{0p}.svg"
	@find "$(TUTORIAL_ASSETS_DIR)/$(@D:$(TUTORIAL_STAMP_DIR)/%=%)" -maxdepth 1 -type f -name "$(@F:.stamp=)-*.svg" -delete
	@rm -f "$(TUTORIAL_ASSETS_DIR)/$*.pdf"
	@$(TYPST) compile --root . "$<" "$(TUTORIAL_ASSETS_DIR)/$*-{0p}.svg" --format svg
	@touch "$@"

showcase-video: $(SHOWCASE_VIDEO) ## Build the animated home-page showcase

$(SHOWCASE_VIDEO): scripts/build-docs-showcase-video.sh $(SHOWCASE_STAMPS)
	./scripts/build-docs-showcase-video.sh

components: install ## Compile the public facade and components test deck
	$(TYPST) compile --root . tests/components.typ /tmp/mosaic-components.pdf

api-sources: $(API_STAGED_MODULES) ## Stage public modules for Tidy inside the Calepin root

$(API_MODULES_DIR)/%.typ: $(PACKAGE_DIR)/src/%.typ
	mkdir -p $(API_MODULES_DIR)
	cp $< $@

examples: $(EXAMPLE_STAMPS) ## Compile the docs/examples decks (PDF slideshows + cover thumbnails)

# Build each example deck via its own Makefile (which knows its typst flags and
# fonts), then render the first page to a JPEG cover for the Examples gallery.
$(EXAMPLE_STAMP_DIR)/%.stamp: $(EXAMPLES_DIR)/%/main.typ $(EXAMPLES_DIR)/%/Makefile $(PACKAGE_SOURCES) | install
	@mkdir -p "$(@D)"
	@echo "examples: building $*"
	@$(MAKE) --no-print-directory -C "$(EXAMPLES_DIR)/$*"
	@pdftoppm -jpeg -jpegopt quality=82 -singlefile -f 1 -l 1 -scale-to 1200 \
		"$(EXAMPLES_DIR)/$*/$*.pdf" "$(EXAMPLES_DIR)/$*/cover"
	@touch "$@"

website: install tutorial-slides showcase-video api-sources examples ## Install Mosaic and build the Calepin website
	$(CALEPIN) compile $(DOCS_DIR) $(DOCS_DIR)

docs: website ## Build the Calepin documentation website

clean: ## Remove staged API modules
	rm -f $(API_MODULES_DIR)/*.typ
	rm -rf $(TUTORIAL_STAMP_DIR)
	rm -rf $(EXAMPLE_STAMP_DIR)
