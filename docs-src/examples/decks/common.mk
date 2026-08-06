.PHONY: all clean

SOURCES := $(wildcard *.typ)
DECK_DEPS ?=
# The decks import the installed @preview/mosaic package, so a package edit must
# rebuild them; the repository tree is the dependency proxy for the installed
# copy (make install refreshes the latter from the former).
PACKAGE_SOURCES := $(shell find ../../../../mosaic -type f 2>/dev/null | sort)

all: $(DECK).pdf

$(DECK).pdf: $(SOURCES) $(DECK_DEPS) $(PACKAGE_SOURCES)
	typst compile --root ../../.. main.typ $@

clean:
	rm -f $(DECK).pdf
