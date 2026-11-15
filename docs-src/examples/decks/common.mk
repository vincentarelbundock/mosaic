.PHONY: all clean

TYPST ?= typst
# Every hand-authored file in the deck is an input: sources, images in any
# format, bibliographies. The top-level Makefile watches this same set to decide
# whether to call in here, so the two must agree: a file one of them misses is
# a stale PDF that gets stamped as fresh.
SOURCES := $(shell find . -type f ! -path './.calepin/*' ! -name '*.pdf' ! -name 'cover.jpg' | sort)
# A deck pinned to the released @preview package renders the same bytes whatever
# the working tree holds. Only a deck importing @local/mosaic follows the
# repository tree, which `make install` copies into Typst's package index.
ifneq ($(shell grep -l '@local/mosaic:' *.typ 2>/dev/null),)
PACKAGE_SOURCES := $(shell find ../../../../mosaic -type f ! -path '*/mosaic/docs/*' ! -name 'README.md' 2>/dev/null | sort)
endif

all: $(DECK).pdf

# For an accessible deck, export against Typst's tagged-PDF standard instead:
#	typst compile --root ../../.. --pdf-standard ua-1 main.typ $@
$(DECK).pdf: $(SOURCES) $(PACKAGE_SOURCES)
	$(TYPST) compile --root ../../.. main.typ $@

clean:
	rm -f $(DECK).pdf
